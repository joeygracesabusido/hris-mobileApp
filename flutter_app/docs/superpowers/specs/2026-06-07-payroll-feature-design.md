# Payroll Feature — Design Spec

## Date
2026-06-07

## Problem
The "Payroll" button on the dashboard does nothing. There's no payroll screen, model, or API integration. The backend has a full Philippine payroll computation engine with SSS, PhilHealth, Pag-IBIG, BIR tax, OT, and holiday pay — but the Flutter app can't display or trigger it.

## Existing State
- Backend `GET /api/payroll` returns payroll records (role-aware: employees see only their own)
- Backend `POST /api/payroll` computes payroll for an employee/period (admin only)
- `Employee` model has `basicSalary`, `dailyRate`, `payrollFrequency`, `payType`
- `TimeLog` model tracks daily attendance used in payroll computation
- Dashboard "Payroll" button navigates to nothing

## Design

### 1. PayrollRecord Freezed Model

**File:** `lib/src/data/models/payroll.dart`

Maps the backend payroll response. Includes:

```dart
@freezed
class PayrollRecord with _$PayrollRecord {
  const factory PayrollRecord({
    required String id,
    required String employeeId,
    required int month,
    required int year,
    required DateTime periodStart,
    required DateTime periodEnd,
    required double basicSalary,
    required double dailyRate,
    required int workDays,
    required int daysWorked,
    required double otHours,
    required double otPay,
    required double holidayPay,
    required double grossPay,
    required double sssEmployee,
    required double philhealthEmployee,
    required double pagibigEmployee,
    required double withholdingTax,
    required double lateDeduction,
    required double undertimeDeduction,
    required double otherDeductions,
    required double totalDeductions,
    required double netPay,
    required String status,
    Map<String, dynamic>? employee, // linked employee data
  }) = _PayrollRecord;

  factory PayrollRecord.fromJson(Map<String, dynamic> json) => _$PayrollRecordFromJson(json);
}
```

### 2. PayrollRepository

**File:** `lib/src/data/providers/payroll_repository.dart`

Two methods:

```dart
class PayrollRepository {
  final Dio _dio = ApiClient.instance.dio;

  Future<List<PayrollRecord>> getPayrolls({String? employeeId, int? month, int? year}) async {
    final response = await _dio.get('/payroll', queryParameters: {
      if (employeeId != null) 'employeeId': employeeId,
      if (month != null) 'month': month,
      if (year != null) 'year': year,
    });
    final List<dynamic> data = response.data as List<dynamic>;
    return data.map((e) => PayrollRecord.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<PayrollRecord?> computePayroll({
    required String employeeId,
    required String periodStart,
    required String periodEnd,
    required String frequency,
    List<String>? deductions,
    double adjustmentAdd = 0,
    double adjustmentDeduct = 0,
    String adjustmentReason = '',
  }) async {
    final response = await _dio.post('/payroll', data: {
      'employeeId': employeeId,
      'periodStart': periodStart,
      'periodEnd': periodEnd,
      'frequency': frequency,
      'deductions': deductions ?? ['sss', 'philhealth', 'pagibig', 'tax'],
      'adjustmentAdd': adjustmentAdd,
      'adjustmentDeduct': adjustmentDeduct,
      'adjustmentReason': adjustmentReason,
    });
    final payroll = response.data['payroll'];
    return payroll != null ? PayrollRecord.fromJson(payroll as Map<String, dynamic>) : null;
  }
}
```

### 3. Riverpod 2.0 Providers

**File:** `lib/src/data/providers/payroll_provider.dart`

#### payrollListProvider.family

```dart
final payrollListProvider = FutureProvider.family.autoDispose<List<PayrollRecord>, String?>(
  (ref, employeeId) async {
    final repository = ref.watch(payrollRepositoryProvider);
    return repository.getPayrolls(employeeId: employeeId);
  },
);
```

- `employeeId = null` → admin fetches all employees' payrolls
- `employeeId = "abc123"` → fetches specific employee's payrolls
- Backend already enforces role-based filtering (non-admin sees only their own)
- `autoDispose` frees memory when the provider is no longer watched

