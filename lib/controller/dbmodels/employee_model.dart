class Employee {
  final String staffId;
  final String name;
  final String department;
  final String designation;
  final DateTime hireDate;
  final double basicSalary;
  final double allowance;
  final double overtimeRate;
  // Add more fields as needed (e.g., loans, provident fund, etc.)

  Employee({
    required this.staffId,
    required this.name,
    required this.department,
    required this.designation,
    required this.hireDate,
    required this.basicSalary,
    required this.allowance,
    required this.overtimeRate,
  });
}
