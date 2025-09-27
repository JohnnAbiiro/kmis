import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/dbmodels/employee_model.dart';
import '../controller/dbmodels/employee_provider.dart';

class EmployeeScreen extends StatelessWidget {
  const EmployeeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Employee Management')),
      body: Column(
        children: [
          Padding(padding: const EdgeInsets.all(12.0), child: EmployeeForm()),
          const Divider(),
          Expanded(
            child: Consumer<EmployeeProvider>(
              builder: (context, provider, _) {
                final employees = provider.employees;
                if (employees.isEmpty) {
                  return const Center(child: Text('No employees found.'));
                }
                return ListView.builder(
                  itemCount: employees.length,
                  itemBuilder: (context, index) {
                    final emp = employees[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        title: Text(emp.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Staff ID: ${emp.staffId}'),
                            Text('Department: ${emp.department}'),
                            Text('Designation: ${emp.designation}'),
                            Text(
                              'Hire Date: ${emp.hireDate.toLocal().toString().split(' ')[0]}',
                            ),
                            Text(
                              'Basic Salary: ₵${emp.basicSalary.toStringAsFixed(2)}',
                            ),
                            Text(
                              'Allowance: ₵${emp.allowance.toStringAsFixed(2)}',
                            ),
                            Text(
                              'Overtime Rate: ₵${emp.overtimeRate.toStringAsFixed(2)}',
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          tooltip: 'Remove',
                          onPressed: () => provider.removeEmployee(index),
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

class EmployeeForm extends StatefulWidget {
  @override
  State<EmployeeForm> createState() => _EmployeeFormState();
}

class _EmployeeFormState extends State<EmployeeForm> {
  final _formKey = GlobalKey<FormState>();
  final _staffIdController = TextEditingController();
  final _nameController = TextEditingController();
  final _departmentController = TextEditingController();
  final _designationController = TextEditingController();
  final _basicSalaryController = TextEditingController();
  final _allowanceController = TextEditingController();
  final _overtimeRateController = TextEditingController();
  DateTime? _hireDate;

  @override
  void dispose() {
    _staffIdController.dispose();
    _nameController.dispose();
    _departmentController.dispose();
    _designationController.dispose();
    _basicSalaryController.dispose();
    _allowanceController.dispose();
    _overtimeRateController.dispose();
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
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Enter name' : null,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _departmentController,
                  decoration: const InputDecoration(labelText: 'Department'),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Enter department' : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _designationController,
                  decoration: const InputDecoration(labelText: 'Designation'),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Enter designation' : null,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _basicSalaryController,
                  decoration: const InputDecoration(labelText: 'Basic Salary'),
                  keyboardType: TextInputType.number,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Enter basic salary' : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _allowanceController,
                  decoration: const InputDecoration(labelText: 'Allowance'),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _overtimeRateController,
                  decoration: const InputDecoration(labelText: 'Overtime Rate'),
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
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                  initialDate: DateTime.now(),
                  fieldLabelText: 'Hire Date',
                  onDateSubmitted: (date) => _hireDate = date,
                  onDateSaved: (date) => _hireDate = date,
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    _formKey.currentState?.save();
                    final provider = Provider.of<EmployeeProvider>(
                      context,
                      listen: false,
                    );
                    provider.addEmployee(
                      Employee(
                        staffId: _staffIdController.text.trim(),
                        name: _nameController.text.trim(),
                        department: _departmentController.text.trim(),
                        designation: _designationController.text.trim(),
                        hireDate: _hireDate ?? DateTime.now(),
                        basicSalary:
                            double.tryParse(_basicSalaryController.text) ?? 0.0,
                        allowance:
                            double.tryParse(_allowanceController.text) ?? 0.0,
                        overtimeRate:
                            double.tryParse(_overtimeRateController.text) ??
                            0.0,
                      ),
                    );
                    _staffIdController.clear();
                    _nameController.clear();
                    _departmentController.clear();
                    _designationController.clear();
                    _basicSalaryController.clear();
                    _allowanceController.clear();
                    _overtimeRateController.clear();
                    setState(() {
                      _hireDate = null;
                    });
                  }
                },
                child: const Text('Add Employee'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