#### processPayrollProvider

```dart
final processPayrollProvider = AsyncNotifierProvider.autoDispose<ProcessPayrollNotifier, PayrollRecord?>(
  (ref) => ProcessPayrollNotifier(
    ref.watch(payrollRepositoryProvider),
  ),
);

class ProcessPayrollNotifier extends AsyncNotifier<PayrollRecord?> {
  final PayrollRepository _repo;

  @override
  Future<PayrollRecord?> build() async => null;

  Future<void> compute({
    required String employeeId,
    required String periodStart,
    required String periodEnd,
    required String frequency,
  }) async {
    state = const AsyncLoading();
    try {
      final result = await _repo.computePayroll(
        employeeId: employeeId,
        periodStart: periodStart,
        periodEnd: periodEnd,
        frequency: frequency,
      );
      state = AsyncData(result);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
```

### 4. Payroll Screen — List View

**File:** `lib/src/ui/screens/payroll_screen.dart`

- Reads `payrollListProvider(null)` for admin, or `payrollListProvider(employeeId)` for employees
- Displays cards: "June 2026 · ₱45,230.00 net" with period label and net pay
- Pull-to-refresh via `RefreshIndicator`
- Search/filter by employee name (admin only)
- Admin-only FAB: "+" → bottom sheet with process payroll form
- Tap a card → navigate to `/payroll/:id`

### 5. Payroll Detail Screen — Full Payslip

**File:** `lib/src/ui/screens/payroll_detail_screen.dart`

Full payslip layout with three sections:

**Earnings:**
- Basic Salary: ₱30,000.00
- Overtime Pay (5h): ₱1,875.00
- Holiday Pay: ₱0.00
- **Gross Earnings: ₱31,875.00**

**Deductions:**
- SSS: ₱500.00
- PhilHealth: ₱500.00
- Pag-IBIG: ₱100.00
- Withholding Tax: ₱2,341.67
- Late Deduction: ₱0.00
- Undertime Deduction: ₱0.00
- **Total Deductions: ₱3,441.67**

**Net Pay: ₱28,433.33** (large bold text at bottom)

### 6. Process Payroll Bottom Sheet

**File:** `lib/src/ui/screens/payroll_screen.dart` (inline widget)

Form fields:
- Employee dropdown (from employee list provider)
- Start date picker
- End date picker
- Frequency selector: Monthly / Semimonthly
- "Compute" button → calls `processPayrollProvider.notifier.compute()`
- Shows loading spinner during computation
- On success: shows result summary + "View Payroll" button to navigate to detail

### 7. Dashboard Integration

**File:** `lib/src/ui/screens/dashboard_screen.dart`

- Wire the "Payroll" button to navigate to `/payroll`
- Only show for admin (already handled by RBAC from previous feature)

## Data Flow

```
Dashboard → /payroll → PayrollScreen
  └─ payrollListProvider(null) → GET /api/payroll → List<PayrollRecord>
  └─ tap card → /payroll/:id → PayrollDetailScreen
  └─ FAB (admin) → ProcessPayrollBottomSheet
      └─ POST /api/payroll → PayrollRecord → refresh list
```

## Error Handling

- `AsyncError` shows "Failed to load payroll data" with retry button
- 403 from process payroll → "You don't have permission" (already handled by hiding the FAB for employees)
- 409 from process payroll → "Payroll already exists for this period"
- Empty state: "No payroll records found" — admin sees "Tap + to process payroll"

## Files to Create

- `lib/src/data/models/payroll.dart` — freezed model
- `lib/src/data/providers/payroll_repository.dart` — API calls
- `lib/src/data/providers/payroll_provider.dart` — Riverpod 2.0 providers
- `lib/src/ui/screens/payroll_screen.dart` — list view + process form
- `lib/src/ui/screens/payroll_detail_screen.dart` — full payslip

## Files to Modify

- `lib/main.dart` — add `/payroll` route and `GoRoute(path: '/payroll/:id', ...) ` for detail screen using `state.pathParameters['id']`
- `lib/src/ui/screens/dashboard_screen.dart` — wire Payroll button navigation
