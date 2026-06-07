// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'payroll.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PayrollRecord _$PayrollRecordFromJson(Map<String, dynamic> json) {
  return _PayrollRecord.fromJson(json);
}

/// @nodoc
mixin _$PayrollRecord {
  String get id => throw _privateConstructorUsedError;
  String get employeeId => throw _privateConstructorUsedError;
  int get month => throw _privateConstructorUsedError;
  int get year => throw _privateConstructorUsedError;
  DateTime get periodStart => throw _privateConstructorUsedError;
  DateTime get periodEnd => throw _privateConstructorUsedError;
  double get basicSalary => throw _privateConstructorUsedError;
  double get dailyRate => throw _privateConstructorUsedError;
  int get workDays => throw _privateConstructorUsedError;
  int get daysWorked => throw _privateConstructorUsedError;
  double get otHours => throw _privateConstructorUsedError;
  double get otPay => throw _privateConstructorUsedError;
  double get holidayPay => throw _privateConstructorUsedError;
  double get grossPay => throw _privateConstructorUsedError;
  double get sssEmployee => throw _privateConstructorUsedError;
  double get philhealthEmployee => throw _privateConstructorUsedError;
  double get pagibigEmployee => throw _privateConstructorUsedError;
  double get withholdingTax => throw _privateConstructorUsedError;
  double get lateDeduction => throw _privateConstructorUsedError;
  double get undertimeDeduction => throw _privateConstructorUsedError;
  double get otherDeductions => throw _privateConstructorUsedError;
  double get totalDeductions => throw _privateConstructorUsedError;
  double get netPay => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  Map<String, dynamic>? get employee => throw _privateConstructorUsedError;

  /// Serializes this PayrollRecord to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PayrollRecord
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PayrollRecordCopyWith<PayrollRecord> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PayrollRecordCopyWith<$Res> {
  factory $PayrollRecordCopyWith(
          PayrollRecord value, $Res Function(PayrollRecord) then) =
      _$PayrollRecordCopyWithImpl<$Res, PayrollRecord>;
  @useResult
  $Res call(
      {String id,
      String employeeId,
      int month,
      int year,
      DateTime periodStart,
      DateTime periodEnd,
      double basicSalary,
      double dailyRate,
      int workDays,
      int daysWorked,
      double otHours,
      double otPay,
      double holidayPay,
      double grossPay,
      double sssEmployee,
      double philhealthEmployee,
      double pagibigEmployee,
      double withholdingTax,
      double lateDeduction,
      double undertimeDeduction,
      double otherDeductions,
      double totalDeductions,
      double netPay,
      String status,
      Map<String, dynamic>? employee});
}

/// @nodoc
class _$PayrollRecordCopyWithImpl<$Res, $Val extends PayrollRecord>
    implements $PayrollRecordCopyWith<$Res> {
  _$PayrollRecordCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PayrollRecord
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? employeeId = null,
    Object? month = null,
    Object? year = null,
    Object? periodStart = null,
    Object? periodEnd = null,
    Object? basicSalary = null,
    Object? dailyRate = null,
    Object? workDays = null,
    Object? daysWorked = null,
    Object? otHours = null,
    Object? otPay = null,
    Object? holidayPay = null,
    Object? grossPay = null,
    Object? sssEmployee = null,
    Object? philhealthEmployee = null,
    Object? pagibigEmployee = null,
    Object? withholdingTax = null,
    Object? lateDeduction = null,
    Object? undertimeDeduction = null,
    Object? otherDeductions = null,
    Object? totalDeductions = null,
    Object? netPay = null,
    Object? status = null,
    Object? employee = freezed,
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
      month: null == month
          ? _value.month
          : month // ignore: cast_nullable_to_non_nullable
              as int,
      year: null == year
          ? _value.year
          : year // ignore: cast_nullable_to_non_nullable
              as int,
      periodStart: null == periodStart
          ? _value.periodStart
          : periodStart // ignore: cast_nullable_to_non_nullable
              as DateTime,
      periodEnd: null == periodEnd
          ? _value.periodEnd
          : periodEnd // ignore: cast_nullable_to_non_nullable
              as DateTime,
      basicSalary: null == basicSalary
          ? _value.basicSalary
          : basicSalary // ignore: cast_nullable_to_non_nullable
              as double,
      dailyRate: null == dailyRate
          ? _value.dailyRate
          : dailyRate // ignore: cast_nullable_to_non_nullable
              as double,
      workDays: null == workDays
          ? _value.workDays
          : workDays // ignore: cast_nullable_to_non_nullable
              as int,
      daysWorked: null == daysWorked
          ? _value.daysWorked
          : daysWorked // ignore: cast_nullable_to_non_nullable
              as int,
      otHours: null == otHours
          ? _value.otHours
          : otHours // ignore: cast_nullable_to_non_nullable
              as double,
      otPay: null == otPay
          ? _value.otPay
          : otPay // ignore: cast_nullable_to_non_nullable
              as double,
      holidayPay: null == holidayPay
          ? _value.holidayPay
          : holidayPay // ignore: cast_nullable_to_non_nullable
              as double,
      grossPay: null == grossPay
          ? _value.grossPay
          : grossPay // ignore: cast_nullable_to_non_nullable
              as double,
      sssEmployee: null == sssEmployee
          ? _value.sssEmployee
          : sssEmployee // ignore: cast_nullable_to_non_nullable
              as double,
      philhealthEmployee: null == philhealthEmployee
          ? _value.philhealthEmployee
          : philhealthEmployee // ignore: cast_nullable_to_non_nullable
              as double,
      pagibigEmployee: null == pagibigEmployee
          ? _value.pagibigEmployee
          : pagibigEmployee // ignore: cast_nullable_to_non_nullable
              as double,
      withholdingTax: null == withholdingTax
          ? _value.withholdingTax
          : withholdingTax // ignore: cast_nullable_to_non_nullable
              as double,
      lateDeduction: null == lateDeduction
          ? _value.lateDeduction
          : lateDeduction // ignore: cast_nullable_to_non_nullable
              as double,
      undertimeDeduction: null == undertimeDeduction
          ? _value.undertimeDeduction
          : undertimeDeduction // ignore: cast_nullable_to_non_nullable
              as double,
      otherDeductions: null == otherDeductions
          ? _value.otherDeductions
          : otherDeductions // ignore: cast_nullable_to_non_nullable
              as double,
      totalDeductions: null == totalDeductions
          ? _value.totalDeductions
          : totalDeductions // ignore: cast_nullable_to_non_nullable
              as double,
      netPay: null == netPay
          ? _value.netPay
          : netPay // ignore: cast_nullable_to_non_nullable
              as double,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      employee: freezed == employee
          ? _value.employee
          : employee // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PayrollRecordImplCopyWith<$Res>
    implements $PayrollRecordCopyWith<$Res> {
  factory _$$PayrollRecordImplCopyWith(
          _$PayrollRecordImpl value, $Res Function(_$PayrollRecordImpl) then) =
      __$$PayrollRecordImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String employeeId,
      int month,
      int year,
      DateTime periodStart,
      DateTime periodEnd,
      double basicSalary,
      double dailyRate,
      int workDays,
      int daysWorked,
      double otHours,
      double otPay,
      double holidayPay,
      double grossPay,
      double sssEmployee,
      double philhealthEmployee,
      double pagibigEmployee,
      double withholdingTax,
      double lateDeduction,
      double undertimeDeduction,
      double otherDeductions,
      double totalDeductions,
      double netPay,
      String status,
      Map<String, dynamic>? employee});
}

