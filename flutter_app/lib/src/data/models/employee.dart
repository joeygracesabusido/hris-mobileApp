// src/data/models/employee.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'employee.freezed.dart';
part 'employee.g.dart';

@freezed
class Employee with _$Employee {
  const factory Employee({
    required String id,
    required String employeeNumber,
    required String fullName,
    required String email,
    required String employeeId,
    required String position,
    required String department,
    required String payType,
    required double basicSalary,
    required double dailyRate,
    required String payrollFrequency,
    required String hireDate,
    required bool isActive,
    required String employeeStatus,
    String? regularizationDate,
    String? managerId,
    required String tin,
    required String sssNo,
    required String philhealthNo,
    required String pagibigNo,
    required String bankName,
    required String bankAccountNo,
  }) = _Employee;

  factory Employee.fromJson(Map<String, dynamic> json) => _$EmployeeFromJson(json);
}
