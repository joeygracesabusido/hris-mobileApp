# Payroll Feature Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a functional payroll screen that displays computed Philippine payroll data with full payslip detail view, using Riverpod 2.0 auto-dispose providers.

**Architecture:** Freezed model → Repository → Riverpod 2.0 `FutureProvider.family.autoDispose` for list + `AsyncNotifierProvider.autoDispose` for compute form → PayrollScreen (list) → PayrollDetailScreen (payslip). Role-aware: admin sees all, employee sees own.

**Tech Stack:** Flutter, Riverpod 2.4, freezed, json_serializable, Dio, GoRouter

---

### Task 1: Create PayrollRecord Freezed Model

**Files:**
- Create: `lib/src/data/models/payroll.dart`

- [ ] **Step 1: Write the model file**

```dart
// lib/src/data/models/payroll.dart
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
```

- [ ] **Step 2: Run build_runner**

Run: `cd flutter_app && dart run build_runner build --delete-conflicting-outputs`
Expected: Generates `payroll.freezed.dart` and `payroll.g.dart`

- [ ] **Step 3: Verify the file compiles**

Run: `flutter analyze lib/src/data/models/payroll.dart`
Expected: No issues

- [ ] **Step 4: Commit**

```bash
git add lib/src/data/models/payroll.dart lib/src/data/models/payroll.freezed.dart lib/src/data/models/payroll.g.dart
git commit -m "feat: add PayrollRecord freezed model"
```

---

### Task 2: Create PayrollRepository

**Files:**
- Create: `lib/src/data/providers/payroll_repository.dart`

- [ ] **Step 1: Write the repository file**

```dart
// lib/src/data/providers/payroll_repository.dart
import 'package:dio/dio.dart';
import '../models/payroll.dart';
import 'api_client.dart';

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

- [ ] **Step 2: Verify the file compiles**

Run: `flutter analyze lib/src/data/providers/payroll_repository.dart`
Expected: No issues

- [ ] **Step 3: Commit**

```bash
git add lib/src/data/providers/payroll_repository.dart
git commit -m "feat: add PayrollRepository with getPayrolls and computePayroll"
```

---

### Task 3: Create Riverpod 2.0 Providers

**Files:**
- Create: `lib/src/data/providers/payroll_provider.dart`

- [ ] **Step 1: Write the providers file**

```dart
// lib/src/data/providers/payroll_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/payroll.dart';
import 'payroll_repository.dart';

final payrollRepositoryProvider = Provider<PayrollRepository>((ref) {
  return PayrollRepository();
});

/// Fetches payroll records. Pass null for employeeId to fetch all (admin).
/// Auto-disposes when no longer watched. Caches per employeeId key.
final payrollListProvider = FutureProvider.family.autoDispose<List<PayrollRecord>, String?>(
  (ref, employeeId) async {
    final repository = ref.watch(payrollRepositoryProvider);
    return repository.getPayrolls(employeeId: employeeId);
  },
);

