import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hris_mobile/src/data/models/time_log.dart';
import 'package:hris_mobile/src/data/providers/time_log_repository.dart';

final timeLogRepositoryProvider = Provider<TimeLogRepository>((ref) {
  return TimeLogRepository();
});

/// Fetches time logs. Pass null for employeeId to fetch all (admin).
/// Auto-disposes when no longer watched. Caches per employeeId key.
final timeLogListProvider =
    FutureProvider.family<List<TimeLog>, String?>(
  (ref, employeeId) async {
    final repository = ref.watch(timeLogRepositoryProvider);
    if (employeeId == null) {
      return repository.getAll();
    }
    return repository.getByEmployeeId(employeeId);
  },
);
