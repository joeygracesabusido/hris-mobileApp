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
              Text('Failed to load payroll data',
                  style: TextStyle(color: AppTheme.textSecondary)),
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
                  const Icon(Icons.receipt_long_outlined,
                      size: 64, color: Colors.grey),
                  const SizedBox(height: 12),
                  Text('No payroll records found',
                      style: TextStyle(color: AppTheme.textSecondary)),
                  if (guard.isAdmin) ...[
                    const SizedBox(height: 8),
                    Text('Tap + to process payroll',
                        style: TextStyle(color: AppTheme.textSecondary)),
                  ],
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async =>
                ref.invalidate(payrollListProvider(employeeId)),
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
  String _formatCurrency(double amount) =>
      NumberFormat.currency(symbol: '₱', decimalDigits: 2).format(amount);

  @override
  Widget build(BuildContext context) {
    final empName =
        record.employee?['fullName'] as String? ?? 'Unknown';
    return GestureDetector(
      onTap: () => context.go('/payroll/${record.id}'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                    _formatPeriod(record.periodStart),
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                Icon(Icons.chevron_right,
                    color: Colors.white.withAlpha(100), size: 20),
              ],
            ),
            if (record.employee != null) ...[
              const SizedBox(height: 4),
              Text(empName,
                  style:
                      TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
            ],
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Net Pay',
                          style: TextStyle(
                              color: AppTheme.textSecondary, fontSize: 11)),
                      Text(
                          _formatCurrency(record.netPay),
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF00D1B2))),
                    ]),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: (record.status == 'PROCESSED'
                            ? const Color(0xFF00D1B2)
                            : Colors.orange)
                        .withAlpha(30),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: (record.status == 'PROCESSED'
                                ? const Color(0xFF00D1B2)
                                : Colors.orange)
                            .withAlpha(80)),
                  ),
                  child: Text(
                      record.status,
                      style: TextStyle(
                          color: record.status == 'PROCESSED'
                              ? const Color(0xFF00D1B2)
                              : Colors.orange,
                          fontSize: 11,
                          fontWeight: FontWeight.w600)),
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
  ConsumerState<_ProcessPayrollSheet> createState() =>
      _ProcessPayrollSheetState();
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
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Process Payroll',
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              const SizedBox(height: 20),

              ListTile(
                title: Text('Start Date',
                    style: const TextStyle(color: Colors.white)),
                subtitle: Text(DateFormat('MMM dd, yyyy').format(_startDate),
                    style: TextStyle(color: AppTheme.textSecondary)),
                onTap: () async {
                  final date = await showDatePicker(
                      context: context,
                      initialDate: _startDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030));
                  if (date != null) setState(() => _startDate = date);
                },
              ),

              ListTile(
                title: Text('End Date',
                    style: const TextStyle(color: Colors.white)),
                subtitle: Text(DateFormat('MMM dd, yyyy').format(_endDate),
                    style: TextStyle(color: AppTheme.textSecondary)),
                onTap: () async {
                  final date = await showDatePicker(
                      context: context,
                      initialDate: _endDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030));
                  if (date != null) setState(() => _endDate = date);
                },
              ),

              DropdownButtonFormField<String>(
                initialValue: _frequency,
                decoration: InputDecoration(
                    labelText: 'Frequency',
                    labelStyle: const TextStyle(color: Colors.white),
                    filled: true,
                    fillColor: AppTheme.cardBackground),
                items: ['MONTHLY', 'SEMIMONTHLY']
                    .map((f) => DropdownMenuItem(
                        value: f,
                        child:
                            Text(f, style: const TextStyle(color: Colors.white))))
                    .toList(),
                onChanged: (v) => setState(() => _frequency = v!),
              ),

              const SizedBox(height: 20),

              computeState.when(
                data: (result) {
                  if (result == null) return const SizedBox.shrink();
                  return Column(
                    children: [
                      Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                              color: Colors.green.withAlpha(30),
                              borderRadius: BorderRadius.circular(12)),
                          child: Text(
                              'Payroll computed! Net pay: ₱${result.netPay.toStringAsFixed(2)}',
                              style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold))),
                      const SizedBox(height: 12),
                      ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            ref.invalidate(payrollListProvider(null));
                          },
                          child: const Text('View Payroll')),
                    ],
                  );
                },
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (err, _) => Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        color: Colors.red.withAlpha(30),
                        borderRadius: BorderRadius.circular(12)),
                    child: Text('Error: $err',
                        style: const TextStyle(color: Colors.red))),
                skipLoadingOnReload: true,
                skipError: true,
              ),
              if (computeState.valueOrNull == null && !computeState.isLoading && computeState.hasError == false)
                SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                        onPressed: _handleCompute,
                        child: const Text('Compute Payroll'))),
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