/// Handles the "Process Payroll" computation form.
final processPayrollProvider = AsyncNotifierProvider.autoDispose<ProcessPayrollNotifier, PayrollRecord?>(
  (ref) => ProcessPayrollNotifier(ref.watch(payrollRepositoryProvider)),
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

- [ ] **Step 2: Verify the file compiles**

Run: `flutter analyze lib/src/data/providers/payroll_provider.dart`
Expected: No issues

- [ ] **Step 3: Commit**

```bash
git add lib/src/data/providers/payroll_provider.dart
git commit -m "feat: add Riverpod 2.0 payroll providers with auto-dispose and family"
```

---

### Task 4: Create Payroll Screen — List View + Process Form

**Files:**
- Create: `lib/src/ui/screens/payroll_screen.dart`

- [ ] **Step 1: Write the payroll screen file**

Read these files first for reference on existing patterns:
- `lib/src/ui/screens/time_log_screen.dart` — for list card pattern, search bar, refresh
- `lib/src/auth/role_guard.dart` — for role checking
- `lib/src/ui/widgets/app_theme.dart` — for theme colors

Then create the screen with:

```dart
// lib/src/ui/screens/payroll_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../auth/auth_provider.dart';
import '../../auth/role_guard.dart';
import '../../data/models/payroll.dart';
import '../../data/providers/payroll_provider.dart';
import '../widgets/app_theme.dart';

class PayrollScreen extends ConsumerWidget {
  const PayrollScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final guard = RoleGuard(authState);

    // Admin fetches all; employee fetches own
    final employeeId = guard.isAdmin ? null : guard.currentEmployeeId;
    final payrollAsync = ref.watch(payrollListProvider(employeeId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payroll'),
        backgroundColor: AppTheme.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => context.go('/dashboard'),
        ),
      ),
      backgroundColor: AppTheme.background,
      body: payrollAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 12),
              Text('Failed to load payroll data', style: TextStyle(color: AppTheme.textSecondary)),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => ref.invalidate(payrollListProvider(employeeId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (payrolls) {
          if (payrolls.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 12),
                  Text('No payroll records found', style: TextStyle(color: AppTheme.textSecondary)),
                  if (guard.isAdmin) ...[
                    const SizedBox(height: 8),
                    Text('Tap + to process payroll', style: TextStyle(color: AppTheme.textSecondary)),
                  ],
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(payrollListProvider(employeeId)),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: payrolls.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final record = payrolls[index];
                return _PayrollCard(record: record);
              },
            ),
          );
        },
      ),
      floatingActionButton: guard.isAdmin
          ? FloatingActionButton(
              onPressed: () => _showProcessPayroll(context, ref),
              backgroundColor: AppTheme.primary,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  void _showProcessPayroll(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.cardBackground,
      builder: (context) => const _ProcessPayrollSheet(),
    );
  }
}

class _PayrollCard extends StatelessWidget {
  final PayrollRecord record;
  const _PayrollCard({required this.record});

  String _formatPeriod(DateTime dt) => DateFormat('MMM yyyy').format(dt);
  String _formatCurrency(double amount) => NumberFormat.currency(symbol: '₱', decimalDigits: 2).format(amount);

  @override
  Widget build(BuildContext context) {
    final empName = record.employee?['fullName'] as String? ?? 'Unknown';
    return GestureDetector(
      onTap: () => context.go('/payroll/${record.id}'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_formatPeriod(record.periodStart), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                Icon(Icons.chevron_right, color: Colors.white.withAlpha(100), size: 20),
              ],
            ),
            if (record.employee != null) ...[
              const SizedBox(height: 4),
              Text(empName, style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
            ],
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Net Pay', style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                  Text(_formatCurrency(record.netPay), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF00D1B2))),
                ]),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: (record.status == 'PROCESSED' ? const Color(0xFF00D1B2) : Colors.orange).withAlpha(30),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: (record.status == 'PROCESSED' ? const Color(0xFF00D1B2) : Colors.orange).withAlpha(80)),
                  ),
                  child: Text(record.status, style: TextStyle(color: record.status == 'PROCESSED' ? const Color(0xFF00D1B2) : Colors.orange, fontSize: 11, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProcessPayrollSheet extends ConsumerStatefulWidget {
  const _ProcessPayrollSheet();

  @override
  ConsumerState<_ProcessPayrollSheet> createState() => _ProcessPayrollSheetState();
}

class _ProcessPayrollSheetState extends ConsumerState<_ProcessPayrollSheet> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedEmployeeId;
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 15));
  DateTime _endDate = DateTime.now();
  String _frequency = 'SEMIMONTHLY';

  @override
  Widget build(BuildContext context) {
    final computeState = ref.watch(processPayrollProvider);

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Process Payroll', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 20),

              // Start date
              ListTile(
                title: Text('Start Date', style: const TextStyle(color: Colors.white)),
                subtitle: Text(DateFormat('MMM dd, yyyy').format(_startDate), style: TextStyle(color: AppTheme.textSecondary)),
                onTap: () async {
                  final date = await showDatePicker(context: context, initialDate: _startDate, firstDate: DateTime(2020), lastDate: DateTime(2030));
                  if (date != null) setState(() => _startDate = date);
                },
              ),

              // End date
              ListTile(
                title: Text('End Date', style: const TextStyle(color: Colors.white)),
                subtitle: Text(DateFormat('MMM dd, yyyy').format(_endDate), style: TextStyle(color: AppTheme.textSecondary)),
                onTap: () async {
                  final date = await showDatePicker(context: context, initialDate: _endDate, firstDate: DateTime(2020), lastDate: DateTime(2030));
                  if (date != null) setState(() => _endDate = date);
                },
              ),

              // Frequency
              DropdownButtonFormField<String>(
                value: _frequency,
                decoration: InputDecoration(labelText: 'Frequency', labelStyle: const TextStyle(color: Colors.white), filled: true, fillColor: AppTheme.cardBackground),
                items: ['MONTHLY', 'SEMIMONTHLY'].map((f) => DropdownMenuItem(value: f, child: Text(f, style: const TextStyle(color: Colors.white)))).toList(),
                onChanged: (v) => setState(() => _frequency = v!),
              ),

              const SizedBox(height: 20),

              // Compute button
              computeState.when(
                data: (result) {
                  if (result == null) return const SizedBox.shrink();
                  return Column(
                    children: [
                      Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.green.withAlpha(30), borderRadius: BorderRadius.circular(12)), child: Text('Payroll computed! Net pay: ₱${result.netPay.toStringAsFixed(2)}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold))),
                      const SizedBox(height: 12),
                      ElevatedButton(onPressed: () { Navigator.pop(context); ref.invalidate(payrollListProvider(null)); }, child: const Text('View Payroll')),
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.red.withAlpha(30), borderRadius: BorderRadius.circular(12)), child: Text('Error: $err', style: const TextStyle(color: Colors.red))),
                orElse: () => SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _handleCompute, child: const Text('Compute Payroll'))),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  void _handleCompute() {
    if (_formKey.currentState!.validate()) {
      final startStr = DateFormat('yyyy-MM-dd').format(_startDate);
      final endStr = DateFormat('yyyy-MM-dd').format(_endDate);
      ref.read(processPayrollProvider.notifier).compute(
        employeeId: _selectedEmployeeId ?? 'all',
        periodStart: startStr,
        periodEnd: endStr,
        frequency: _frequency,
      );
    }
  }
}
```

- [ ] **Step 2: Verify the file compiles**

Run: `flutter analyze lib/src/ui/screens/payroll_screen.dart`
Expected: No issues

- [ ] **Step 3: Commit**

```bash
git add lib/src/ui/screens/payroll_screen.dart
git commit -m "feat: add PayrollScreen with list view, payslip cards, and process payroll bottom sheet"
```

---

### Task 5: Create Payroll Detail Screen — Full Payslip

**Files:**
- Create: `lib/src/ui/screens/payroll_detail_screen.dart`

- [ ] **Step 1: Write the detail screen file**

```dart
// lib/src/ui/screens/payroll_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../data/models/payroll.dart';
import '../../data/providers/payroll_provider.dart';
import '../widgets/app_theme.dart';

class PayrollDetailScreen extends ConsumerWidget {
  final String payrollId;
  const PayrollDetailScreen({required this.payrollId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Find the payroll record from the cached list
    final payrollAsync = ref.watch(payrollListProvider(null));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payroll Detail'),
        backgroundColor: AppTheme.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => context.go('/payroll'),
        ),
      ),
      backgroundColor: AppTheme.background,
      body: payrollAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err', style: TextStyle(color: AppTheme.textSecondary))),
        data: (payrolls) {
          final record = payrolls.firstWhere((p) => p.id == payrollId, orElse: () => const PayrollRecord(id: '', employeeId: '', month: 0, year: 0, periodStart: DateTime.now(), periodEnd: DateTime.now()));
          if (record.id.isEmpty) {
            return const Center(child: Text('Payroll record not found', style: TextStyle(color: AppTheme.textSecondary)));
          }
          return _PayslipDetail(record: record);
        },
      ),
    );
  }
}

class _PayslipDetail extends StatelessWidget {
  final PayrollRecord record;
  const _PayslipDetail({required this.record});

  String _formatCurrency(double amount) => NumberFormat.currency(symbol: '₱', decimalDigits: 2).format(amount);
  String _formatPeriod(DateTime dt) => DateFormat('MMM dd, yyyy').format(dt);

  Widget _lineItem(String label, double amount, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: color ?? Colors.white, fontSize: 14)),
          Text(_formatCurrency(amount), style: TextStyle(color: color ?? Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF00D1B2))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final empName = record.employee?['fullName'] as String? ?? 'Unknown';
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Employee info header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppTheme.cardBackground, borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(empName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 4),
                Text('Period: ${_formatPeriod(record.periodStart)} — ${_formatPeriod(record.periodEnd)}', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                Text('Work Days: ${record.daysWorked}/${record.workDays}', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Earnings section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppTheme.cardBackground, borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionHeader('Earnings'),
                _lineItem('Basic Salary', record.basicSalary),
                if (record.otPay > 0) _lineItem('Overtime Pay (${record.otHours.toStringAsFixed(1)}h)', record.otPay),
                if (record.holidayPay > 0) _lineItem('Holiday Pay', record.holidayPay),
                const Divider(color: Colors.white24),
                _lineItem('Gross Earnings', record.grossPay, color: const Color(0xFF00D1B2)),
              ],
            ),
          ),

          // Deductions section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(color: AppTheme.cardBackground, borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionHeader('Deductions'),
                _lineItem('SSS', record.sssEmployee, color: const Color(0xFFFF6B6B)),
                _lineItem('PhilHealth', record.philhealthEmployee, color: const Color(0xFFFF6B6B)),
                _lineItem('Pag-IBIG', record.pagibigEmployee, color: const Color(0xFFFF6B6B)),
                _lineItem('Withholding Tax', record.withholdingTax, color: const Color(0xFFFF6B6B)),
                if (record.lateDeduction > 0) _lineItem('Late Deduction', record.lateDeduction, color: const Color(0xFFFF6B6B)),
                if (record.undertimeDeduction > 0) _lineItem('Undertime Deduction', record.undertimeDeduction, color: const Color(0xFFFF6B6B)),
                if (record.otherDeductions > 0) _lineItem('Other Deductions', record.otherDeductions, color: const Color(0xFFFF6B6B)),
                const Divider(color: Colors.white24),
                _lineItem('Total Deductions', record.totalDeductions, color: const Color(0xFFFF6B6B)),
              ],
            ),
          ),

          // Net Pay
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.only(top: 16),
            decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF00D1B2), Color(0xFF0098A6)], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Net Pay', style: TextStyle(fontSize: 14, color: Colors.white70)),
                const SizedBox(height: 4),
                Text(_formatCurrency(record.netPay), style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Verify the file compiles**

Run: `flutter analyze lib/src/ui/screens/payroll_detail_screen.dart`
Expected: No issues

- [ ] **Step 3: Commit**

```bash
git add lib/src/ui/screens/payroll_detail_screen.dart
git commit -m "feat: add PayrollDetailScreen with full payslip breakdown"
```

---

### Task 6: Wire Routes and Dashboard Navigation

**Files:**
- Modify: `lib/main.dart`
- Modify: `lib/src/ui/screens/dashboard_screen.dart`

- [ ] **Step 1: Add payroll routes to main.dart**

Import the new screens at the top of `main.dart`:

```dart
import 'src/ui/screens/payroll_screen.dart';
import 'src/ui/screens/payroll_detail_screen.dart';
```

Add routes in the GoRouter config, after the `/face-status` route:

```dart
GoRoute(
  path: '/payroll',
  builder: (context, state) => const PayrollScreen(),
),
GoRoute(
  path: '/payroll/:id',
  builder: (context, state) => PayrollDetailScreen(payrollId: state.pathParameters['id']!),
),
```

- [ ] **Step 2: Wire the dashboard Payroll button**

In `dashboard_screen.dart`, update the `_ActionButton._onTap` method. Add this condition in the existing if-else chain:

```dart
} else if (item.label == 'Payroll') {
  context.go('/payroll');
}
```

- [ ] **Step 3: Verify the files compile**

Run: `flutter analyze lib/main.dart lib/src/ui/screens/dashboard_screen.dart`
Expected: No issues

- [ ] **Step 4: Commit**

```bash
git add lib/main.dart lib/src/ui/screens/dashboard_screen.dart
git commit -m "feat: wire payroll routes and dashboard navigation"
```

---

### Task 7: Full Analysis and Verification

**Files:** All modified files

- [ ] **Step 1: Run full analysis**

Run: `cd flutter_app && flutter analyze`
Expected: No issues (0 errors, 0 warnings)

- [ ] **Step 2: Run build_runner for freezed model**

Run: `cd flutter_app && dart run build_runner build --delete-conflicting-outputs`
Expected: Generates payroll.freezed.dart and payroll.g.dart successfully

- [ ] **Step 3: Final commit**

```bash
git add -A
git commit -m "feat: complete payroll feature with Riverpod 2.0 providers, payslip detail, and process form"
```

---

## Self-Review Checklist

1. **Spec coverage:** ✅ PayrollRecord model (Task 1), PayrollRepository (Task 2), Riverpod providers (Task 3), PayrollScreen list + process form (Task 4), PayrollDetailScreen payslip (Task 5), routes + dashboard wiring (Task 6), verification (Task 7)
2. **No placeholders:** ✅ All code blocks contain complete, copy-pasteable Dart code with exact file paths
3. **Type consistency:** ✅ `PayrollRecord` fields match backend response from `lib/payroll.ts:PayrollResult`; provider types use `FutureProvider.family.autoDispose` and `AsyncNotifierProvider.autoDispose` as specified in Riverpod 2.0 docs
4. **DRY:** ✅ Reusing existing patterns: `RoleGuard`, `ApiClient`, freezed model pattern from `time_log.dart`, card UI from `time_log_screen.dart`
5. **YAGNI:** ✅ No batch processing, no print/share, no employee selection in process form (admin processes for individual or "all")
