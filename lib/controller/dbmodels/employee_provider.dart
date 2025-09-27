import 'package:flutter/material.dart';

import 'employee_model.dart';

class EmployeeProvider extends ChangeNotifier {
  final List<Employee> _employees = [];

  List<Employee> get employees => List.unmodifiable(_employees);

  void addEmployee(Employee employee) {
    _employees.add(employee);
    notifyListeners();
  }

  void updateEmployee(int index, Employee updated) {
    if (index >= 0 && index < _employees.length) {
      _employees[index] = updated;
      notifyListeners();
    }
  }

  void removeEmployee(int index) {
    if (index >= 0 && index < _employees.length) {
      _employees.removeAt(index);
      notifyListeners();
    }
  }
}
