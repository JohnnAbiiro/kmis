import { onDocumentUpdated } from "firebase-functions/v2/firestore";
// Ledger posting for singlebilled (top-up or unbilled students)
import { onDocumentCreated } from "firebase-functions/v2/firestore";
import admin from "firebase-admin";
import { v4 as uuidv4 } from "uuid"; // install with: npm install uuid

if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();

// Ledger posting for expense collection
export const createLedgerOnExpense = onDocumentCreated(
  "expense/{expenseId}",
  async (event) => {
    const snapshot = event.data;
    if (!snapshot) return;
    const expenseData = snapshot.data();
    if (!expenseData) return;
    const expenseRef = snapshot.ref;
  const { schoolId, term, expenseType, expenseName, fees, paidAccount} = expenseData;
    try {
      let creditAccount = null;
      let creditAccountClass = null;
      let creditAccountSubClass = null;
      let debitAccountClass = null;
      let debitAccountSubClass = null;

      // Get debit account class/subtype from mainaccounts
      const debitAccDoc = await db.collection("mainaccounts").where("name", "==", expenseName).limit(1).get();
      if (!debitAccDoc.empty) {
        const debitAccData = debitAccDoc.docs[0].data();
        debitAccountClass = debitAccData.accountType ?? null;
        debitAccountSubClass = debitAccData.subType ?? null;
      }

      if (expenseType === "Unpaid") {
         const activitySnap = await db.collection("systemActivity").where("name", "==", "Unpaid Expense").limit(1).get();
        if (activitySnap.empty) throw new Error("SystemActivity 'Unpaid Expense' not found.");
        const activityData = activitySnap.docs[0].data();
        creditAccount = activityData.crAccount ?? null;
        // Get systemActivity for Unpaid Expense
       
        // Get credit account class/subtype from mainaccounts
        const creditAccDoc = await db.collection("mainaccounts").where("name", "==", creditAccount).limit(1).get();
        if (!creditAccDoc.empty) {
          const creditAccData = creditAccDoc.docs[0].data();
          creditAccountClass = creditAccData.accountType ?? null;
          creditAccountSubClass = creditAccData.subType ?? null;
        } else {
          creditAccountClass = activityData.crAccountClass ?? null;
          creditAccountSubClass = activityData.crAccountSubClass ?? null;
        }
      } else if (expenseType === "Paid") {
        creditAccount = paidAccount ?? null;
        // Get credit account class/subtype from mainaccounts
        const creditAccDoc = await db.collection("mainaccounts").where("name", "==", creditAccount).limit(1).get();
        if (!creditAccDoc.empty) {
          const creditAccData = creditAccDoc.docs[0].data();
          creditAccountClass = creditAccData.accountType ?? null;
          creditAccountSubClass = creditAccData.subType ?? null;
        } else {
          creditAccountClass = null;
          creditAccountSubClass = null;
        }
      }

      // Post to ledger
      const ledgerId = `${event.params.expenseId}_${expenseName}`;
      const ledgerRef = db.collection("ledger").doc(ledgerId);
      await ledgerRef.set({
        transactionId: uuidv4(),
        schoolId,
        term,
        activityType: "expense",
        expenseName,
        amount: String(fees),
        expenseId: event.params.expenseId,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        accounts: {
          debit:{
            account: expenseName,
            accountClass: debitAccountClass,
            value: String(fees),
            subClass: debitAccountSubClass,
          },
          credit:{
            account: creditAccount,
            accountClass: creditAccountClass,
            value: String(fees),
            subClass: creditAccountSubClass,
          },
        },
      });
      await expenseRef.update({
        ledgerStatus: "success",
        ledgerMessage: `Ledger posted for expense ${expenseName} (${expenseType})`,
      });
    } catch (error) {
      await expenseRef.update({
        ledgerStatus: "failed",
        ledgerMessage: `Error: ${error.message}`,
      });
    }
});

