// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'employee.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$EmployeeImpl _$$EmployeeImplFromJson(Map<String, dynamic> json) =>
    _$EmployeeImpl(
      id: json['id'] as String,
      employeeNumber: json['employeeNumber'] as String,
      fullName: json['fullName'] as String,
      email: json['email'] as String,
      employeeId: json['employeeId'] as String,
      position: json['position'] as String,
      department: json['department'] as String,
      payType: json['payType'] as String,
      basicSalary: (json['basicSalary'] as num).toDouble(),
      dailyRate: (json['dailyRate'] as num).toDouble(),
      payrollFrequency: json['payrollFrequency'] as String,
      hireDate: json['hireDate'] as String,
      isActive: json['isActive'] as bool,
      employeeStatus: json['employeeStatus'] as String,
      regularizationDate: json['regularizationDate'] as String?,
      managerId: json['managerId'] as String?,
      tin: json['tin'] as String,
      sssNo: json['sssNo'] as String,
      philhealthNo: json['philhealthNo'] as String,
      pagibigNo: json['pagibigNo'] as String,
      bankName: json['bankName'] as String,
      bankAccountNo: json['bankAccountNo'] as String,
    );

Map<String, dynamic> _$$EmployeeImplToJson(_$EmployeeImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'employeeNumber': instance.employeeNumber,
      'fullName': instance.fullName,
      'email': instance.email,
      'employeeId': instance.employeeId,
      'position': instance.position,
      'department': instance.department,
      'payType': instance.payType,
      'basicSalary': instance.basicSalary,
      'dailyRate': instance.dailyRate,
      'payrollFrequency': instance.payrollFrequency,
      'hireDate': instance.hireDate,
      'isActive': instance.isActive,
      'employeeStatus': instance.employeeStatus,
      'regularizationDate': instance.regularizationDate,
      'managerId': instance.managerId,
      'tin': instance.tin,
      'sssNo': instance.sssNo,
      'philhealthNo': instance.philhealthNo,
      'pagibigNo': instance.pagibigNo,
      'bankName': instance.bankName,
      'bankAccountNo': instance.bankAccountNo,
    };
