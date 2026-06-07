// src/data/providers/employee_list_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hris_mobile/src/data/models/employee.dart';
import 'package:hris_mobile/src/data/providers/employee_repository.dart';
import '../../auth/auth_provider.dart';
import '../../auth/role_guard.dart';

class EmployeeListNotifier extends StateNotifier<AsyncValue<List<Employee>>> {
  final EmployeeRepository _repository;
  final RoleGuard _guard;

  EmployeeListNotifier(this._repository, this._guard) : super(const AsyncLoading()) {
    fetchEmployees();
  }

  Future<void> fetchEmployees() async {
    try {
      state = const AsyncLoading();
      List<Employee> employees = [];

      if (_guard.isAdmin) {
        employees = await _repository.getAll();
      } else if (_guard.currentEmployeeId != null) {
        employees = await _repository.getByEmployeeId(_guard.currentEmployeeId!);
      }

      state = AsyncData(employees);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> refresh() async => await fetchEmployees();
}

final employeeRepositoryProvider = Provider<EmployeeRepository>((ref) {
  return EmployeeRepository();
});

final employeeListProvider = StateNotifierProvider<EmployeeListNotifier, AsyncValue<List<Employee>>>(
  (ref) {
    final repository = ref.watch(employeeRepositoryProvider);
    final authState = ref.watch(authProvider);
    return EmployeeListNotifier(repository, RoleGuard(authState));
  },
);
