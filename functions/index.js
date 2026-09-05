import { onDocumentUpdated, onDocumentCreated, onDocumentDeleted } from "firebase-functions/v2/firestore";
import { onRequest } from "firebase-functions/v2/https";
import { initializeApp, getApps } from "firebase-admin/app";
import { getFirestore, FieldValue } from "firebase-admin/firestore";
import { getMessaging } from "firebase-admin/messaging";
import { v4 as uuidv4 } from "uuid";
import nodemailer from "nodemailer";

if (getApps().length === 0) {
  initializeApp();
}

const db = getFirestore();

/**
 * Helper to queue notifications (SMS and Email)
 */
async function sendNotification(schoolId, student, type, amount, feeName) {
  try {
    const schoolDoc = await db.collection("schools").doc(schoolId).get();
    const schoolData = schoolDoc.data();
    if (!schoolData) return;

    const { smsSenderId, name: schoolname } = schoolData;
    const studentName = student.name || "Student";
    const phone = student.phone || student.guardiancontact?.[0]; // Fallback to guardian
    const email = student.email;

    let message = "";
    if (type === "payment") {
      message = `Dear ${studentName}, payment of GHS ${amount} for ${feeName} received. Thank you. - ${schoolname}`;
    } else {
      message = `Dear ${studentName}, you have been billed GHS ${amount} for ${feeName}. - ${schoolname}`;
    }

    if (phone) {
      await db.collection("smsQueue").add({
        phone: phone.toString(),
        message,
        senderId: smsSenderId || "KMIS",
        status: "pending",
        createdAt: FieldValue.serverTimestamp()
      });
    }

    if (email) {
      await db.collection("emailQueue").add({
        to: email,
        subject: type === "payment" ? "Payment Received" : "New Billing",
        text: message,
        schoolId,
        status: "pending",
        createdAt: FieldValue.serverTimestamp()
      });
    }
  } catch (err) {
    console.error("Notification queuing failed:", err);
  }
}

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
        createdAt: FieldValue.serverTimestamp(),
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
    const { studentId, schoolId, term, receivedaccount, fees, level, yeargroup, staff, paymentmethod, staffId } = after;
    const prevFees = before?.fees || {};

    try {
      const studentQuery = await db.collection("students").where("schoolId", "==", schoolId).where("studentid", "==", studentId).limit(1).get();
      if (studentQuery.empty) return;
      const studentDoc = studentQuery.docs[0];
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
      let totalAmount = 0;
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
          createdAt: FieldValue.serverTimestamp(),
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
        totalAmount += Number(amount);
      }
      if (ledgerCount > 0) {
        await batch.commit();
        await paymentRef.update({
          ledgerStatus: "success",
          ledgerMessage: `Ledger created for ${ledgerCount} new fee types for student ${studentId}.`,
        });

        // 3. Update Accountant Daily Summary
        const now = new Date();
        const dateOnlyString = now.toISOString().split('T')[0]; // YYYY-MM-DD
        const sId = staffId || (staff || 'Unknown').replace(/\s+/g, '_');
        const summaryId = `${schoolId}_${sId}_${dateOnlyString}`;
        const summaryRef = db.collection("accountantDailySummary").doc(summaryId);

        await summaryRef.set({
          schoolId,
          staffId: sId,
          staffName: staff || 'Unknown Staff',
          date: dateOnlyString,
          totalCollected: FieldValue.increment(totalAmount),
          paymentMethods: {
            [paymentmethod || 'Unknown']: FieldValue.increment(totalAmount)
          },
          lastUpdated: FieldValue.serverTimestamp()
        }, { merge: true });
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
    const { studentId, schoolId, term, receivedaccount, fees, level, yeargroup, staff, paymentmethod, staffId } = paymentData;

    try {
      const studentQuery = await db.collection("students").where("schoolId", "==", schoolId).where("studentid", "==", studentId).limit(1).get();
      if (studentQuery.empty) {
        await paymentRef.update({ ledgerStatus: "failed", ledgerMessage: `Student ${studentId} not found` });
        return;
      }
      const studentDoc = studentQuery.docs[0];
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
      let totalAmount = 0;
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
          createdAt: FieldValue.serverTimestamp(),
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
        totalAmount += Number(amount);

        // Queue individual fee notification
        await sendNotification(schoolId, student, "payment", amount, feeType);
      }

      if (ledgerCount > 0) {
        const studentRef = studentDoc.ref;
        const now = new Date();
        const dateString = now.toISOString();

        // Update student balance and detailed breakdown maps
        batch.set(studentRef, {
          lastPaidDate: dateString,
          accounts: {
            paid: FieldValue.increment(totalAmount),
            balance: FieldValue.increment(-totalAmount)
          },
          accountHistory: {
            academicYears: {
              [yeargroup]: {
                paid: FieldValue.increment(totalAmount),
                balance: FieldValue.increment(-totalAmount)
              }
            },
            levels: {
              [level]: {
                paid: FieldValue.increment(totalAmount),
                balance: FieldValue.increment(-totalAmount)
              }
            },
            terms: {
              [`${yeargroup}_${term}`]: {
                paid: FieldValue.increment(totalAmount),
                balance: FieldValue.increment(-totalAmount)
              }
            }
          }
        }, { merge: true });

        await batch.commit();
        await paymentRef.update({
          ledgerStatus: "success",
          ledgerMessage: `Ledger created for ${ledgerCount} fee types for student ${studentId}. Balance updated by GHS ${totalAmount}.`,
        });

        // 3. Update Accountant Daily Summary
        const dateOnlyString = now.toISOString().split('T')[0]; // YYYY-MM-DD
        const sId = staffId || (staff || 'Unknown').replace(/\s+/g, '_');
        const summaryId = `${schoolId}_${sId}_${dateOnlyString}`;
        const summaryRef = db.collection("accountantDailySummary").doc(summaryId);

        await summaryRef.set({
          schoolId,
          staffId: sId,
          staffName: staff || 'Unknown Staff',
          date: dateOnlyString,
          totalCollected: FieldValue.increment(totalAmount),
          paymentMethods: {
            [paymentmethod || 'Unknown']: FieldValue.increment(totalAmount)
          },
          lastUpdated: FieldValue.serverTimestamp()
        }, { merge: true });

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
      const studentQuery = await db.collection("students").where("schoolId", "==", schoolId).where("studentid", "==", studentId).limit(1).get();
      if (studentQuery.empty) {
        await billRef.update({ ledgerStatus: "failed", ledgerMessage: `Student ${studentId} not found` });
        return;
      }
      const studentDoc = studentQuery.docs[0];
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
        createdAt: FieldValue.serverTimestamp(),
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

      // Update student balance and detailed breakdown maps
      const now = new Date();
      const dateString = now.toISOString();
      await studentDoc.ref.set({
        lastBilledDate: dateString,
        accounts: {
          billed: FieldValue.increment(Number(amount)),
          balance: FieldValue.increment(Number(amount))
        },
        accountHistory: {
          academicYears: {
            [yeargroup]: {
              billed: FieldValue.increment(Number(amount)),
              balance: FieldValue.increment(Number(amount))
            }
          },
          levels: {
            [level]: {
              billed: FieldValue.increment(Number(amount)),
              balance: FieldValue.increment(Number(amount))
            }
          },
          terms: {
            [`${yeargroup}_${term}`]: {
              billed: FieldValue.increment(Number(amount)),
              balance: FieldValue.increment(Number(amount))
            }
          }
        }
      }, { merge: true });

      // Queue notification
      await sendNotification(schoolId, student, "billing", amount, feeName);

      await billRef.update({ ledgerStatus: "success", ledgerMessage: `Ledger created and student balance updated.` });
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
    const { level, yeargroup, schoolId, amount, term, activityType, feeName, excludedStudents, customAmounts } = billedData;

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
      const notificationPromises = [];
      const appliedAmounts = {};

      studentsSnap.forEach((studentDoc) => {
        if (excludedStudents && excludedStudents.includes(studentDoc.id)) return;

        const student = studentDoc.data();
        let billedAmount = Number(amount);

        // Use custom amount if provided
        if (customAmounts && customAmounts[studentDoc.id]) {
          billedAmount = Number(customAmounts[studentDoc.id]);
        }

        if (isNaN(billedAmount) || billedAmount <= 0) return;

        appliedAmounts[studentDoc.id] = billedAmount;

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
          amount: billedAmount,
          billedId: event.params.billId,
          createdAt: FieldValue.serverTimestamp(),
          accounts: {
            debit: {
              account: drAccount ?? null,
              accountClass: drAccountClass ?? null,
              value: billedAmount,
              subClass: drAccountSubClass ?? null
            },
            credit: {
              account: crAccount ?? null,
              accountClass: crAccountClass ?? null,
              value: billedAmount,
              subClass: crAccountSubClass ?? null
            },
          },
        });

        // Update student balance and detailed breakdown maps
        const now = new Date();
        const dateString = now.toISOString();
        batch.set(studentDoc.ref, {
          lastBilledDate: dateString,
          accounts: {
            billed: FieldValue.increment(billedAmount),
            balance: FieldValue.increment(billedAmount)
          },
          accountHistory: {
            academicYears: {
              [yeargroup]: {
                billed: FieldValue.increment(billedAmount),
                balance: FieldValue.increment(billedAmount)
              }
            },
            levels: {
              [level]: {
                billed: FieldValue.increment(billedAmount),
                balance: FieldValue.increment(billedAmount)
              }
            },
            terms: {
              [`${yeargroup}_${term}`]: {
                billed: FieldValue.increment(billedAmount),
                balance: FieldValue.increment(billedAmount)
              }
            }
          }
        }, { merge: true });

        // Queue notification
        notificationPromises.push(sendNotification(schoolId, student, "billing", billedAmount, feeName));
      });

      // Store what was actually applied for correct deletion later
      batch.update(billedRef, { appliedAmounts: appliedAmounts });

      await batch.commit();
      await Promise.all(notificationPromises);
      await billedRef.update({ ledgerStatus: "success", ledgerMessage: `Ledger created and balances updated for ${Object.keys(appliedAmounts).length} students.` });
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
      const increment = FieldValue.increment;
      const serverTimestamp = FieldValue.serverTimestamp();

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
        timestamp: FieldValue.serverTimestamp(),
      });
    }
  }
);

