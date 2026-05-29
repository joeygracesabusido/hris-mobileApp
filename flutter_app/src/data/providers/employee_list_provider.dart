// src/data/providers/employee_list_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/employee.dart';
import '../employee_repository.dart';

/// A [StateNotifier] that loads the list of employees and exposes it as an
/// [AsyncValue]. It supports refresh and basic error handling.
class EmployeeListNotifier extends StateNotifier<AsyncValue<List<Employee>>> {
  final EmployeeRepository _repository;

  EmployeeListNotifier(this._repository) : super(const AsyncLoading()) {
    // Load on creation
    fetchEmployees();
  }

  /// Fetches all employees from the backend.
  Future<void> fetchEmployees() async {
    try {
      state = const AsyncLoading();
      final employees = await _repository.getAll();
      state = AsyncData(employees);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  /// Refreshes the list – useful for pull‑to‑refresh UI.
  Future<void> refresh() async => await fetchEmployees();
}

/// Provider for the repository – a single instance for the whole app.
final employeeRepositoryProvider = Provider<EmployeeRepository>((ref) {
  return EmployeeRepository();
});

/// StateNotifierProvider exposing the employee list.
final employeeListProvider = StateNotifierProvider<EmployeeListNotifier, AsyncValue<List<Employee>>>(
  (ref) => EmployeeListNotifier(ref.watch(employeeRepositoryProvider)),
);