/// @nodoc
class __$$PayrollRecordImplCopyWithImpl<$Res>
    extends _$PayrollRecordCopyWithImpl<$Res, _$PayrollRecordImpl>
    implements _$$PayrollRecordImplCopyWith<$Res> {
  __$$PayrollRecordImplCopyWithImpl(
      _$PayrollRecordImpl _value, $Res Function(_$PayrollRecordImpl) _then)
      : super(_value, _then);

  /// Create a copy of PayrollRecord
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? employeeId = null,
    Object? month = null,
    Object? year = null,
    Object? periodStart = null,
    Object? periodEnd = null,
    Object? basicSalary = null,
    Object? dailyRate = null,
    Object? workDays = null,
    Object? daysWorked = null,
    Object? otHours = null,
    Object? otPay = null,
    Object? holidayPay = null,
    Object? grossPay = null,
    Object? sssEmployee = null,
    Object? philhealthEmployee = null,
    Object? pagibigEmployee = null,
    Object? withholdingTax = null,
    Object? lateDeduction = null,
    Object? undertimeDeduction = null,
    Object? otherDeductions = null,
    Object? totalDeductions = null,
    Object? netPay = null,
    Object? status = null,
    Object? employee = freezed,
  }) {
    return _then(_$PayrollRecordImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      employeeId: null == employeeId
          ? _value.employeeId
          : employeeId // ignore: cast_nullable_to_non_nullable
              as String,
      month: null == month
          ? _value.month
          : month // ignore: cast_nullable_to_non_nullable
              as int,
      year: null == year
          ? _value.year
          : year // ignore: cast_nullable_to_non_nullable
              as int,
      periodStart: null == periodStart
          ? _value.periodStart
          : periodStart // ignore: cast_nullable_to_non_nullable
              as DateTime,
      periodEnd: null == periodEnd
          ? _value.periodEnd
          : periodEnd // ignore: cast_nullable_to_non_nullable
              as DateTime,
      basicSalary: null == basicSalary
          ? _value.basicSalary
          : basicSalary // ignore: cast_nullable_to_non_nullable
              as double,
      dailyRate: null == dailyRate
          ? _value.dailyRate
          : dailyRate // ignore: cast_nullable_to_non_nullable
              as double,
      workDays: null == workDays
          ? _value.workDays
          : workDays // ignore: cast_nullable_to_non_nullable
              as int,
      daysWorked: null == daysWorked
          ? _value.daysWorked
          : daysWorked // ignore: cast_nullable_to_non_nullable
              as int,
      otHours: null == otHours
          ? _value.otHours
          : otHours // ignore: cast_nullable_to_non_nullable
              as double,
      otPay: null == otPay
          ? _value.otPay
          : otPay // ignore: cast_nullable_to_non_nullable
              as double,
      holidayPay: null == holidayPay
          ? _value.holidayPay
          : holidayPay // ignore: cast_nullable_to_non_nullable
              as double,
      grossPay: null == grossPay
          ? _value.grossPay
          : grossPay // ignore: cast_nullable_to_non_nullable
              as double,
      sssEmployee: null == sssEmployee
          ? _value.sssEmployee
          : sssEmployee // ignore: cast_nullable_to_non_nullable
              as double,
      philhealthEmployee: null == philhealthEmployee
          ? _value.philhealthEmployee
          : philhealthEmployee // ignore: cast_nullable_to_non_nullable
              as double,
      pagibigEmployee: null == pagibigEmployee
          ? _value.pagibigEmployee
          : pagibigEmployee // ignore: cast_nullable_to_non_nullable
              as double,
      withholdingTax: null == withholdingTax
          ? _value.withholdingTax
          : withholdingTax // ignore: cast_nullable_to_non_nullable
              as double,
      lateDeduction: null == lateDeduction
          ? _value.lateDeduction
          : lateDeduction // ignore: cast_nullable_to_non_nullable
              as double,
      undertimeDeduction: null == undertimeDeduction
          ? _value.undertimeDeduction
          : undertimeDeduction // ignore: cast_nullable_to_non_nullable
              as double,
      otherDeductions: null == otherDeductions
          ? _value.otherDeductions
          : otherDeductions // ignore: cast_nullable_to_non_nullable
              as double,
      totalDeductions: null == totalDeductions
          ? _value.totalDeductions
          : totalDeductions // ignore: cast_nullable_to_non_nullable
              as double,
      netPay: null == netPay
          ? _value.netPay
          : netPay // ignore: cast_nullable_to_non_nullable
              as double,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      employee: freezed == employee
          ? _value._employee
          : employee // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PayrollRecordImpl implements _PayrollRecord {
  const _$PayrollRecordImpl(
      {required this.id,
      required this.employeeId,
      required this.month,
      required this.year,
      required this.periodStart,
      required this.periodEnd,
      this.basicSalary = 0.0,
      this.dailyRate = 0.0,
      this.workDays = 0,
      this.daysWorked = 0,
      this.otHours = 0.0,
      this.otPay = 0.0,
      this.holidayPay = 0.0,
      this.grossPay = 0.0,
      this.sssEmployee = 0.0,
      this.philhealthEmployee = 0.0,
      this.pagibigEmployee = 0.0,
      this.withholdingTax = 0.0,
      this.lateDeduction = 0.0,
      this.undertimeDeduction = 0.0,
      this.otherDeductions = 0.0,
      this.totalDeductions = 0.0,
      this.netPay = 0.0,
      this.status = 'PROCESSED',
      final Map<String, dynamic>? employee})
      : _employee = employee;

  factory _$PayrollRecordImpl.fromJson(Map<String, dynamic> json) =>
      _$$PayrollRecordImplFromJson(json);

  @override
  final String id;
  @override
  final String employeeId;
  @override
  final int month;
  @override
  final int year;
  @override
  final DateTime periodStart;
  @override
  final DateTime periodEnd;
  @override
  @JsonKey()
  final double basicSalary;
  @override
  @JsonKey()
  final double dailyRate;
  @override
  @JsonKey()
  final int workDays;
  @override
  @JsonKey()
  final int daysWorked;
  @override
  @JsonKey()
  final double otHours;
  @override
  @JsonKey()
  final double otPay;
  @override
  @JsonKey()
  final double holidayPay;
  @override
  @JsonKey()
  final double grossPay;
  @override
  @JsonKey()
  final double sssEmployee;
  @override
  @JsonKey()
  final double philhealthEmployee;
  @override
  @JsonKey()
  final double pagibigEmployee;
  @override
  @JsonKey()
  final double withholdingTax;
  @override
  @JsonKey()
  final double lateDeduction;
  @override
  @JsonKey()
  final double undertimeDeduction;
  @override
  @JsonKey()
  final double otherDeductions;
  @override
  @JsonKey()
  final double totalDeductions;
  @override
  @JsonKey()
  final double netPay;
  @override
  @JsonKey()
  final String status;
  final Map<String, dynamic>? _employee;
  @override
  Map<String, dynamic>? get employee {
    final value = _employee;
    if (value == null) return null;
    if (_employee is EqualUnmodifiableMapView) return _employee;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'PayrollRecord(id: $id, employeeId: $employeeId, month: $month, year: $year, periodStart: $periodStart, periodEnd: $periodEnd, basicSalary: $basicSalary, dailyRate: $dailyRate, workDays: $workDays, daysWorked: $daysWorked, otHours: $otHours, otPay: $otPay, holidayPay: $holidayPay, grossPay: $grossPay, sssEmployee: $sssEmployee, philhealthEmployee: $philhealthEmployee, pagibigEmployee: $pagibigEmployee, withholdingTax: $withholdingTax, lateDeduction: $lateDeduction, undertimeDeduction: $undertimeDeduction, otherDeductions: $otherDeductions, totalDeductions: $totalDeductions, netPay: $netPay, status: $status, employee: $employee)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PayrollRecordImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.employeeId, employeeId) ||
                other.employeeId == employeeId) &&
            (identical(other.month, month) || other.month == month) &&
            (identical(other.year, year) || other.year == year) &&
            (identical(other.periodStart, periodStart) ||
                other.periodStart == periodStart) &&
            (identical(other.periodEnd, periodEnd) ||
                other.periodEnd == periodEnd) &&
            (identical(other.basicSalary, basicSalary) ||
                other.basicSalary == basicSalary) &&
            (identical(other.dailyRate, dailyRate) ||
                other.dailyRate == dailyRate) &&
            (identical(other.workDays, workDays) ||
                other.workDays == workDays) &&
            (identical(other.daysWorked, daysWorked) ||
                other.daysWorked == daysWorked) &&
            (identical(other.otHours, otHours) || other.otHours == otHours) &&
            (identical(other.otPay, otPay) || other.otPay == otPay) &&
            (identical(other.holidayPay, holidayPay) ||
                other.holidayPay == holidayPay) &&
            (identical(other.grossPay, grossPay) ||
                other.grossPay == grossPay) &&
            (identical(other.sssEmployee, sssEmployee) ||
                other.sssEmployee == sssEmployee) &&
            (identical(other.philhealthEmployee, philhealthEmployee) ||
                other.philhealthEmployee == philhealthEmployee) &&
            (identical(other.pagibigEmployee, pagibigEmployee) ||
                other.pagibigEmployee == pagibigEmployee) &&
            (identical(other.withholdingTax, withholdingTax) ||
                other.withholdingTax == withholdingTax) &&
            (identical(other.lateDeduction, lateDeduction) ||
                other.lateDeduction == lateDeduction) &&
            (identical(other.undertimeDeduction, undertimeDeduction) ||
                other.undertimeDeduction == undertimeDeduction) &&
            (identical(other.otherDeductions, otherDeductions) ||
                other.otherDeductions == otherDeductions) &&
            (identical(other.totalDeductions, totalDeductions) ||
                other.totalDeductions == totalDeductions) &&
            (identical(other.netPay, netPay) || other.netPay == netPay) &&
            (identical(other.status, status) || other.status == status) &&
            const DeepCollectionEquality().equals(other._employee, _employee));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        employeeId,
        month,
        year,
        periodStart,
        periodEnd,
        basicSalary,
        dailyRate,
        workDays,
        daysWorked,
        otHours,
        otPay,
        holidayPay,
        grossPay,
        sssEmployee,
        philhealthEmployee,
        pagibigEmployee,
        withholdingTax,
        lateDeduction,
        undertimeDeduction,
        otherDeductions,
        totalDeductions,
        netPay,
        status,
        const DeepCollectionEquality().hash(_employee)
      ]);

  /// Create a copy of PayrollRecord
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PayrollRecordImplCopyWith<_$PayrollRecordImpl> get copyWith =>
      __$$PayrollRecordImplCopyWithImpl<_$PayrollRecordImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PayrollRecordImplToJson(
      this,
    );
  }
}

