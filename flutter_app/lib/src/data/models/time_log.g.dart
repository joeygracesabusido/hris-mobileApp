// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'time_log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TimeLogEmployeeImpl _$$TimeLogEmployeeImplFromJson(
        Map<String, dynamic> json) =>
    _$TimeLogEmployeeImpl(
      fullName: json['fullName'] as String,
      employeeId: json['employeeId'] as String,
    );

Map<String, dynamic> _$$TimeLogEmployeeImplToJson(
        _$TimeLogEmployeeImpl instance) =>
    <String, dynamic>{
      'fullName': instance.fullName,
      'employeeId': instance.employeeId,
    };

_$TimeLogShiftImpl _$$TimeLogShiftImplFromJson(Map<String, dynamic> json) =>
    _$TimeLogShiftImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
    );

Map<String, dynamic> _$$TimeLogShiftImplToJson(_$TimeLogShiftImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'startTime': instance.startTime,
      'endTime': instance.endTime,
    };

_$TimeLogImpl _$$TimeLogImplFromJson(Map<String, dynamic> json) =>
    _$TimeLogImpl(
      id: json['id'] as String,
      employeeId: json['employeeId'] as String,
      date: DateTime.parse(json['date'] as String),
      clockIn: json['clockIn'] == null
          ? null
          : DateTime.parse(json['clockIn'] as String),
      clockOut: json['clockOut'] == null
          ? null
          : DateTime.parse(json['clockOut'] as String),
      workHours: (json['workHours'] as num?)?.toDouble() ?? 0.0,
      otHours: (json['otHours'] as num?)?.toDouble() ?? 0.0,
      lateMinutes: (json['lateMinutes'] as num?)?.toInt() ?? 0,
      undertimeMinutes: (json['undertimeMinutes'] as num?)?.toInt() ?? 0,
      notes: json['notes'] as String?,
      isEdited: json['isEdited'] as bool? ?? false,
      editedBy: json['editedBy'] as String?,
      editReason: json['editReason'] as String?,
      employee: json['employee'] == null
          ? null
          : TimeLogEmployee.fromJson(json['employee'] as Map<String, dynamic>),
      shift: json['shift'] == null
          ? null
          : TimeLogShift.fromJson(json['shift'] as Map<String, dynamic>),
      holiday: json['holiday'],
    );

Map<String, dynamic> _$$TimeLogImplToJson(_$TimeLogImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'employeeId': instance.employeeId,
      'date': instance.date.toIso8601String(),
      'clockIn': instance.clockIn?.toIso8601String(),
      'clockOut': instance.clockOut?.toIso8601String(),
      'workHours': instance.workHours,
      'otHours': instance.otHours,
      'lateMinutes': instance.lateMinutes,
      'undertimeMinutes': instance.undertimeMinutes,
      'notes': instance.notes,
      'isEdited': instance.isEdited,
      'editedBy': instance.editedBy,
      'editReason': instance.editReason,
      'employee': instance.employee,
      'shift': instance.shift,
      'holiday': instance.holiday,
    };