export const sendPushNotificationHttp = onRequest(async (req, res) => {
  const { token, title, body, data } = req.body;
  if (!token || !title || !body) return res.status(400).json({ error: "Required fields missing" });

  const message = { token, notification: { title, body }, data: data || {} };
  try {
    const response = await getMessaging().send(message);
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
            lastUpdated: FieldValue.serverTimestamp(),
            lastSaleData: {
              salesId: event.params.salesId,
              qty: Math.abs(qty),
              costPrice: costPrice || 0,
              timestamp: FieldValue.serverTimestamp()
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
            createdAt: FieldValue.serverTimestamp(),
            lastUpdated: FieldValue.serverTimestamp(),
            lastSaleData: {
              salesId: event.params.salesId,
              qty: Math.abs(qty),
              costPrice: costPrice || 0,
              timestamp: FieldValue.serverTimestamp()
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
            lastUpdated: FieldValue.serverTimestamp(),
            lastStockingData: {
              stockingId: event.params.stockingId,
              qty: Math.abs(qty),
              costPrice: costPrice || 0,
              timestamp: FieldValue.serverTimestamp()
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
            createdAt: FieldValue.serverTimestamp(),
            lastUpdated: FieldValue.serverTimestamp(),
            lastStockingData: {
              stockingId: event.params.stockingId,
              qty: Math.abs(qty),
              costPrice: costPrice || 0,
              timestamp: FieldValue.serverTimestamp()
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
            lastUpdated: FieldValue.serverTimestamp(),
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
            lastUpdated: FieldValue.serverTimestamp(),
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
            lastUpdated: FieldValue.serverTimestamp(),
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
            lastUpdated: FieldValue.serverTimestamp(),
          });
        }
      }
      await batch.commit();
    } catch (error) {
      console.error("Error in updateStockStatementOnStockingDelete:", error);
    }
  }
);

