# Role-Based Access Control — Design Spec

## Date
2026-06-07

## Problem
Currently, all authenticated users (admin and employee) have full access to all data and features. Employees should only see their own data and a limited set of actions. Admins retain full access.

## Existing State
- Auth system stores `role` in `AuthState.user` map (`auth_state.dart`)
- `X-Auth-Role` header is already sent with every API request via ApiClient interceptor
- Time Log screen already has role-based filtering: admin sees all, employee sees own (`time_log_list_provider.dart:36-40`)
- Dashboard shows all buttons and stats to all users

## Design

### 1. RoleGuard Utility

**File:** `lib/src/auth/role_guard.dart`

A lightweight utility that reads the current user's role from the auth state:

```dart
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
```

No new provider needed — each screen constructs a `RoleGuard` from the current `AuthState`.

### 2. Dashboard Changes

**File:** `lib/src/ui/screens/dashboard_screen.dart`

- Read role via `RoleGuard(ref.watch(authProvider))`
- **Stats row (`_QuickStatsRow`)**: wrap in `guard.isAdmin ? _QuickStatsRow() : const SizedBox.shrink()`
- **Recent Activity section**: same guard — only admin sees it
- **Quick Actions grid**: filter the `actions` list:

| Button | Admin | Employee |
|---|---|---|
| Attendance | ✓ | ✓ |
| Face Registration | ✓ | ✓ |
| Add Employee | ✓ | ✗ |
| Manage Leaves | ✓ | ✗ |
| Payroll | ✓ | ✗ |
| Time Logs | ✓ | ✓ |

### 3. Employee List Provider Changes

**File:** `lib/src/data/providers/employee_list_provider.dart`

Update `EmployeeListNotifier` to accept `AuthState` (same pattern as `TimeLogListNotifier`):

- If admin: call `_repository.getAll()` → show all employees
- If employee: call `_repository.getByEmployeeId(currentEmployeeId)` → show single card with own data
- Remove search bar from employee list screen when in employee mode (only 1 result)

### 4. Employee List Screen Changes

**File:** `lib/src/ui/screens/employee_list_screen.dart`

- Pass a flag or use the provider to determine if it's showing self-only vs all employees
- If employee: no search bar, single card displayed
- If admin: unchanged behavior (all employees, with search)

### 5. Time Log Screen

**No changes needed.** Already has correct role-based filtering in `time_log_list_provider.dart`.

### 6. Error Handling

- If API returns 403/404 for an employee trying to access other data, show "You don't have permission to view this data"
- Same `AsyncError` handling as existing code — no new error state type needed

## Data Flow

```
AuthState (role) → RoleGuard → Provider (filter by role) → Screen (render based on data)
```

Each screen reads auth state, constructs a RoleGuard, and the provider uses it to decide what data to fetch. The screen renders whatever data the provider returns.

## Testing Approach

- Verify admin sees all buttons, stats, all employees, all time logs
- Verify employee sees limited buttons, no stats, only own employee card, only own time logs
- No automated tests needed for this change — manual verification on device

## Files to Create

- `lib/src/auth/role_guard.dart`

## Files to Modify

- `lib/src/ui/screens/dashboard_screen.dart` — conditional rendering based on role
- `lib/src/data/providers/employee_list_provider.dart` — role-aware data fetching
- `lib/src/ui/screens/employee_list_screen.dart` — conditional search bar for employee mode
