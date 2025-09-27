import 'package:ksoftsms/controller/loginprovider.dart';

class PayrollProvider extends LoginProvider {
  // Example staff payroll data structure
  final List<PayrollRecord> _payrollRecords = [];

  List<PayrollRecord> get payrollRecords => List.unmodifiable(_payrollRecords);

  void addPayrollRecord(PayrollRecord record) {
    _payrollRecords.add(record);
    notifyListeners();
  }

  void updatePayrollRecord(int index, PayrollRecord updatedRecord) {
    if (index >= 0 && index < _payrollRecords.length) {
      _payrollRecords[index] = updatedRecord;
      notifyListeners();
    }
  }

  void removePayrollRecord(int index) {
    if (index >= 0 && index < _payrollRecords.length) {
      _payrollRecords.removeAt(index);
      notifyListeners();
    }
  }

  PayrollRecord? getPayrollRecordByStaffId(String staffId) {
    try {
      return _payrollRecords.firstWhere((record) => record.staffId == staffId);
    } catch (e) {
      return null;
    }
  }
}

class PayrollRecord {
  final String staffId;
  final String staffName;
  final double salary;
  final double bonuses;
  final DateTime payDate;

  // Statutory deductions
  final double ssnitRate; // e.g., 5.5%
  final double taxRate; // e.g., 10%

  PayrollRecord({
    required this.staffId,
    required this.staffName,
    required this.salary,
    this.bonuses = 0.0,
    required this.payDate,
    this.ssnitRate = 0.055,
    this.taxRate = 0.10,
  });

  double get ssnit => salary * ssnitRate;
  double get tax => (salary - ssnit) * taxRate;
  double get totalDeductions => ssnit + tax;
  double get netPay => salary - totalDeductions + bonuses;
}
