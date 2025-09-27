import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/payroll_provider.dart';

class PayrollScreen extends StatelessWidget {
  const PayrollScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Staff Payroll')),
      body: Column(
        children: [
          Padding(padding: const EdgeInsets.all(12.0), child: PayrollForm()),
          const Divider(),
          Expanded(
            child: Consumer<PayrollProvider>(
              builder: (context, payrollProvider, _) {
                final records = payrollProvider.payrollRecords;
                if (records.isEmpty) {
                  return const Center(child: Text('No payroll records found.'));
                }
                return ListView.builder(
                  itemCount: records.length,
                  itemBuilder: (context, index) {
                    final record = records[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        title: Text(record.staffName),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Salary: ₵${record.salary.toStringAsFixed(2)}',
                            ),
                            Text('SSNIT: ₵${record.ssnit.toStringAsFixed(2)}'),
                            Text('Tax: ₵${record.tax.toStringAsFixed(2)}'),
                            Text(
                              'Total Deductions: ₵${record.totalDeductions.toStringAsFixed(2)}',
                            ),
                            Text(
                              'Bonuses: ₵${record.bonuses.toStringAsFixed(2)}',
                            ),
                            Text(
                              'Net Pay: ₵${record.netPay.toStringAsFixed(2)}',
                            ),
                            Text(
                              'Pay Date: ${record.payDate.toLocal().toString().split(' ')[0]}',
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.receipt_long),
                          tooltip: 'View Payslip',
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (_) => PayslipDialog(record: record),
                            );
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class PayrollForm extends StatefulWidget {
  @override
  State<PayrollForm> createState() => _PayrollFormState();
}

class _PayrollFormState extends State<PayrollForm> {
  final _formKey = GlobalKey<FormState>();
  final _staffIdController = TextEditingController();
  final _staffNameController = TextEditingController();
  final _salaryController = TextEditingController();
  final _deductionsController = TextEditingController();
  final _bonusesController = TextEditingController();
  DateTime? _payDate;

  @override
  void dispose() {
    _staffIdController.dispose();
    _staffNameController.dispose();
    _salaryController.dispose();
    _deductionsController.dispose();
    _bonusesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _staffIdController,
                  decoration: const InputDecoration(labelText: 'Staff ID'),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Enter staff ID' : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _staffNameController,
                  decoration: const InputDecoration(labelText: 'Staff Name'),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Enter staff name' : null,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _salaryController,
                  decoration: const InputDecoration(labelText: 'Salary'),
                  keyboardType: TextInputType.number,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Enter salary' : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _deductionsController,
                  decoration: const InputDecoration(labelText: 'Deductions'),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _bonusesController,
                  decoration: const InputDecoration(labelText: 'Bonuses'),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: InputDatePickerFormField(
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2100),
                  initialDate: DateTime.now(),
                  fieldLabelText: 'Pay Date',
                  onDateSubmitted: (date) => _payDate = date,
                  onDateSaved: (date) => _payDate = date,
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    _formKey.currentState?.save();
                    final provider = Provider.of<PayrollProvider>(
                      context,
                      listen: false,
                    );
                    provider.addPayrollRecord(
                      PayrollRecord(
                        staffId: _staffIdController.text.trim(),
                        staffName: _staffNameController.text.trim(),
                        salary: double.tryParse(_salaryController.text) ?? 0.0,
                        bonuses:
                            double.tryParse(_bonusesController.text) ?? 0.0,
                        payDate: _payDate ?? DateTime.now(),
                      ),
                    );
                    _staffIdController.clear();
                    _staffNameController.clear();
                    _salaryController.clear();
                    _deductionsController.clear();
                    _bonusesController.clear();
                    setState(() {
                      _payDate = null;
                    });
                  }
                },
                child: const Text('Add Payroll'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class PayslipDialog extends StatelessWidget {
  final PayrollRecord record;
  const PayslipDialog({Key? key, required this.record}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Payslip - ${record.staffName}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Staff ID: ${record.staffId}'),
          Text('Salary: ₵${record.salary.toStringAsFixed(2)}'),
          Text('SSNIT: ₵${record.ssnit.toStringAsFixed(2)}'),
          Text('Tax: ₵${record.tax.toStringAsFixed(2)}'),
          Text(
            'Total Deductions: ₵${record.totalDeductions.toStringAsFixed(2)}',
          ),
          Text('Bonuses: ₵${record.bonuses.toStringAsFixed(2)}'),
          const Divider(),
          Text(
            'Net Pay: ₵${record.netPay.toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            'Pay Date: ${record.payDate.toLocal().toString().split(' ')[0]}',
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
