// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'time_log.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

TimeLogEmployee _$TimeLogEmployeeFromJson(Map<String, dynamic> json) {
  return _TimeLogEmployee.fromJson(json);
}

/// @nodoc
mixin _$TimeLogEmployee {
  String get fullName => throw _privateConstructorUsedError;
  String get employeeId => throw _privateConstructorUsedError;

  /// Serializes this TimeLogEmployee to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TimeLogEmployee
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TimeLogEmployeeCopyWith<TimeLogEmployee> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TimeLogEmployeeCopyWith<$Res> {
  factory $TimeLogEmployeeCopyWith(
          TimeLogEmployee value, $Res Function(TimeLogEmployee) then) =
      _$TimeLogEmployeeCopyWithImpl<$Res, TimeLogEmployee>;
  @useResult
  $Res call({String fullName, String employeeId});
}

/// @nodoc
class _$TimeLogEmployeeCopyWithImpl<$Res, $Val extends TimeLogEmployee>
    implements $TimeLogEmployeeCopyWith<$Res> {
  _$TimeLogEmployeeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TimeLogEmployee
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? fullName = null,
    Object? employeeId = null,
  }) {
    return _then(_value.copyWith(
      fullName: null == fullName
          ? _value.fullName
          : fullName // ignore: cast_nullable_to_non_nullable
              as String,
      employeeId: null == employeeId
          ? _value.employeeId
          : employeeId // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TimeLogEmployeeImplCopyWith<$Res>
    implements $TimeLogEmployeeCopyWith<$Res> {
  factory _$$TimeLogEmployeeImplCopyWith(_$TimeLogEmployeeImpl value,
          $Res Function(_$TimeLogEmployeeImpl) then) =
      __$$TimeLogEmployeeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String fullName, String employeeId});
}

/// @nodoc
class __$$TimeLogEmployeeImplCopyWithImpl<$Res>
    extends _$TimeLogEmployeeCopyWithImpl<$Res, _$TimeLogEmployeeImpl>
    implements _$$TimeLogEmployeeImplCopyWith<$Res> {
  __$$TimeLogEmployeeImplCopyWithImpl(
      _$TimeLogEmployeeImpl _value, $Res Function(_$TimeLogEmployeeImpl) _then)
      : super(_value, _then);

  /// Create a copy of TimeLogEmployee
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? fullName = null,
    Object? employeeId = null,
  }) {
    return _then(_$TimeLogEmployeeImpl(
      fullName: null == fullName
          ? _value.fullName
          : fullName // ignore: cast_nullable_to_non_nullable
              as String,
      employeeId: null == employeeId
          ? _value.employeeId
          : employeeId // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TimeLogEmployeeImpl implements _TimeLogEmployee {
  const _$TimeLogEmployeeImpl(
      {required this.fullName, required this.employeeId});

  factory _$TimeLogEmployeeImpl.fromJson(Map<String, dynamic> json) =>
      _$$TimeLogEmployeeImplFromJson(json);

  @override
  final String fullName;
  @override
  final String employeeId;

  @override
  String toString() {
    return 'TimeLogEmployee(fullName: $fullName, employeeId: $employeeId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TimeLogEmployeeImpl &&
            (identical(other.fullName, fullName) ||
                other.fullName == fullName) &&
            (identical(other.employeeId, employeeId) ||
                other.employeeId == employeeId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, fullName, employeeId);

  /// Create a copy of TimeLogEmployee
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TimeLogEmployeeImplCopyWith<_$TimeLogEmployeeImpl> get copyWith =>
      __$$TimeLogEmployeeImplCopyWithImpl<_$TimeLogEmployeeImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TimeLogEmployeeImplToJson(
      this,
    );
  }
}

abstract class _TimeLogEmployee implements TimeLogEmployee {
  const factory _TimeLogEmployee(
      {required final String fullName,
      required final String employeeId}) = _$TimeLogEmployeeImpl;

  factory _TimeLogEmployee.fromJson(Map<String, dynamic> json) =
      _$TimeLogEmployeeImpl.fromJson;

  @override
  String get fullName;
  @override
  String get employeeId;

  /// Create a copy of TimeLogEmployee
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TimeLogEmployeeImplCopyWith<_$TimeLogEmployeeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TimeLogShift _$TimeLogShiftFromJson(Map<String, dynamic> json) {
  return _TimeLogShift.fromJson(json);
}

/// @nodoc
mixin _$TimeLogShift {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get startTime => throw _privateConstructorUsedError;
  String get endTime => throw _privateConstructorUsedError;

  /// Serializes this TimeLogShift to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TimeLogShift
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TimeLogShiftCopyWith<TimeLogShift> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TimeLogShiftCopyWith<$Res> {
  factory $TimeLogShiftCopyWith(
          TimeLogShift value, $Res Function(TimeLogShift) then) =
      _$TimeLogShiftCopyWithImpl<$Res, TimeLogShift>;
  @useResult
  $Res call({String id, String name, String startTime, String endTime});
}

/// @nodoc
class _$TimeLogShiftCopyWithImpl<$Res, $Val extends TimeLogShift>
    implements $TimeLogShiftCopyWith<$Res> {
  _$TimeLogShiftCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TimeLogShift
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? startTime = null,
    Object? endTime = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      startTime: null == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as String,
      endTime: null == endTime
          ? _value.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TimeLogShiftImplCopyWith<$Res>
    implements $TimeLogShiftCopyWith<$Res> {
  factory _$$TimeLogShiftImplCopyWith(
          _$TimeLogShiftImpl value, $Res Function(_$TimeLogShiftImpl) then) =
      __$$TimeLogShiftImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String name, String startTime, String endTime});
}

/// @nodoc
class __$$TimeLogShiftImplCopyWithImpl<$Res>
    extends _$TimeLogShiftCopyWithImpl<$Res, _$TimeLogShiftImpl>
    implements _$$TimeLogShiftImplCopyWith<$Res> {
  __$$TimeLogShiftImplCopyWithImpl(
      _$TimeLogShiftImpl _value, $Res Function(_$TimeLogShiftImpl) _then)
      : super(_value, _then);

  /// Create a copy of TimeLogShift
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? startTime = null,
    Object? endTime = null,
  }) {
    return _then(_$TimeLogShiftImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      startTime: null == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as String,
      endTime: null == endTime
          ? _value.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TimeLogShiftImpl implements _TimeLogShift {
  const _$TimeLogShiftImpl(
      {required this.id,
      required this.name,
      required this.startTime,
      required this.endTime});

  factory _$TimeLogShiftImpl.fromJson(Map<String, dynamic> json) =>
      _$$TimeLogShiftImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String startTime;
  @override
  final String endTime;

  @override
  String toString() {
    return 'TimeLogShift(id: $id, name: $name, startTime: $startTime, endTime: $endTime)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TimeLogShiftImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.endTime, endTime) || other.endTime == endTime));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, startTime, endTime);

  /// Create a copy of TimeLogShift
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TimeLogShiftImplCopyWith<_$TimeLogShiftImpl> get copyWith =>
      __$$TimeLogShiftImplCopyWithImpl<_$TimeLogShiftImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TimeLogShiftImplToJson(
      this,
    );
  }
}

abstract class _TimeLogShift implements TimeLogShift {
  const factory _TimeLogShift(
      {required final String id,
      required final String name,
      required final String startTime,
      required final String endTime}) = _$TimeLogShiftImpl;

  factory _TimeLogShift.fromJson(Map<String, dynamic> json) =
      _$TimeLogShiftImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get startTime;
  @override
  String get endTime;

  /// Create a copy of TimeLogShift
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TimeLogShiftImplCopyWith<_$TimeLogShiftImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TimeLog _$TimeLogFromJson(Map<String, dynamic> json) {
  return _TimeLog.fromJson(json);
}

/// @nodoc
mixin _$TimeLog {
  String get id => throw _privateConstructorUsedError;
  String get employeeId => throw _privateConstructorUsedError;
  DateTime get date => throw _privateConstructorUsedError;
  DateTime? get clockIn => throw _privateConstructorUsedError;
  DateTime? get clockOut => throw _privateConstructorUsedError;
  double get workHours => throw _privateConstructorUsedError;
  double get otHours => throw _privateConstructorUsedError;
  int get lateMinutes => throw _privateConstructorUsedError;
  int get undertimeMinutes => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  bool get isEdited => throw _privateConstructorUsedError;
  String? get editedBy => throw _privateConstructorUsedError;
  String? get editReason => throw _privateConstructorUsedError;
  TimeLogEmployee? get employee => throw _privateConstructorUsedError;
  TimeLogShift? get shift => throw _privateConstructorUsedError;
  dynamic get holiday => throw _privateConstructorUsedError;

  /// Serializes this TimeLog to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TimeLog
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TimeLogCopyWith<TimeLog> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TimeLogCopyWith<$Res> {
  factory $TimeLogCopyWith(TimeLog value, $Res Function(TimeLog) then) =
      _$TimeLogCopyWithImpl<$Res, TimeLog>;
  @useResult
  $Res call(
      {String id,
      String employeeId,
      DateTime date,
      DateTime? clockIn,
      DateTime? clockOut,
      double workHours,
      double otHours,
      int lateMinutes,
      int undertimeMinutes,
      String? notes,
      bool isEdited,
      String? editedBy,
      String? editReason,
      TimeLogEmployee? employee,
      TimeLogShift? shift,
      dynamic holiday});

  $TimeLogEmployeeCopyWith<$Res>? get employee;
  $TimeLogShiftCopyWith<$Res>? get shift;
}

/// @nodoc
class _$TimeLogCopyWithImpl<$Res, $Val extends TimeLog>
    implements $TimeLogCopyWith<$Res> {
  _$TimeLogCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TimeLog
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? employeeId = null,
    Object? date = null,
    Object? clockIn = freezed,
    Object? clockOut = freezed,
    Object? workHours = null,
    Object? otHours = null,
    Object? lateMinutes = null,
    Object? undertimeMinutes = null,
    Object? notes = freezed,
    Object? isEdited = null,
    Object? editedBy = freezed,
    Object? editReason = freezed,
    Object? employee = freezed,
    Object? shift = freezed,
    Object? holiday = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      employeeId: null == employeeId
          ? _value.employeeId
          : employeeId // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      clockIn: freezed == clockIn
          ? _value.clockIn
          : clockIn // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      clockOut: freezed == clockOut
          ? _value.clockOut
          : clockOut // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      workHours: null == workHours
          ? _value.workHours
          : workHours // ignore: cast_nullable_to_non_nullable
              as double,
      otHours: null == otHours
          ? _value.otHours
          : otHours // ignore: cast_nullable_to_non_nullable
              as double,
      lateMinutes: null == lateMinutes
          ? _value.lateMinutes
          : lateMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      undertimeMinutes: null == undertimeMinutes
          ? _value.undertimeMinutes
          : undertimeMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      isEdited: null == isEdited
          ? _value.isEdited
          : isEdited // ignore: cast_nullable_to_non_nullable
              as bool,
      editedBy: freezed == editedBy
          ? _value.editedBy
          : editedBy // ignore: cast_nullable_to_non_nullable
              as String?,
      editReason: freezed == editReason
          ? _value.editReason
          : editReason // ignore: cast_nullable_to_non_nullable
              as String?,
      employee: freezed == employee
          ? _value.employee
          : employee // ignore: cast_nullable_to_non_nullable
              as TimeLogEmployee?,
      shift: freezed == shift
          ? _value.shift
          : shift // ignore: cast_nullable_to_non_nullable
              as TimeLogShift?,
      holiday: freezed == holiday
          ? _value.holiday
          : holiday // ignore: cast_nullable_to_non_nullable
              as dynamic,
    ) as $Val);
  }

  /// Create a copy of TimeLog
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TimeLogEmployeeCopyWith<$Res>? get employee {
    if (_value.employee == null) {
      return null;
    }

    return $TimeLogEmployeeCopyWith<$Res>(_value.employee!, (value) {
      return _then(_value.copyWith(employee: value) as $Val);
    });
  }

  /// Create a copy of TimeLog
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TimeLogShiftCopyWith<$Res>? get shift {
    if (_value.shift == null) {
      return null;
    }

    return $TimeLogShiftCopyWith<$Res>(_value.shift!, (value) {
      return _then(_value.copyWith(shift: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$TimeLogImplCopyWith<$Res> implements $TimeLogCopyWith<$Res> {
  factory _$$TimeLogImplCopyWith(
          _$TimeLogImpl value, $Res Function(_$TimeLogImpl) then) =
      __$$TimeLogImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String employeeId,
      DateTime date,
      DateTime? clockIn,
      DateTime? clockOut,
      double workHours,
      double otHours,
      int lateMinutes,
      int undertimeMinutes,
      String? notes,
      bool isEdited,
      String? editedBy,
      String? editReason,
      TimeLogEmployee? employee,
      TimeLogShift? shift,
      dynamic holiday});

  @override
  $TimeLogEmployeeCopyWith<$Res>? get employee;
  @override
  $TimeLogShiftCopyWith<$Res>? get shift;
}

/// @nodoc
class __$$TimeLogImplCopyWithImpl<$Res>
    extends _$TimeLogCopyWithImpl<$Res, _$TimeLogImpl>
    implements _$$TimeLogImplCopyWith<$Res> {
  __$$TimeLogImplCopyWithImpl(
      _$TimeLogImpl _value, $Res Function(_$TimeLogImpl) _then)
      : super(_value, _then);

  /// Create a copy of TimeLog
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? employeeId = null,
    Object? date = null,
    Object? clockIn = freezed,
    Object? clockOut = freezed,
    Object? workHours = null,
    Object? otHours = null,
    Object? lateMinutes = null,
    Object? undertimeMinutes = null,
    Object? notes = freezed,
    Object? isEdited = null,
    Object? editedBy = freezed,
    Object? editReason = freezed,
    Object? employee = freezed,
    Object? shift = freezed,
    Object? holiday = freezed,
  }) {
    return _then(_$TimeLogImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      employeeId: null == employeeId
          ? _value.employeeId
          : employeeId // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      clockIn: freezed == clockIn
          ? _value.clockIn
          : clockIn // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      clockOut: freezed == clockOut
          ? _value.clockOut
          : clockOut // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      workHours: null == workHours
          ? _value.workHours
          : workHours // ignore: cast_nullable_to_non_nullable
              as double,
      otHours: null == otHours
          ? _value.otHours
          : otHours // ignore: cast_nullable_to_non_nullable
              as double,
      lateMinutes: null == lateMinutes
          ? _value.lateMinutes
          : lateMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      undertimeMinutes: null == undertimeMinutes
          ? _value.undertimeMinutes
          : undertimeMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      isEdited: null == isEdited
          ? _value.isEdited
          : isEdited // ignore: cast_nullable_to_non_nullable
              as bool,
      editedBy: freezed == editedBy
          ? _value.editedBy
          : editedBy // ignore: cast_nullable_to_non_nullable
              as String?,
      editReason: freezed == editReason
          ? _value.editReason
          : editReason // ignore: cast_nullable_to_non_nullable
              as String?,
      employee: freezed == employee
          ? _value.employee
          : employee // ignore: cast_nullable_to_non_nullable
              as TimeLogEmployee?,
      shift: freezed == shift
          ? _value.shift
          : shift // ignore: cast_nullable_to_non_nullable
              as TimeLogShift?,
      holiday: freezed == holiday
          ? _value.holiday
          : holiday // ignore: cast_nullable_to_non_nullable
              as dynamic,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TimeLogImpl implements _TimeLog {
  const _$TimeLogImpl(
      {required this.id,
      required this.employeeId,
      required this.date,
      this.clockIn,
      this.clockOut,
      this.workHours = 0.0,
      this.otHours = 0.0,
      this.lateMinutes = 0,
      this.undertimeMinutes = 0,
      this.notes,
      this.isEdited = false,
      this.editedBy,
      this.editReason,
      this.employee,
      this.shift,
      this.holiday});

  factory _$TimeLogImpl.fromJson(Map<String, dynamic> json) =>
      _$$TimeLogImplFromJson(json);

  @override
  final String id;
  @override
  final String employeeId;
  @override
  final DateTime date;
  @override
  final DateTime? clockIn;
  @override
  final DateTime? clockOut;
  @override
  @JsonKey()
  final double workHours;
  @override
  @JsonKey()
  final double otHours;
  @override
  @JsonKey()
  final int lateMinutes;
  @override
  @JsonKey()
  final int undertimeMinutes;
  @override
  final String? notes;
  @override
  @JsonKey()
  final bool isEdited;
  @override
  final String? editedBy;
  @override
  final String? editReason;
  @override
  final TimeLogEmployee? employee;
  @override
  final TimeLogShift? shift;
  @override
  final dynamic holiday;

  @override
  String toString() {
    return 'TimeLog(id: $id, employeeId: $employeeId, date: $date, clockIn: $clockIn, clockOut: $clockOut, workHours: $workHours, otHours: $otHours, lateMinutes: $lateMinutes, undertimeMinutes: $undertimeMinutes, notes: $notes, isEdited: $isEdited, editedBy: $editedBy, editReason: $editReason, employee: $employee, shift: $shift, holiday: $holiday)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TimeLogImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.employeeId, employeeId) ||
                other.employeeId == employeeId) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.clockIn, clockIn) || other.clockIn == clockIn) &&
            (identical(other.clockOut, clockOut) ||
                other.clockOut == clockOut) &&
            (identical(other.workHours, workHours) ||
                other.workHours == workHours) &&
            (identical(other.otHours, otHours) || other.otHours == otHours) &&
            (identical(other.lateMinutes, lateMinutes) ||
                other.lateMinutes == lateMinutes) &&
            (identical(other.undertimeMinutes, undertimeMinutes) ||
                other.undertimeMinutes == undertimeMinutes) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.isEdited, isEdited) ||
                other.isEdited == isEdited) &&
            (identical(other.editedBy, editedBy) ||
                other.editedBy == editedBy) &&
            (identical(other.editReason, editReason) ||
                other.editReason == editReason) &&
            (identical(other.employee, employee) ||
                other.employee == employee) &&
            (identical(other.shift, shift) || other.shift == shift) &&
            const DeepCollectionEquality().equals(other.holiday, holiday));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      employeeId,
      date,
      clockIn,
      clockOut,
      workHours,
      otHours,
      lateMinutes,
      undertimeMinutes,
      notes,
      isEdited,
      editedBy,
      editReason,
      employee,
      shift,
      const DeepCollectionEquality().hash(holiday));

  /// Create a copy of TimeLog
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TimeLogImplCopyWith<_$TimeLogImpl> get copyWith =>
      __$$TimeLogImplCopyWithImpl<_$TimeLogImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TimeLogImplToJson(
      this,
    );
  }
}

abstract class _TimeLog implements TimeLog {
  const factory _TimeLog(
      {required final String id,
      required final String employeeId,
      required final DateTime date,
      final DateTime? clockIn,
      final DateTime? clockOut,
      final double workHours,
      final double otHours,
      final int lateMinutes,
      final int undertimeMinutes,
      final String? notes,
      final bool isEdited,
      final String? editedBy,
      final String? editReason,
      final TimeLogEmployee? employee,
      final TimeLogShift? shift,
      final dynamic holiday}) = _$TimeLogImpl;

  factory _TimeLog.fromJson(Map<String, dynamic> json) = _$TimeLogImpl.fromJson;

  @override
  String get id;
  @override
  String get employeeId;
  @override
  DateTime get date;
  @override
  DateTime? get clockIn;
  @override
  DateTime? get clockOut;
  @override
  double get workHours;
  @override
  double get otHours;
  @override
  int get lateMinutes;
  @override
  int get undertimeMinutes;
  @override
  String? get notes;
  @override
  bool get isEdited;
  @override
  String? get editedBy;
  @override
  String? get editReason;
  @override
  TimeLogEmployee? get employee;
  @override
  TimeLogShift? get shift;
  @override
  dynamic get holiday;

  /// Create a copy of TimeLog
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TimeLogImplCopyWith<_$TimeLogImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