// Trigger: create ledger for newly added fee names in feepayment (on update)
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
          amount: String(fees),
          paymentId: event.params.paymentId,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
          accounts: {
            debit: {
              account: receivedaccount ?? null,
              accountClass: debitAccountClass,
              value: String(fees),
              subClass: debitSubClass,
            },
            credit: {
              account: crAccount ?? null,
              accountClass: crAccountClass ?? null,
              value: String(fees),
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


// Trigger: create ledger for newly added fee names in feepayment
// Ledger posting for feepayment collection
export const createLedgerOnFeePayment = onDocumentCreated(
  "feepayment/{paymentId}",
  async (event) => {
    const snapshot = event.data;
    if (!snapshot) {
      console.log("No feepayment document found.");
      return;
    }
    const paymentData = snapshot.data();
    if (!paymentData) {
      console.log("Empty feepayment data.");
      return;
    }
    const paymentRef = snapshot.ref;
  const { studentId, schoolId, term, receivedaccount, fees, level, yeargroup } = paymentData;
    try {
      // Get student
      const studentDoc = await db.collection("students").doc(`${schoolId}_${studentId}`).get();
      if (!studentDoc.exists) {
        await paymentRef.update({
          ledgerStatus: "failed",
          ledgerMessage: `Student ${studentId} not found`,
        });
        return;
      }
  const student = studentDoc.data();
      // Get system activity for 'fee payment'
      const activitySnap = await db
        .collection("systemActivity")
        .where("name", "==", "Fee Payment")
        .limit(1)
        .get();
      if (activitySnap.empty) {
        await db.collection("errors").add({
          message: `SystemActivity with name 'fee payment' not found.`,
          paymentId: event.params.paymentId,
          timestamp: admin.firestore.FieldValue.serverTimestamp(),
        });
        await paymentRef.update({
          ledgerStatus: "failed",
          ledgerMessage: `SystemActivity 'fee payment' not found.`,
        });
        return;
      }
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

      // Create a ledger entry for each fee type in the fees map
      const batch = db.batch();
      let ledgerCount = 0;
      for (const [feeType, amount] of Object.entries(fees || {})) {
        if (typeof amount !== "number" || amount <= 0) continue;
        const transactionId = uuidv4();
        const ledgerId = `${event.params.paymentId}_${studentId}_${feeType.replace(/\s+/g, "_")}`;
        const ledgerRef = db.collection("ledger").doc(ledgerId);
        batch.set(ledgerRef, {
          transactionId,
          studentId,
          studentName: student.name || null,
          schoolId,
          activityType: "fee payment",
          feeName: feeType,
          term,
          level,
          yeargroup,
          amount: String(amount),
          paymentId: event.params.paymentId,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
          accounts: {
            debit: {
              account: receivedaccount ?? null,
              accountClass: debitAccountClass,
              value: String(amount),
              subClass: debitSubClass,
            },
            credit: {
              account: crAccount ?? null,
              accountClass: crAccountClass ?? null,
              value: String(amount),
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
          ledgerMessage: `Ledger created for ${ledgerCount} fee types for student ${studentId}.`,
        });
        console.log(`Ledger created for ${ledgerCount} fee types for student ${studentId}`);
      } else {
        await paymentRef.update({
          ledgerStatus: "failed",
          ledgerMessage: `No valid fee types found for student ${studentId}.`,
        });
        console.log(`No valid fee types found for student ${studentId}`);
      }
    } catch (error) {
      console.error("Error creating feepayment ledger entry:", error);
      await paymentRef.update({
        ledgerStatus: "failed",
        ledgerMessage: `Error: ${error.message}`,
      });
    }
  }
);


export const createLedgerOnSingleBilling = onDocumentCreated(
  "singlebilled/{singleBillId}",
  async (event) => {
    const snapshot = event.data;
    if (!snapshot) {
      console.log("No singlebilled document found.");
      return;
    }

    const billData = snapshot.data();
    if (!billData) {
      console.log("Empty singlebilled data.");
      return;
    }

    const billRef = snapshot.ref;
    const { studentId, schoolId, amount, term, activityType, feeName, level, yeargroup,ledgerid } = billData;
    try {
      // Get student
      const studentDoc = await db.collection("students").doc(`${schoolId}_${studentId}`).get();
      if (!studentDoc.exists) {
        await billRef.update({
          ledgerStatus: "failed",
          ledgerMessage: `Student ${studentId} not found`,
        });
        return;
      }
      const student = studentDoc.data();

      // Get system activity
      const activitySnap = await db.collection("systemActivity").where("name", "==", activityType).limit(1).get();
      if (activitySnap.empty) {
        await db.collection("errors").add({
          message: `SystemActivity with name '${activityType}' not found.`,
          singleBillId: event.params.singleBillId,
          timestamp: admin.firestore.FieldValue.serverTimestamp(),
        });
        await billRef.update({
          ledgerStatus: "failed",
          ledgerMessage: `SystemActivity '${activityType}' not found.`,
        });
        return;
      }
      const activityData = activitySnap.docs[0].data();
      const { crAccount, crAccountClass, drAccount, drAccountClass, staff, crAccountSubClass, drAccountSubClass } = activityData;

      // Ledger entry
      const transactionId = uuidv4();
      const note = `Being ${feeName} single billed  for ${term} Term`;
      const status=true;
     // const ledgerId = `${event.params.singleBillId}_${studentId}`;
      const ledgerRef = db.collection("ledger").doc(ledgerid);
      await ledgerRef.set({
        transactionId,
        studentId,
        studentName: student.name || null,
        schoolId,
        activityType,
        feeName,
        term,
        note,
        status,
        level,
        staff,
        yeargroup,
        amount: String(amount),
        singleBillId: event.params.singleBillId,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        accounts: {
          debit: {
            account: drAccount ?? null,
            accountClass: drAccountClass ?? null,
            value: String(amount),
            subClass: drAccountSubClass ?? null,
          },
          credit: {
            account: crAccount ?? null,
            accountClass: crAccountClass ?? null,
            value: String(amount),
            subClass: crAccountSubClass ?? null,
          },
        },
      });

      await billRef.update({
        ledgerStatus: "success",
        ledgerMessage: `Ledger created for student ${studentId}.`,
      });
      console.log(`Ledger created for singlebilled student ${studentId}`);
    } catch (error) {
      console.error("Error creating singlebilled ledger entry:", error);
      await billRef.update({
        ledgerStatus: "failed",
        ledgerMessage: `Error: ${error.message}`,
      });
    }
  }
);

export const createLedgerOnBilling = onDocumentCreated(
  "billed/{billId}",
  async (event) => {
    const snapshot = event.data;
    if (!snapshot) {
      console.log("No billed document found.");
      return;
    }

    const billedData = snapshot.data();
    if (!billedData) {
      console.log("Empty billed data.");
      return;
    }

    const billedRef = snapshot.ref;
    const { level, yeargroup, schoolId, amount, term, activityType,feeName } = billedData;

    try {
      // 1. Get matching students
      const studentsSnap = await db
        .collection("students")
        .where("level", "==", level)
        .where("yeargroup", "==", yeargroup)
        .where("schoolId", "==", schoolId)
        .get();

      if (studentsSnap.empty) {
        console.log(`No students found for ${level}, ${yeargroup}, ${schoolId}`);
        await billedRef.update({
          ledgerStatus: "failed",
          ledgerMessage: `No students found for ${level}, ${yeargroup}, ${schoolId}`,
        });
        return;
      }

      // 2. Get system activity by name
      const activitySnap = await db
        .collection("systemActivity")
        .where("name", "==", activityType)
        .limit(1)
        .get();

      if (activitySnap.empty) {
        console.log(`SystemActivity with name '${activityType}' not found.`);
        await db.collection("errors").add({
          message: `SystemActivity with name '${activityType}' not found.`,
          billedId: event.params.billId,
          timestamp: admin.firestore.FieldValue.serverTimestamp(),
        });
        await billedRef.update({
          ledgerStatus: "failed",
          ledgerMessage: `SystemActivity '${activityType}' not found.`,
        });
        return;
      }

      const activityData = activitySnap.docs[0].data();
      const { crAccount, crAccountClass, drAccount, drAccountClass, staff,crAccountSubClass,drAccountSubClass } = activityData;

      // 3. Batch ledger entries
      const batch = db.batch();

      studentsSnap.forEach((studentDoc) => {
        const student = studentDoc.data();
        const transactionId = uuidv4();

        // Use billId + studentId for ledger doc ID
              const note = `Being ${feeName} billed  for ${term} Term`;

        const ledgerId = `${event.params.billId}_${studentDoc.id}`;
        const ledgerRef = db.collection("ledger").doc(ledgerId);
        const status=true;
        batch.set(ledgerRef, {
          transactionId,
          studentId: studentDoc.id,
          studentName: student.name || null,
          schoolId,
          activityType,
          feeName,
          term,
          note,
          level,
          staff,
          status,
          yeargroup,
          amount: String(amount), // ensure stored as string
          billedId: event.params.billId,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
          accounts: {
            debit: {
              account: drAccount ?? null,
              accountClass: drAccountClass ?? null,
              value: String(amount), // string
              subClass:drAccountSubClass??null
            },
            credit: {
              account: crAccount ?? null,
              accountClass: crAccountClass ?? null,
              value: String(amount), // string
              subClass:crAccountSubClass??null
            },
          },
        });
      });

      await batch.commit();

      // Update billed document with success
      await billedRef.update({
        ledgerStatus: "success",
        ledgerMessage: `Ledger created for ${studentsSnap.size} students.`,
      });

      console.log(
        `Ledger created for ${studentsSnap.size} students under ${activityType}.`
      );
    } catch (error) {
      console.error("Error creating ledger entries:", error);
      await snapshot.ref.update({
        ledgerStatus: "failed",
        ledgerMessage: `Error: ${error.message}`,
      });
    }
  }
);



export const updateReportsOnLedger = onDocumentCreated(
  "ledger/{ledgerId}",
  async (event) => {
    const snapshot = event.data;
    if (!snapshot) return;

    const ledger = snapshot.data();
    if (!ledger) return;

    const { schoolId, term, accounts, activityType } = ledger;

    try {
      // === 1. Update Trial Balance ===
      const trialBalanceRef = db
        .collection("trialBalance")
        .doc(`${schoolId}_${term}`);

      await db.runTransaction(async (t) => {
        const trialDoc = await t.get(trialBalanceRef);
        let trialData = trialDoc.exists ? trialDoc.data() : { accounts: {} };

        // Debit account
        if (accounts.debit?.account) {
          const acc = accounts.debit.account;
          const value = parseFloat(accounts.debit.value || "0");
          if (!trialData.accounts[acc]) {
            trialData.accounts[acc] = { debit: 0, credit: 0 };
          }
          trialData.accounts[acc].debit += value;
        }

        // Credit account
        if (accounts.credit?.account) {
          const acc = accounts.credit.account;
          const value = parseFloat(accounts.credit.value || "0");
          if (!trialData.accounts[acc]) {
            trialData.accounts[acc] = { debit: 0, credit: 0 };
          }
          trialData.accounts[acc].credit += value;
        }

        trialData.updatedAt = admin.firestore.FieldValue.serverTimestamp();
        t.set(trialBalanceRef, trialData);
      });

      // === 2. Update Income & Expenditure ===
      const incExpRef = db
        .collection("incomeExpenditure")
        .doc(`${schoolId}_${term}`);

      await db.runTransaction(async (t) => {
        const incDoc = await t.get(incExpRef);
        let incData = incDoc.exists
          ? incDoc.data()
          : { income: 0, expenditure: 0, breakdown: {} };

        // Check debit side → usually Expenditure
        if (accounts.debit?.accountClass === "Expenditure") {
          const value = parseFloat(accounts.debit.value || "0");
          incData.expenditure += value;
          incData.breakdown[accounts.debit.account] =
            (incData.breakdown[accounts.debit.account] || 0) + value;
        }

        // Check credit side → usually Income
        if (accounts.credit?.accountClass === "Income") {
          const value = parseFloat(accounts.credit.value || "0");
          incData.income += value;
          incData.breakdown[accounts.credit.account] =
            (incData.breakdown[accounts.credit.account] || 0) + value;
        }

        incData.updatedAt = admin.firestore.FieldValue.serverTimestamp();
        t.set(incExpRef, incData);
      });

      console.log(
        `Reports updated for school ${schoolId}, term ${term}, activity ${activityType}`
      );
    } catch (error) {
      console.error("Error updating reports:", error);
      await db.collection("errors").add({
        type: "reporting",
        message: error.message,
        ledgerId: event.params.ledgerId,
        schoolId,
        term,
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
      });
    }
  }
);
import { onRequest } from "firebase-functions/v2/https";

export const sendPushNotificationHttp = onRequest(async (req, res) => {
  const { token, title, body, data } = req.body;
  if (!token || !title || !body) {
    return res.status(400).json({ error: "token, title, and body are required" });
  }
  const message = {
    token,
    notification: { title, body },
    data: data || {},
  };
  try {
    const response = await admin.messaging().send(message);
    return res.json({ success: true, response });
  } catch (error) {
    console.error("Error sending push notification:", error);
    return res.status(500).json({ error: error.message || "Failed to send notification" });
  }
});