abstract class _PayrollRecord implements PayrollRecord {
  const factory _PayrollRecord(
      {required final String id,
      required final String employeeId,
      required final int month,
      required final int year,
      required final DateTime periodStart,
      required final DateTime periodEnd,
      final double basicSalary,
      final double dailyRate,
      final int workDays,
      final int daysWorked,
      final double otHours,
      final double otPay,
      final double holidayPay,
      final double grossPay,
      final double sssEmployee,
      final double philhealthEmployee,
      final double pagibigEmployee,
      final double withholdingTax,
      final double lateDeduction,
      final double undertimeDeduction,
      final double otherDeductions,
      final double totalDeductions,
      final double netPay,
      final String status,
      final Map<String, dynamic>? employee}) = _$PayrollRecordImpl;

  factory _PayrollRecord.fromJson(Map<String, dynamic> json) =
      _$PayrollRecordImpl.fromJson;

  @override
  String get id;
  @override
  String get employeeId;
  @override
  int get month;
  @override
  int get year;
  @override
  DateTime get periodStart;
  @override
  DateTime get periodEnd;
  @override
  double get basicSalary;
  @override
  double get dailyRate;
  @override
  int get workDays;
  @override
  int get daysWorked;
  @override
  double get otHours;
  @override
  double get otPay;
  @override
  double get holidayPay;
  @override
  double get grossPay;
  @override
  double get sssEmployee;
  @override
  double get philhealthEmployee;
  @override
  double get pagibigEmployee;
  @override
  double get withholdingTax;
  @override
  double get lateDeduction;
  @override
  double get undertimeDeduction;
  @override
  double get otherDeductions;
  @override
  double get totalDeductions;
  @override
  double get netPay;
  @override
  String get status;
  @override
  Map<String, dynamic>? get employee;

  /// Create a copy of PayrollRecord
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PayrollRecordImplCopyWith<_$PayrollRecordImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
