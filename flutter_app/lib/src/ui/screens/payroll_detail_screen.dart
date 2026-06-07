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
          final record = payrolls.firstWhere((p) => p.id == payrollId, orElse: () => PayrollRecord(id: '', employeeId: '', month: 0, year: 0, periodStart: DateTime.now(), periodEnd: DateTime.now()));
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
