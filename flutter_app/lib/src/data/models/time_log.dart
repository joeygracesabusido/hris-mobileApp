import 'package:freezed_annotation/freezed_annotation.dart';

part 'time_log.freezed.dart';
part 'time_log.g.dart';

@freezed
class TimeLogEmployee with _$TimeLogEmployee {
  const factory TimeLogEmployee({
    required String fullName,
    required String employeeId,
  }) = _TimeLogEmployee;

  factory TimeLogEmployee.fromJson(Map<String, dynamic> json) =>
      _$TimeLogEmployeeFromJson(json);
}

@freezed
class TimeLogShift with _$TimeLogShift {
  const factory TimeLogShift({
    required String id,
    required String name,
    required String startTime,
    required String endTime,
  }) = _TimeLogShift;

  factory TimeLogShift.fromJson(Map<String, dynamic> json) =>
      _$TimeLogShiftFromJson(json);
}

@freezed
class TimeLog with _$TimeLog {
  const factory TimeLog({
    required String id,
    required String employeeId,
    required DateTime date,
    DateTime? clockIn,
    DateTime? clockOut,
    @Default(0.0) double workHours,
    @Default(0.0) double otHours,
    @Default(0) int lateMinutes,
    @Default(0) int undertimeMinutes,
    String? notes,
    @Default(false) bool isEdited,
    String? editedBy,
    String? editReason,
    TimeLogEmployee? employee,
    TimeLogShift? shift,
    dynamic holiday,
  }) = _TimeLog;

  factory TimeLog.fromJson(Map<String, dynamic> json) =>
      _$TimeLogFromJson(json);
}