// Delete Triggers for Student Balance

export const updateStudentBalanceOnFeePaymentDelete = onDocumentDeleted(
  "feepayment/{paymentId}",
  async (event) => {
    const deletedData = event.data.data();
    if (!deletedData) return;
    const { studentId, schoolId, fees, staffId, staff, paymentmethod } = deletedData;
    if (!studentId || !schoolId || !fees) return;

    try {
      const studentQuery = await db.collection("students").where("schoolId", "==", schoolId).where("studentid", "==", studentId).limit(1).get();
      if (studentQuery.empty) return;
      const studentDoc = studentQuery.docs[0];

      let totalAmount = 0;
      for (const amount of Object.values(fees)) {
        if (typeof amount === "number") totalAmount += amount;
      }

      if (totalAmount > 0) {
        await studentDoc.ref.set({
          accounts: {
            paid: FieldValue.increment(-totalAmount),
            balance: FieldValue.increment(totalAmount)
          },
          accountHistory: {
            academicYears: {
              [deletedData.yeargroup]: {
                paid: FieldValue.increment(-totalAmount),
                balance: FieldValue.increment(totalAmount)
              }
            },
            levels: {
              [deletedData.level]: {
                paid: FieldValue.increment(-totalAmount),
                balance: FieldValue.increment(totalAmount)
              }
            },
            terms: {
              [`${deletedData.yeargroup}_${deletedData.term}`]: {
                paid: FieldValue.increment(-totalAmount),
                balance: FieldValue.increment(totalAmount)
              }
            }
          }
        }, { merge: true });

        // Reverse Accountant Daily Summary
        const dateCreated = deletedData.dateCreated;
        const date = (dateCreated && typeof dateCreated.toDate === 'function') ? dateCreated.toDate() : new Date();
        const dateString = date.toISOString().split('T')[0];
        const sId = deletedData.staffId || (deletedData.staff || 'Unknown').replace(/\s+/g, '_');
        const summaryId = `${schoolId}_${sId}_${dateString}`;

        await db.collection("accountantDailySummary").doc(summaryId).set({
          totalCollected: FieldValue.increment(-totalAmount),
          paymentMethods: {
            [paymentmethod || 'Unknown']: FieldValue.increment(-totalAmount)
          },
          lastUpdated: FieldValue.serverTimestamp()
        }, { merge: true });

        console.log(`Decreased paid amount for student ${studentId} and reversed daily summary.`);
      }
    } catch (error) {
      console.error("Error in updateStudentBalanceOnFeePaymentDelete:", error);
    }
  }
);

