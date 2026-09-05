import { onDocumentUpdated } from "firebase-functions/v2/firestore";
import admin from "firebase-admin";
import { v4 as uuidv4 } from "uuid";

const db = admin.firestore();

export const createLedgerOnFeePaymentUpdate = onDocumentUpdated(
  "feepayment/{paymentId}",
  async (event) => {
    const before = event.data.before.data();
    const after = event.data.after.data();
    if (!after) return;
    const paymentRef = event.data.after.ref;
    const { studentId, schoolId, term, receivedaccount, fees, level, yeargroup } = after;
    const prevFees = before?.fees || {};
    try {
      // Get student
      const studentDoc = await db.collection("students").doc(`${schoolId}_${studentId}`).get();
      if (!studentDoc.exists) return;
      const student = studentDoc.data();

      // Get system activity for 'fee payment'
      const activitySnap = await db.collection("systemActivity").where("name", "==", "Fee Payment").limit(1).get();
      if (activitySnap.empty) return;
      const activityData = activitySnap.docs[0].data();
      const { crAccount, crAccountClass, crAccountSubClass } = activityData;

      // Get mainaccounts data for debit account
      let debitAccountClass = null;
      let debitSubClass = null;
      if (receivedaccount) {
        const mainAccDoc = await db.collection("mainaccounts").where("name", "==", receivedaccount).get();
        if (!mainAccDoc.empty) {
          const mainAccData = mainAccDoc.docs[0].data();
          debitAccountClass = mainAccData.accountType ?? null;
          debitSubClass = mainAccData.subType ?? null;
        }
      }

      // Only create ledger for newly added fee names
      const batch = db.batch();
      let ledgerCount = 0;
      for (const [feeType, amount] of Object.entries(fees || {})) {
        if (typeof amount !== "number" || amount <= 0) continue;
        if (feeType in prevFees) continue; // skip existing fee names
        const ledgerId = `${event.params.paymentId}_${studentId}_${feeType.replace(/\s+/g, "_")}`;
        const ledgerRef = db.collection("ledger").doc(ledgerId);
        batch.set(ledgerRef, {
          transactionId: uuidv4(),
          studentId,
          studentName: student.name || null,
          schoolId,
          activityType: "fee payment",
          feeName: feeType,
          term,
          level,
          yeargroup,
          amount: Number(amount),
          paymentId: event.params.paymentId,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
          accounts: {
            debit: {
              account: receivedaccount ?? null,
              accountClass: debitAccountClass,
              value: Number(amount),
              subClass: debitSubClass,
            },
            credit: {
              account: crAccount ?? null,
              accountClass: crAccountClass ?? null,
              value: Number(amount),
              subClass: crAccountSubClass ?? null,
            },
          },
        });
        ledgerCount++;
      }
      if (ledgerCount > 0) {
        await batch.commit();
        await paymentRef.update({
          ledgerStatus: "success",
          ledgerMessage: `Ledger created for ${ledgerCount} new fee types for student ${studentId}.`,
        });
      }
    } catch (error) {
      await paymentRef.update({
        ledgerStatus: "failed",
        ledgerMessage: `Error: ${error.message}`,
      });
    }
  }
);
