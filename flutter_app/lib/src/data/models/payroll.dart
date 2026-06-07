import 'package:freezed_annotation/freezed_annotation.dart';

part 'payroll.freezed.dart';
part 'payroll.g.dart';

@freezed
class PayrollRecord with _$PayrollRecord {
  const factory PayrollRecord({
    required String id,
    required String employeeId,
    required int month,
    required int year,
    required DateTime periodStart,
    required DateTime periodEnd,
    @Default(0.0) double basicSalary,
    @Default(0.0) double dailyRate,
    @Default(0) int workDays,
    @Default(0) int daysWorked,
    @Default(0.0) double otHours,
    @Default(0.0) double otPay,
    @Default(0.0) double holidayPay,
    @Default(0.0) double grossPay,
    @Default(0.0) double sssEmployee,
    @Default(0.0) double philhealthEmployee,
    @Default(0.0) double pagibigEmployee,
    @Default(0.0) double withholdingTax,
    @Default(0.0) double lateDeduction,
    @Default(0.0) double undertimeDeduction,
    @Default(0.0) double otherDeductions,
    @Default(0.0) double totalDeductions,
    @Default(0.0) double netPay,
    @Default('PROCESSED') String status,
    Map<String, dynamic>? employee,
  }) = _PayrollRecord;

  factory PayrollRecord.fromJson(Map<String, dynamic> json) =>
      _$PayrollRecordFromJson(json);
}
