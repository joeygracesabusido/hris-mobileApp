// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payroll.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PayrollRecordImpl _$$PayrollRecordImplFromJson(Map<String, dynamic> json) =>
    _$PayrollRecordImpl(
      id: json['id'] as String,
      employeeId: json['employeeId'] as String,
      month: (json['month'] as num).toInt(),
      year: (json['year'] as num).toInt(),
      periodStart: DateTime.parse(json['periodStart'] as String),
      periodEnd: DateTime.parse(json['periodEnd'] as String),
      basicSalary: (json['basicSalary'] as num?)?.toDouble() ?? 0.0,
      dailyRate: (json['dailyRate'] as num?)?.toDouble() ?? 0.0,
      workDays: (json['workDays'] as num?)?.toInt() ?? 0,
      daysWorked: (json['daysWorked'] as num?)?.toInt() ?? 0,
      otHours: (json['otHours'] as num?)?.toDouble() ?? 0.0,
      otPay: (json['otPay'] as num?)?.toDouble() ?? 0.0,
      holidayPay: (json['holidayPay'] as num?)?.toDouble() ?? 0.0,
      grossPay: (json['grossPay'] as num?)?.toDouble() ?? 0.0,
      sssEmployee: (json['sssEmployee'] as num?)?.toDouble() ?? 0.0,
      philhealthEmployee:
          (json['philhealthEmployee'] as num?)?.toDouble() ?? 0.0,
      pagibigEmployee: (json['pagibigEmployee'] as num?)?.toDouble() ?? 0.0,
      withholdingTax: (json['withholdingTax'] as num?)?.toDouble() ?? 0.0,
      lateDeduction: (json['lateDeduction'] as num?)?.toDouble() ?? 0.0,
      undertimeDeduction:
          (json['undertimeDeduction'] as num?)?.toDouble() ?? 0.0,
      otherDeductions: (json['otherDeductions'] as num?)?.toDouble() ?? 0.0,
      totalDeductions: (json['totalDeductions'] as num?)?.toDouble() ?? 0.0,
      netPay: (json['netPay'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'PROCESSED',
      employee: json['employee'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$PayrollRecordImplToJson(_$PayrollRecordImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'employeeId': instance.employeeId,
      'month': instance.month,
      'year': instance.year,
      'periodStart': instance.periodStart.toIso8601String(),
      'periodEnd': instance.periodEnd.toIso8601String(),
      'basicSalary': instance.basicSalary,
      'dailyRate': instance.dailyRate,
      'workDays': instance.workDays,
      'daysWorked': instance.daysWorked,
      'otHours': instance.otHours,
      'otPay': instance.otPay,
      'holidayPay': instance.holidayPay,
      'grossPay': instance.grossPay,
      'sssEmployee': instance.sssEmployee,
      'philhealthEmployee': instance.philhealthEmployee,
      'pagibigEmployee': instance.pagibigEmployee,
      'withholdingTax': instance.withholdingTax,
      'lateDeduction': instance.lateDeduction,
      'undertimeDeduction': instance.undertimeDeduction,
      'otherDeductions': instance.otherDeductions,
      'totalDeductions': instance.totalDeductions,
      'netPay': instance.netPay,
      'status': instance.status,
      'employee': instance.employee,
    };
