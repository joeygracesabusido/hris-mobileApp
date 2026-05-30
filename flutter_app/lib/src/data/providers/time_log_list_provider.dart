import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hris_mobile/src/data/models/time_log.dart';
import 'package:hris_mobile/src/data/providers/time_log_repository.dart';
import '../../auth/auth_provider.dart';
import '../../auth/auth_state.dart';

class TimeLogListNotifier extends StateNotifier<AsyncValue<List<TimeLog>>> {
  final TimeLogRepository _repository;
  final AuthState _authState;

  TimeLogListNotifier(this._repository, this._authState) : super(const AsyncLoading()) {
    fetchTimeLogs();
  }

  Future<void> fetchTimeLogs() async {
    if (!_authState.isAuthenticated) {
      state = const AsyncData([]);
      return;
    }

    try {
      state = const AsyncLoading();
      
      final user = _authState.user;
      final role = user?['role']?.toString().toLowerCase() ?? 'employee';
      
      // Try multiple possible ID fields from the user object
      final employeeId = user?['employeeId']?.toString() ?? 
                         user?['employeeNumber']?.toString() ?? 
                         user?['id']?.toString() ?? 
                         user?['_id']?.toString();

      List<TimeLog> timeLogs = [];
      
      try {
        if (role == 'admin') {
          timeLogs = await _repository.getAll();
        } else if (employeeId != null) {
          timeLogs = await _repository.getByEmployeeId(employeeId);
        }
      } catch (e) {
        // If specific fetch fails, try fetching all as a fallback if role might be admin
        if (role == 'admin') {
          timeLogs = await _repository.getAll();
        } else {
          rethrow;
        }
      }

      state = AsyncData(timeLogs);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> refresh() async => await fetchTimeLogs();
}

final timeLogRepositoryProvider = Provider<TimeLogRepository>((ref) {
  return TimeLogRepository();
});

final timeLogListProvider =
    StateNotifierProvider<TimeLogListNotifier, AsyncValue<List<TimeLog>>>(
  (ref) {
    final repository = ref.watch(timeLogRepositoryProvider);
    final authState = ref.watch(authProvider);
    return TimeLogListNotifier(repository, authState);
  },
);
