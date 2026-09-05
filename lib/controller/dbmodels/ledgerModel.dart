import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class LedgerTransaction {
  final String documentId;
  final String transactionId;
  final String activityType;
  final DateTime createdAt;
  final String schoolId;
  final String studentId;
  final String studentName;
  final String feeName;
  final String level;
  final String term;
  final String yeargroup;
  final String note;
  final String staff;
  final String billedId;
  final String debitAccount;
  final String debitAccountClass;
  final String debitSubClass;
  final double debitValue;
  final String creditAccount;
  final String creditAccountClass;
  final String creditSubClass;
  final double creditValue;

  LedgerTransaction({
    required this.documentId,
    required this.transactionId,
    required this.activityType,
    required this.createdAt,
    required this.schoolId,
    required this.studentId,
    required this.studentName,
    required this.feeName,
    required this.level,
    required this.term,
    required this.yeargroup,
    required this.note,
    required this.staff,
    required this.billedId,
    required this.debitAccount,
    required this.debitAccountClass,
    required this.debitSubClass,
    required this.debitValue,
    required this.creditAccount,
    required this.creditAccountClass,
    required this.creditSubClass,
    required this.creditValue,
  });

  factory LedgerTransaction.fromFirestore(String documentId, Map<String, dynamic> data) {
    final accounts = Map<String, dynamic>.from(data['accounts'] ?? {});
    final debit = Map<String, dynamic>.from(accounts['debit'] ?? {});
    final credit = Map<String, dynamic>.from(accounts['credit'] ?? {});

    return LedgerTransaction(
      documentId: documentId,
      transactionId: data['transactionId']?.toString() ?? documentId,
      activityType: data['activityType']?.toString() ?? '',
      createdAt: _parseDate(data['createdAt']),
      schoolId: data['schoolId']?.toString() ?? '',
      studentId: data['studentId']?.toString() ?? '',
      studentName: data['studentName']?.toString() ?? '',
      feeName: data['feeName']?.toString() ?? '',
      level: data['level']?.toString() ?? '',
      term: data['term']?.toString() ?? '',
      yeargroup: data['yeargroup']?.toString() ?? '',
      note: data['note']?.toString() ?? '',
      staff: data['staff']?.toString() ?? '',
      billedId: data['billedId']?.toString() ?? '',
      debitAccount: debit['account']?.toString() ?? '',
      debitAccountClass: debit['accountClass']?.toString() ?? '',
      debitSubClass: debit['subClass']?.toString() ?? '',
      debitValue: _toDouble(debit['value']),
      creditAccount: credit['account']?.toString() ?? '',
      creditAccountClass: credit['accountClass']?.toString() ?? '',
      creditSubClass: credit['subClass']?.toString() ?? '',
      creditValue: _toDouble(credit['value']),
    );
  }

  static DateTime _parseDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? DateTime(2000);
    return DateTime(2000);
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString().replaceAll(',', '').trim()) ?? 0;
  }

  double accountDebit(String account) => debitAccount == account ? debitValue : 0;
  double accountCredit(String account) => creditAccount == account ? creditValue : 0;
}

class LedgerAccountSummary {
  final String account;
  final String accountClass;
  final String subClass;
  double openingDebit;
  double openingCredit;
  double debit;
  double credit;
  final List<LedgerTransaction> transactions;

  LedgerAccountSummary({
    required this.account,
    required this.accountClass,
    required this.subClass,
    this.openingDebit = 0,
    this.openingCredit = 0,
    this.debit = 0,
    this.credit = 0,
    List<LedgerTransaction>? transactions,
  }) : transactions = transactions ?? [];

  double get openingBalance {
    if (isDebitNormal) return openingDebit - openingCredit;
    return openingCredit - openingDebit;
  }

  double get closingBalance {
    if (isDebitNormal) return openingBalance + debit - credit;
    return openingBalance + credit - debit;
  }

  bool get isDebitNormal {
    final normalized = accountClass.trim().toLowerCase();
    return normalized == 'assets' || normalized == 'asset' || normalized == 'expenses' || normalized == 'expense' || normalized == 'cost of sales' || normalized == 'cost of goods sold';
  }
}
