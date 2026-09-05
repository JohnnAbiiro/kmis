import { onDocumentUpdated } from "firebase-functions/v2/firestore";
import { onDocumentCreated } from "firebase-functions/v2/firestore";
import admin from "firebase-admin";
import { v4 as uuidv4 } from "uuid";
import { onRequest } from "firebase-functions/v2/https";
import { onDocumentDeleted } from "firebase-functions/v2/firestore";

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
        const creditAccDoc = await db.collection("mainaccounts").where("name", "==", creditAccount).limit(1).get();
        if (!creditAccDoc.empty) {
          const creditAccData = creditAccDoc.docs[0].data();
          creditAccountClass = creditAccData.accountType ?? null;
          creditAccountSubClass = creditAccData.subType ?? null;
        }
      }

      const ledgerId = `${event.params.expenseId}_${expenseName}`;
      const ledgerRef = db.collection("ledger").doc(ledgerId);
      await ledgerRef.set({
        transactionId: uuidv4(),
        schoolId,
        term,
        activityType: "expense",
        expenseName,
        amount: Number(fees),
        expenseId: event.params.expenseId,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        accounts: {
          debit:{
            account: expenseName,
            accountClass: debitAccountClass,
            value: Number(fees),
            subClass: debitAccountSubClass,
          },
          credit:{
            account: creditAccount,
            accountClass: creditAccountClass,
            value: Number(fees),
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
      const studentDoc = await db.collection("students").doc(`${schoolId}_${studentId}`).get();
      if (!studentDoc.exists) return;
      const student = studentDoc.data();

      const activitySnap = await db.collection("systemActivity").where("name", "==", "Fee Payment").limit(1).get();
      if (activitySnap.empty) return;
      const activityData = activitySnap.docs[0].data();
      const { crAccount, crAccountClass, crAccountSubClass } = activityData;

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

      const batch = db.batch();
      let ledgerCount = 0;
      for (const [feeType, amount] of Object.entries(fees || {})) {
        if (typeof amount !== "number" || amount <= 0) continue;
        if (feeType in prevFees) continue;

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

export const createLedgerOnFeePayment = onDocumentCreated(
  "feepayment/{paymentId}",
  async (event) => {
    const snapshot = event.data;
    if (!snapshot) return;
    const paymentData = snapshot.data();
    if (!paymentData) return;
    const paymentRef = snapshot.ref;
    const { studentId, schoolId, term, receivedaccount, fees, level, yeargroup } = paymentData;

    try {
      const studentDoc = await db.collection("students").doc(`${schoolId}_${studentId}`).get();
      if (!studentDoc.exists) {
        await paymentRef.update({ ledgerStatus: "failed", ledgerMessage: `Student ${studentId} not found` });
        return;
      }
      const student = studentDoc.data();

      const activitySnap = await db.collection("systemActivity").where("name", "==", "Fee Payment").limit(1).get();
      if (activitySnap.empty) {
        await paymentRef.update({ ledgerStatus: "failed", ledgerMessage: `SystemActivity 'Fee Payment' not found.` });
        return;
      }
      const activityData = activitySnap.docs[0].data();
      const { crAccount, crAccountClass, crAccountSubClass } = activityData;

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

      const batch = db.batch();
      let ledgerCount = 0;
      for (const [feeType, amount] of Object.entries(fees || {})) {
        if (typeof amount !== "number" || amount <= 0) continue;

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
          ledgerMessage: `Ledger created for ${ledgerCount} fee types for student ${studentId}.`,
        });
      } else {
        await paymentRef.update({ ledgerStatus: "failed", ledgerMessage: `No valid fees found.` });
      }
    } catch (error) {
      await paymentRef.update({ ledgerStatus: "failed", ledgerMessage: `Error: ${error.message}` });
    }
  }
);

export const createLedgerOnSingleBilling = onDocumentCreated(
  "singlebilled/{singleBillId}",
  async (event) => {
    const snapshot = event.data;
    if (!snapshot) return;
    const billData = snapshot.data();
    if (!billData) return;
    const billRef = snapshot.ref;
    const { studentId, schoolId, amount, term, activityType, feeName, level, yeargroup, ledgerid } = billData;

    try {
      const studentDoc = await db.collection("students").doc(`${schoolId}_${studentId}`).get();
      if (!studentDoc.exists) {
        await billRef.update({ ledgerStatus: "failed", ledgerMessage: `Student ${studentId} not found` });
        return;
      }
      const student = studentDoc.data();

      const activitySnap = await db.collection("systemActivity").where("name", "==", activityType).limit(1).get();
      if (activitySnap.empty) {
        await billRef.update({ ledgerStatus: "failed", ledgerMessage: `SystemActivity '${activityType}' not found.` });
        return;
      }
      const activityData = activitySnap.docs[0].data();
      const { crAccount, crAccountClass, drAccount, drAccountClass, staff, crAccountSubClass, drAccountSubClass } = activityData;

      const ledgerRef = db.collection("ledger").doc(ledgerid);
      await ledgerRef.set({
        transactionId: uuidv4(),
        studentId,
        studentName: student.name || null,
        schoolId,
        activityType,
        feeName,
        term,
        note: `Being ${feeName} single billed for ${term} Term`,
        status: true,
        level,
        staff,
        yeargroup,
        amount: Number(amount),
        singleBillId: event.params.singleBillId,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        accounts: {
          debit: {
            account: drAccount ?? null,
            accountClass: drAccountClass ?? null,
            value: Number(amount),
            subClass: drAccountSubClass ?? null,
          },
          credit: {
            account: crAccount ?? null,
            accountClass: crAccountClass ?? null,
            value: Number(amount),
            subClass: crAccountSubClass ?? null,
          },
        },
      });

      await billRef.update({ ledgerStatus: "success", ledgerMessage: `Ledger created.` });
    } catch (error) {
      await billRef.update({ ledgerStatus: "failed", ledgerMessage: `Error: ${error.message}` });
    }
  }
);

export const createLedgerOnBilling = onDocumentCreated(
  "billed/{billId}",
  async (event) => {
    const snapshot = event.data;
    if (!snapshot) return;
    const billedData = snapshot.data();
    if (!billedData) return;
    const billedRef = snapshot.ref;
    const { level, yeargroup, schoolId, amount, term, activityType, feeName } = billedData;

    try {
      const studentsSnap = await db.collection("students")
        .where("level", "==", level)
        .where("yeargroup", "==", yeargroup)
        .where("schoolId", "==", schoolId)
        .get();

      if (studentsSnap.empty) {
        await billedRef.update({ ledgerStatus: "failed", ledgerMessage: "No students found." });
        return;
      }

      const activitySnap = await db.collection("systemActivity").where("name", "==", activityType).limit(1).get();
      if (activitySnap.empty) {
        await billedRef.update({ ledgerStatus: "failed", ledgerMessage: `SystemActivity '${activityType}' not found.` });
        return;
      }

      const activityData = activitySnap.docs[0].data();
      const { crAccount, crAccountClass, drAccount, drAccountClass, staff, crAccountSubClass, drAccountSubClass } = activityData;

      const batch = db.batch();
      studentsSnap.forEach((studentDoc) => {
        const student = studentDoc.data();
        const ledgerId = `${event.params.billId}_${studentDoc.id}`;
        const ledgerRef = db.collection("ledger").doc(ledgerId);
        batch.set(ledgerRef, {
          transactionId: uuidv4(),
          studentId: studentDoc.id,
          studentName: student.name || null,
          schoolId,
          activityType,
          feeName,
          term,
          note: `Being ${feeName} billed for ${term} Term`,
          level,
          staff,
          status: true,
          yeargroup,
          amount: Number(amount),
          billedId: event.params.billId,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
          accounts: {
            debit: {
              account: drAccount ?? null,
              accountClass: drAccountClass ?? null,
              value: Number(amount),
              subClass: drAccountSubClass ?? null
            },
            credit: {
              account: crAccount ?? null,
              accountClass: crAccountClass ?? null,
              value: Number(amount),
              subClass: crAccountSubClass ?? null
            },
          },
        });
      });

      await batch.commit();
      await billedRef.update({ ledgerStatus: "success", ledgerMessage: `Ledger created for ${studentsSnap.size} students.` });
    } catch (error) {
      await billedRef.update({ ledgerStatus: "failed", ledgerMessage: `Error: ${error.message}` });
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

    const { schoolId, term, accounts, activityType, createdAt } = ledger;

    if (!schoolId || !term || !accounts) {
      console.log(`Skipping reporting for ledger ${event.params.ledgerId}: Missing required fields.`);
      return;
    }

    try {
      const debitVal = parseFloat(accounts.debit?.value || 0);
      const creditVal = parseFloat(accounts.credit?.value || 0);
      const debitAcc = accounts.debit?.account;
      const creditAcc = accounts.credit?.account;
      const increment = admin.firestore.FieldValue.increment;
      const serverTimestamp = admin.firestore.FieldValue.serverTimestamp();

      // 1. Update Trial Balance
      const trialRef = db.collection("trialBalance").doc(`${schoolId}_${term}`);
      const trialAccounts = {};
      if (debitAcc) {
        trialAccounts[debitAcc] = { debit: increment(debitVal), credit: increment(0) };
      }
      if (creditAcc) {
        if (trialAccounts[creditAcc]) {
          trialAccounts[creditAcc].credit = increment(creditVal);
        } else {
          trialAccounts[creditAcc] = { debit: increment(0), credit: increment(creditVal) };
        }
      }
      await trialRef.set({ updatedAt: serverTimestamp, accounts: trialAccounts }, { merge: true });

      // 2. Update Income & Expenditure
      if (accounts.debit?.accountClass === "Expenditure" || accounts.credit?.accountClass === "Income") {
        const incExpRef = db.collection("incomeExpenditure").doc(`${schoolId}_${term}`);
        const incExpUpdate = { updatedAt: serverTimestamp, breakdown: {} };

        if (accounts.debit?.accountClass === "Expenditure" && debitAcc) {
          incExpUpdate.expenditure = increment(debitVal);
          incExpUpdate.breakdown[debitAcc] = increment(debitVal);
        }
        if (accounts.credit?.accountClass === "Income" && creditAcc) {
          incExpUpdate.income = increment(creditVal);
          incExpUpdate.breakdown[creditAcc] = increment(creditVal);
        }
        await incExpRef.set(incExpUpdate, { merge: true });
      }

      // 3. Update Daily Ledger Summary
      const ledgerDate = (createdAt && typeof createdAt.toDate === 'function') ? createdAt.toDate() : new Date();
      const dateString = ledgerDate.toISOString().split('T')[0];
      const dailyRef = db.collection("dailyLedgerSummary").doc(`${schoolId}_${dateString}`);

      const dailyAccounts = {};
      if (debitAcc) {
        dailyAccounts[debitAcc] = { debit: increment(debitVal), credit: increment(0) };
      }
      if (creditAcc) {
        if (dailyAccounts[creditAcc]) {
          dailyAccounts[creditAcc].credit = increment(creditVal);
        } else {
          dailyAccounts[creditAcc] = { debit: increment(0), credit: increment(creditVal) };
        }
      }

      await dailyRef.set({
        schoolId,
        date: dateString,
        totalDebit: increment(debitVal),
        totalCredit: increment(creditVal),
        updatedAt: serverTimestamp,
        lastTransactionAt: serverTimestamp,
        accounts: dailyAccounts
      }, { merge: true });

      console.log(`Reports updated for school ${schoolId}, ledger ${event.params.ledgerId}`);
    } catch (error) {
      console.error("Error in updateReportsOnLedger:", error);
      await db.collection("errors").add({
        type: "reporting",
        message: error.message,
        ledgerId: event.params.ledgerId,
        schoolId,
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
      });
    }
  }
);

export const sendPushNotificationHttp = onRequest(async (req, res) => {
  const { token, title, body, data } = req.body;
  if (!token || !title || !body) return res.status(400).json({ error: "Required fields missing" });

  const message = { token, notification: { title, body }, data: data || {} };
  try {
    const response = await admin.messaging().send(message);
    return res.json({ success: true, response });
  } catch (error) {
    return res.status(500).json({ error: error.message });
  }
});

// Stock Statement Triggers

export const updateStockStatementOnSales = onDocumentCreated(
  "sales/{salesId}",
  async (event) => {
    const snapshot = event.data;
    if (!snapshot) return;
    const salesData = snapshot.data();
    if (!salesData) return;
    const { items, schoolId } = salesData;
    
    try {
      const batch = db.batch();
      for (const item of items || []) {
        const { barcode, name, costPrice, qty } = item;
        if (!barcode || !qty || qty <= 0) continue;
        const stockStatementRef = db.collection("stockStatement").doc(`${barcode}_${schoolId}`);
        const existingDoc = await stockStatementRef.get();
        
        if (existingDoc.exists) {
          const currentData = existingDoc.data();
          const newTotalSoldQty = (currentData.totalSoldQty || 0) + Math.abs(qty);
          const newBalance = (currentData.totalStockQty || 0) - newTotalSoldQty;
          batch.update(stockStatementRef, {
            totalSoldQty: newTotalSoldQty,
            balance: newBalance,
            lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
            lastSaleData: {
              salesId: event.params.salesId,
              qty: Math.abs(qty),
              costPrice: costPrice || 0,
              timestamp: admin.firestore.FieldValue.serverTimestamp()
            }
          });
        } else {
          batch.set(stockStatementRef, {
            barcode,
            itemName: name || "Unknown Item",
            totalSoldQty: Math.abs(qty),
            totalStockQty: 0,
            balance: -Math.abs(qty),
            schoolId: schoolId || null,
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
            lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
            lastSaleData: {
              salesId: event.params.salesId,
              qty: Math.abs(qty),
              costPrice: costPrice || 0,
              timestamp: admin.firestore.FieldValue.serverTimestamp()
            }
          });
        }
      }
      await batch.commit();
    } catch (error) {
      console.error("Error in updateStockStatementOnSales:", error);
    }
  }
);

export const updateStockStatementOnStocking = onDocumentCreated(
  "stock/{stockingId}",
  async (event) => {
    const snapshot = event.data;
    if (!snapshot) return;
    const stockingData = snapshot.data();
    if (!stockingData) return;
    const { items, schoolId } = stockingData;
    
    try {
      const batch = db.batch();
      for (const item of items || []) {
        const { barcode, name, costPrice, qty } = item;
        if (!barcode || !qty || qty <= 0) continue;
        const stockStatementRef = db.collection("stockStatement").doc(`${barcode}_${schoolId}`);
        const existingDoc = await stockStatementRef.get();
        
        if (existingDoc.exists) {
          const currentData = existingDoc.data();
          const newTotalStockQty = (currentData.totalStockQty || 0) + Math.abs(qty);
          const newBalance = newTotalStockQty - (currentData.totalSoldQty || 0);
          batch.update(stockStatementRef, {
            totalStockQty: newTotalStockQty,
            balance: newBalance,
            lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
            lastStockingData: {
              stockingId: event.params.stockingId,
              qty: Math.abs(qty),
              costPrice: costPrice || 0,
              timestamp: admin.firestore.FieldValue.serverTimestamp()
            }
          });
        } else {
          batch.set(stockStatementRef, {
            barcode,
            itemName: name || "Unknown Item",
            totalSoldQty: 0,
            totalStockQty: Math.abs(qty),
            balance: Math.abs(qty),
            schoolId: schoolId || null,
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
            lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
            lastStockingData: {
              stockingId: event.params.stockingId,
              qty: Math.abs(qty),
              costPrice: costPrice || 0,
              timestamp: admin.firestore.FieldValue.serverTimestamp()
            }
          });
        }
      }
      await batch.commit();
    } catch (error) {
      console.error("Error in updateStockStatementOnStocking:", error);
    }
  }
);

export const updateStockStatementOnSalesUpdate = onDocumentUpdated(
  "sales/{salesId}",
  async (event) => {
    const beforeData = event.data.before.data();
    const afterData = event.data.after.data();
    if (!beforeData || !afterData) return;
    const beforeItems = beforeData.items || [];
    const afterItems = afterData.items || [];
    const { schoolId } = afterData;
    if (JSON.stringify(beforeItems) === JSON.stringify(afterItems)) return;

    try {
      const batch = db.batch();
      const quantityDiffs = new Map();
      beforeItems.forEach(item => {
        if (item.barcode && item.qty) quantityDiffs.set(item.barcode, -(Math.abs(item.qty) || 0));
      });
      afterItems.forEach(item => {
        if (item.barcode && item.qty) {
          const currentDiff = quantityDiffs.get(item.barcode) || 0;
          quantityDiffs.set(item.barcode, currentDiff + (Math.abs(item.qty) || 0));
        }
      });
      for (const [barcode, qtyDiff] of quantityDiffs) {
        if (qtyDiff === 0) continue;
        const stockStatementRef = db.collection("stockStatement").doc(`${barcode}_${schoolId}`);
        const existingDoc = await stockStatementRef.get();
        if (existingDoc.exists) {
          const currentData = existingDoc.data();
          const newTotalSoldQty = Math.max(0, (currentData.totalSoldQty || 0) + qtyDiff);
          const newBalance = (currentData.totalStockQty || 0) - newTotalSoldQty;
          batch.update(stockStatementRef, {
            totalSoldQty: newTotalSoldQty,
            balance: newBalance,
            lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
          });
        }
      }
      await batch.commit();
    } catch (error) {
      console.error("Error in updateStockStatementOnSalesUpdate:", error);
    }
  }
);

export const updateStockStatementOnStockingUpdate = onDocumentUpdated(
  "stock/{stockingId}",
  async (event) => {
    const beforeData = event.data.before.data();
    const afterData = event.data.after.data();
    if (!beforeData || !afterData) return;
    const beforeItems = beforeData.items || [];
    const afterItems = afterData.items || [];
    const { schoolId } = afterData;
    if (JSON.stringify(beforeItems) === JSON.stringify(afterItems)) return;

    try {
      const batch = db.batch();
      const quantityDiffs = new Map();
      beforeItems.forEach(item => {
        if (item.barcode && item.qty) quantityDiffs.set(item.barcode, -(Math.abs(item.qty) || 0));
      });
      afterItems.forEach(item => {
        if (item.barcode && item.qty) {
          const currentDiff = quantityDiffs.get(item.barcode) || 0;
          quantityDiffs.set(item.barcode, currentDiff + (Math.abs(item.qty) || 0));
        }
      });
      for (const [barcode, qtyDiff] of quantityDiffs) {
        if (qtyDiff === 0) continue;
        const stockStatementRef = db.collection("stockStatement").doc(`${barcode}_${schoolId}`);
        const existingDoc = await stockStatementRef.get();
        if (existingDoc.exists) {
          const currentData = existingDoc.data();
          const newTotalStockQty = Math.max(0, (currentData.totalStockQty || 0) + qtyDiff);
          const newBalance = newTotalStockQty - (currentData.totalSoldQty || 0);
          batch.update(stockStatementRef, {
            totalStockQty: newTotalStockQty,
            balance: newBalance,
            lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
          });
        }
      }
      await batch.commit();
    } catch (error) {
      console.error("Error in updateStockStatementOnStockingUpdate:", error);
    }
  }
);

export const updateStockStatementOnSalesDelete = onDocumentDeleted(
  "sales/{salesId}",
  async (event) => {
    const deletedData = event.data.data();
    if (!deletedData) return;
    const { items, schoolId } = deletedData;
    try {
      const batch = db.batch();
      for (const item of items || []) {
        const { barcode, qty } = item;
        if (!barcode || !qty || qty <= 0) continue;
        const stockStatementRef = db.collection("stockStatement").doc(`${barcode}_${schoolId}`);
        const existingDoc = await stockStatementRef.get();
        if (existingDoc.exists) {
          const currentData = existingDoc.data();
          const newTotalSoldQty = Math.max(0, (currentData.totalSoldQty || 0) - Math.abs(qty));
          const newBalance = (currentData.totalStockQty || 0) - newTotalSoldQty;
          batch.update(stockStatementRef, {
            totalSoldQty: newTotalSoldQty,
            balance: newBalance,
            lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
          });
        }
      }
      await batch.commit();
    } catch (error) {
      console.error("Error in updateStockStatementOnSalesDelete:", error);
    }
  }
);

export const updateStockStatementOnStockingDelete = onDocumentDeleted(
  "stock/{stockingId}",
  async (event) => {
    const deletedData = event.data.data();
    if (!deletedData) return;
    const { items, schoolId } = deletedData;
    try {
      const batch = db.batch();
      for (const item of items || []) {
        const { barcode, qty } = item;
        if (!barcode || !qty || qty <= 0) continue;
        const stockStatementRef = db.collection("stockStatement").doc(`${barcode}_${schoolId}`);
        const existingDoc = await stockStatementRef.get();
        if (existingDoc.exists) {
          const currentData = existingDoc.data();
          const newTotalStockQty = Math.max(0, (currentData.totalStockQty || 0) - Math.abs(qty));
          const newBalance = newTotalStockQty - (currentData.totalSoldQty || 0);
          batch.update(stockStatementRef, {
            totalStockQty: newTotalStockQty,
            balance: newBalance,
            lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
          });
        }
      }
      await batch.commit();
    } catch (error) {
      console.error("Error in updateStockStatementOnStockingDelete:", error);
    }
  }
);

export const getStockStatements = onRequest(async (req, res) => {
  try {
    const { barcode, schoolId, includeZeroBalance } = req.query;
    let query = db.collection("stockStatement");
    if (barcode) query = query.where("barcode", "==", barcode);
    if (schoolId) query = query.where("schoolId", "==", schoolId);
    if (!barcode && !schoolId) query = query.orderBy("balance", "desc");
    const snapshot = await query.get();
    let stockStatements = snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data(),
      lastUpdated: doc.data().lastUpdated?.toDate?.() || doc.data().lastUpdated,
      createdAt: doc.data().createdAt?.toDate?.() || doc.data().createdAt
    }));
    if (includeZeroBalance !== 'true') stockStatements = stockStatements.filter(item => item.balance > 0);
    if (barcode || schoolId) stockStatements.sort((a, b) => (b.balance || 0) - (a.balance || 0));
    res.json({ success: true, stockStatements, totalItems: stockStatements.length });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

export const regenerateStockStatements = onRequest(async (req, res) => {
  try {
    const existingSnapshot = await db.collection("stockStatement").get();
    const deleteBatch = db.batch();
    existingSnapshot.docs.forEach(doc => deleteBatch.delete(doc.ref));
    await deleteBatch.commit();

    const salesSnapshot = await db.collection("sales").get();
    for (const salesDoc of salesSnapshot.docs) {
      const { items, schoolId } = salesDoc.data();
      for (const item of items || []) {
        const { barcode, name, qty } = item;
        if (!barcode || !qty || qty <= 0) continue;
        const ref = db.collection("stockStatement").doc(`${barcode}_${schoolId}`);
        const snap = await ref.get();
        if (snap.exists) {
          const d = snap.data();
          await ref.update({ totalSoldQty: (d.totalSoldQty || 0) + Math.abs(qty), balance: (d.totalStockQty || 0) - ((d.totalSoldQty || 0) + Math.abs(qty)), lastUpdated: admin.firestore.FieldValue.serverTimestamp() });
        } else {
          await ref.set({ barcode, itemName: name || "Unknown Item", totalSoldQty: Math.abs(qty), totalStockQty: 0, balance: -Math.abs(qty), schoolId, createdAt: admin.firestore.FieldValue.serverTimestamp(), lastUpdated: admin.firestore.FieldValue.serverTimestamp() });
        }
      }
    }

    const stockingSnapshot = await db.collection("stock").get();
    for (const stockingDoc of stockingSnapshot.docs) {
      const { items, schoolId } = stockingDoc.data();
      for (const item of items || []) {
        const { barcode, name, qty } = item;
        if (!barcode || !qty || qty <= 0) continue;
        const ref = db.collection("stockStatement").doc(`${barcode}_${schoolId}`);
        const snap = await ref.get();
        if (snap.exists) {
          const d = snap.data();
          const n = (d.totalStockQty || 0) + Math.abs(qty);
          await ref.update({ totalStockQty: n, balance: n - (d.totalSoldQty || 0), lastUpdated: admin.firestore.FieldValue.serverTimestamp() });
        } else {
          await ref.set({ barcode, itemName: name || "Unknown Item", totalSoldQty: 0, totalStockQty: Math.abs(qty), balance: Math.abs(qty), schoolId, createdAt: admin.firestore.FieldValue.serverTimestamp(), lastUpdated: admin.firestore.FieldValue.serverTimestamp() });
        }
      }
    }
    res.json({ success: true, message: "Stock statements regenerated" });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});
