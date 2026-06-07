// lib/src/auth/role_guard.dart
import 'auth_state.dart';

class RoleGuard {
  final AuthState state;
  RoleGuard(this.state);

  String get role => (state.user?['role'] ?? 'employee').toString().toLowerCase();
  bool get isAdmin => role == 'admin';
  bool get isEmployee => role == 'employee';

  /// Returns the current user's employee ID for filtering queries.
  String? get currentEmployeeId {
    final u = state.user;
    return u?['employeeId']?.toString() ??
           u?['employeeNumber']?.toString() ??
           u?['id']?.toString() ??
           u?['_id']?.toString();
  }
}
