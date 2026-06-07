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
  ProcessPayrollNotifier.new,
);

class ProcessPayrollNotifier extends AutoDisposeAsyncNotifier<PayrollRecord?> {
  late final PayrollRepository _repo;

  @override
  Future<PayrollRecord?> build() async {
    _repo = ref.watch(payrollRepositoryProvider);
    return null;
  }

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