export const updateStudentBalanceOnSingleBillingDelete = onDocumentDeleted(
  "singlebilled/{singleBillId}",
  async (event) => {
    const deletedData = event.data.data();
    if (!deletedData) return;
    const { studentId, schoolId, amount } = deletedData;
    if (!studentId || !schoolId || !amount) return;

    try {
      const studentQuery = await db.collection("students").where("schoolId", "==", schoolId).where("studentid", "==", studentId).limit(1).get();
      if (studentQuery.empty) return;
      const studentDoc = studentQuery.docs[0];

      const numAmount = Number(amount);
      if (numAmount > 0) {
        await studentDoc.ref.set({
          accounts: {
            billed: FieldValue.increment(-numAmount),
            balance: FieldValue.increment(-numAmount)
          },
          accountHistory: {
            academicYears: {
              [deletedData.yeargroup]: {
                billed: FieldValue.increment(-numAmount),
                balance: FieldValue.increment(-numAmount)
              }
            },
            levels: {
              [deletedData.level]: {
                billed: FieldValue.increment(-numAmount),
                balance: FieldValue.increment(-numAmount)
              }
            },
            terms: {
              [`${deletedData.yeargroup}_${deletedData.term}`]: {
                billed: FieldValue.increment(-numAmount),
                balance: FieldValue.increment(-numAmount)
              }
            }
          }
        }, { merge: true });
        console.log(`Decreased billed amount for student ${studentId} by ${numAmount} due to billing deletion.`);
      }
    } catch (error) {
      console.error("Error in updateStudentBalanceOnSingleBillingDelete:", error);
    }
  }
);

export const updateStudentBalanceOnBillingDelete = onDocumentDeleted(
  "billed/{billId}",
  async (event) => {
    const deletedData = event.data.data();
    if (!deletedData) return;
    const { appliedAmounts, schoolId } = deletedData;

    // Fallback to old behavior if appliedAmounts doesn't exist
    if (!appliedAmounts) {
      const { level, yeargroup, amount } = deletedData;
      if (!level || !yeargroup || !schoolId || !amount) return;

      try {
        const numAmount = Number(amount);
        const studentsSnap = await db.collection("students")
          .where("level", "==", level)
          .where("yeargroup", "==", yeargroup)
          .where("schoolId", "==", schoolId)
          .get();

        if (studentsSnap.empty) return;

        const batch = db.batch();
        studentsSnap.forEach((doc) => {
          batch.set(doc.ref, {
            accounts: {
              billed: FieldValue.increment(-numAmount),
              balance: FieldValue.increment(-numAmount)
            },
            accountHistory: {
              academicYears: {
                [yeargroup]: {
                  billed: FieldValue.increment(-numAmount),
                  balance: FieldValue.increment(-numAmount)
                }
              },
              levels: {
                [level]: {
                  billed: FieldValue.increment(-numAmount),
                  balance: FieldValue.increment(-numAmount)
                }
              },
              terms: {
                [`${yeargroup}_${deletedData.term}`]: {
                  billed: FieldValue.increment(-numAmount),
                  balance: FieldValue.increment(-numAmount)
                }
              }
            }
          }, { merge: true });
        });

        await batch.commit();
        console.log(`Decreased billed amount for ${studentsSnap.size} students by ${numAmount} (fallback mode).`);
      } catch (error) {
        console.error("Error in updateStudentBalanceOnBillingDelete (fallback):", error);
      }
      return;
    }

    try {
      const batch = db.batch();
      let count = 0;

      for (const [studentDocId, billedAmount] of Object.entries(appliedAmounts)) {
        const studentRef = db.collection("students").doc(studentDocId);

        const updateObj = {
          accounts: {
            billed: FieldValue.increment(-billedAmount),
            balance: FieldValue.increment(-billedAmount)
          },
          accountHistory: {
            academicYears: {
              [deletedData.yeargroup]: {
                billed: FieldValue.increment(-billedAmount),
                balance: FieldValue.increment(-billedAmount)
              }
            },
            levels: {
              [deletedData.level]: {
                billed: FieldValue.increment(-billedAmount),
                balance: FieldValue.increment(-billedAmount)
              }
            },
            terms: {
              [`${deletedData.yeargroup}_${deletedData.term}`]: {
                billed: FieldValue.increment(-billedAmount),
                balance: FieldValue.increment(-billedAmount)
              }
            }
          }
        };

        batch.set(studentRef, updateObj, { merge: true });
        count++;
      }

      await batch.commit();
      console.log(`Reversed billing for ${count} students using appliedAmounts.`);
    } catch (error) {
      console.error("Error in updateStudentBalanceOnBillingDelete:", error);
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
          await ref.update({ totalSoldQty: (d.totalSoldQty || 0) + Math.abs(qty), balance: (d.totalStockQty || 0) - ((d.totalSoldQty || 0) + Math.abs(qty)), lastUpdated: FieldValue.serverTimestamp() });
        } else {
          await ref.set({ barcode, itemName: name || "Unknown Item", totalSoldQty: Math.abs(qty), totalStockQty: 0, balance: -Math.abs(qty), schoolId, createdAt: FieldValue.serverTimestamp(), lastUpdated: FieldValue.serverTimestamp() });
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
          await ref.update({ totalStockQty: n, balance: n - (d.totalSoldQty || 0), lastUpdated: FieldValue.serverTimestamp() });
        } else {
          await ref.set({ barcode, itemName: name || "Unknown Item", totalSoldQty: 0, totalStockQty: Math.abs(qty), balance: Math.abs(qty), schoolId, createdAt: FieldValue.serverTimestamp(), lastUpdated: FieldValue.serverTimestamp() });
        }
      }
    }
    res.json({ success: true, message: "Stock statements regenerated" });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// Queue Processors

/**
 * Process SMS Queue
 */
export const processSmsQueue = onDocumentCreated("smsQueue/{smsId}", async (event) => {
  const smsData = event.data.data();
  const { phone, message, senderId } = smsData;
  const smsRef = event.data.ref;

  try {
    // TODO: Integrate with your SMS provider API here
    // Example using a generic fetch:
    // const apiUrl = `https://sms-provider.com/api?to=${phone}&msg=${encodeURIComponent(message)}&sender=${senderId}`;
    // await fetch(apiUrl);

    console.log(`[SMS Simulation] To: ${phone}, Msg: ${message}, Sender: ${senderId}`);
    await smsRef.update({ status: "sent", sentAt: FieldValue.serverTimestamp() });
  } catch (error) {
    console.error("SMS sending failed:", error);
    await smsRef.update({ status: "failed", error: error.message });
  }
});

/**
 * Process Email Queue using school-specific SMTP
 */
export const processEmailQueue = onDocumentCreated("emailQueue/{emailId}", async (event) => {
  const emailData = event.data.data();
  const { to, subject, text, schoolId } = emailData;
  const emailRef = event.data.ref;

  try {
    const schoolDoc = await db.collection("schools").doc(schoolId).get();
    if (!schoolDoc.exists) throw new Error("School not found");
    const { smtpHost, smtpPort, smtpEmail, smtpPassword, name: schoolName } = schoolDoc.data();

    if (!smtpEmail || !smtpPassword) {
      throw new Error("SMTP configuration missing for school.");
    }

    const transporter = nodemailer.createTransport({
      host: smtpHost || "smtp.gmail.com",
      port: Number(smtpPort) || 465,
      secure: (Number(smtpPort) || 465) === 465,
      auth: {
        user: smtpEmail,
        pass: smtpPassword,
      },
    });

    await transporter.sendMail({
      from: `"${schoolName}" <${smtpEmail}>`,
      to,
      subject,
      text,
    });

    await emailRef.update({ status: "sent", sentAt: FieldValue.serverTimestamp() });
  } catch (error) {
    console.error("Email sending failed:", error);
    await emailRef.update({ status: "failed", error: error.message });
  }
});
