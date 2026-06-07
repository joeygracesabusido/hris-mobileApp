# Role-Based Access Control Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Restrict employees to viewing only their own data; admins retain full access to all data and features.

**Architecture:** A `RoleGuard` utility reads the user's role from `AuthState`. Each provider checks the guard before fetching data. The dashboard conditionally renders buttons and stats based on role. The employee list screen filters to self-only for employees.

**Tech Stack:** Flutter, Riverpod, Dart, GoRouter

---

### Task 1: Create RoleGuard Utility

**Files:**
- Create: `lib/src/auth/role_guard.dart`

- [ ] **Step 1: Write the RoleGuard class**

```dart
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
```

- [ ] **Step 2: Verify the file compiles**

Run: `flutter analyze lib/src/auth/role_guard.dart`
Expected: No issues

- [ ] **Step 3: Commit**

```bash
git add lib/src/auth/role_guard.dart
git commit -m "feat: add RoleGuard utility for role-based access control"
```

---

### Task 2: Add getByEmployeeId to EmployeeRepository

**Files:**
- Modify: `lib/src/data/providers/employee_repository.dart`

- [ ] **Step 1: Add the getByEmployeeId method**

Add this method to the `EmployeeRepository` class, after the `getAll()` method:

```dart
Future<List<Employee>> getByEmployeeId(String employeeId) async {
  final response = await _dio.get('/employees', queryParameters: {'employeeId': employeeId});
  final dynamic rawData = response.data;
  
  List<dynamic> data = [];
  if (rawData is List) {
    data = rawData;
  } else if (rawData is Map) {
    if (rawData['data'] is List) {
      data = rawData['data'];
    } else if (rawData['employees'] is List) {
      data = rawData['employees'];
    } else if (rawData['results'] is List) {
      data = rawData['results'];
    }
  }

  return data
      .map((e) => Employee.fromJson(e as Map<String, dynamic>))
      .toList();
}
```

- [ ] **Step 2: Verify the file compiles**

Run: `flutter analyze lib/src/data/providers/employee_repository.dart`
Expected: No issues

- [ ] **Step 3: Commit**

```bash
git add lib/src/data/providers/employee_repository.dart
git commit -m "feat: add getByEmployeeId to EmployeeRepository"
```

---

### Task 3: Update EmployeeListProvider with Role-Aware Fetching

**Files:**
- Modify: `lib/src/data/providers/employee_list_provider.dart`

- [ ] **Step 1: Add imports for auth**

Add these imports at the top of the file:

```dart
import '../../auth/auth_provider.dart';
import '../../auth/auth_state.dart';
import '../../auth/role_guard.dart';
```

- [ ] **Step 2: Update EmployeeListNotifier to accept AuthState and use RoleGuard**

Replace the entire `EmployeeListNotifier` class with:

```dart
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
```

- [ ] **Step 3: Update the provider to pass AuthState**

Replace the `employeeListProvider` definition with:

```dart
final employeeListProvider = StateNotifierProvider<EmployeeListNotifier, AsyncValue<List<Employee>>>(
  (ref) {
    final repository = ref.watch(employeeRepositoryProvider);
    final authState = ref.watch(authProvider);
    return EmployeeListNotifier(repository, RoleGuard(authState));
  },
);
```

- [ ] **Step 4: Verify the file compiles**

Run: `flutter analyze lib/src/data/providers/employee_list_provider.dart`
Expected: No issues

- [ ] **Step 5: Commit**

```bash
git add lib/src/data/providers/employee_list_provider.dart
git commit -m "feat: make EmployeeListProvider role-aware — admin sees all, employee sees self"
```

---

### Task 4: Update DashboardScreen with Conditional Rendering

**Files:**
- Modify: `lib/src/ui/screens/dashboard_screen.dart`

- [ ] **Step 1: Add the RoleGuard import**

Add this import at the top of the file:

```dart
import '../../auth/role_guard.dart';
```

- [ ] **Step 2: Add RoleGuard to the build method**

In `DashboardScreen.build()`, after reading `authState`, add:

```dart
final guard = RoleGuard(authState);
```

- [ ] **Step 3: Conditionally render stats row**

Replace `_QuickStatsRow()` with:

```dart
if (guard.isAdmin) _QuickStatsRow() else const SizedBox.shrink(),
```

And if showing the stats, add the spacing. If not showing stats, skip the `SizedBox(height: 24)` after it. The full replacement for lines 29-31 in the sliver list:

```dart
if (guard.isAdmin) ...[
  _QuickStatsRow(),
  const SizedBox(height: 24),
] else ...,
```

- [ ] **Step 4: Conditionally render Recent Activity section**

Wrap the "Recent Activity" section title and activity tiles with `guard.isAdmin`. Replace lines 33-55 with:

```dart
if (guard.isAdmin) ...[
  _SectionTitle(title: 'Recent Activity'),
  const SizedBox(height: 12),
  _ActivityTile(
    icon: Icons.person_add,
    title: 'New Employee Onboarded',
    subtitle: 'Juan dela Cruz joined as Software Engineer',
    time: '2 hours ago',
  ),
  _ActivityTile(
    icon: Icons.description,
    title: 'Leave Request Approved',
    subtitle: 'Maria Santos — Annual Leave (3 days)',
    time: '5 hours ago',
  ),
  _ActivityTile(
    icon: Icons.attach_money,
    title: 'Payroll Processed',
    subtitle: 'May 2026 payroll has been finalized',
    time: '1 day ago',
  ),
  const SizedBox(height: 32),
],
```

- [ ] **Step 5: Filter Quick Actions by role**

In `_QuickActionsGrid.build()`, replace the `actions` list with a filtered version. Replace lines 301-308 with:

```dart
final isEmployee = guard.isEmployee;
final actions = [
  _ActionItem(icon: Icons.fingerprint, label: 'Attendance', color: const Color(0xFF00D1B2)),
  _ActionItem(icon: Icons.fingerprint, label: 'Face Registration', color: const Color(0xFF6C63FF)),
  if (!isEmployee) ...[
    _ActionItem(icon: Icons.person_add, label: 'Add Employee', color: const Color(0xFF00D1B2)),
    _ActionItem(icon: Icons.event, label: 'Manage Leaves', color: const Color(0xFF6C63FF)),
    _ActionItem(icon: Icons.attach_money, label: 'Payroll', color: const Color(0xFFFF6B6B)),
  ],
  _ActionItem(icon: Icons.schedule, label: 'Time Logs', color: const Color(0xFFFFD93D)),
];
```

But `_QuickActionsGrid` doesn't have access to the guard. We need to pass it down. Update the `_QuickActionsGrid` class:

Add a `RoleGuard` parameter:

```dart
class _QuickActionsGrid extends StatelessWidget {
  final RoleGuard guard;
  const _QuickActionsGrid({required this.guard});
```

Then in `DashboardScreen.build()`, change `const _QuickActionsGrid()` to `_QuickActionsGrid(guard: guard)`.

- [ ] **Step 6: Verify the file compiles**

Run: `flutter analyze lib/src/ui/screens/dashboard_screen.dart`
Expected: No issues

- [ ] **Step 7: Commit**

```bash
git add lib/src/ui/screens/dashboard_screen.dart
git commit -m "feat: dashboard conditional rendering — hide admin-only buttons, stats, and activity from employees"
```

---

### Task 5: Update EmployeeListScreen for Employee Mode

**Files:**
- Modify: `lib/src/ui/screens/employee_list_screen.dart`

- [ ] **Step 1: Add the RoleGuard import**

Add this import at the top of the file:

```dart
import '../../auth/auth_provider.dart';
import '../../auth/role_guard.dart';
```

- [ ] **Step 2: Add search bar conditional rendering**

In `EmployeeListScreen.build()`, after reading `employeeAsync`, add:

```dart
final guard = RoleGuard(ref.watch(authProvider));
```

Then, wrap the search bar in a conditional. But the current screen doesn't have a search bar — it just lists employees. The search bar was added to TimeLogScreen, not EmployeeListScreen. So this step is just about ensuring the employee sees only their own card (which the provider now handles).

The screen itself needs no structural changes — the provider returns filtered data, and the screen renders whatever list it receives. The employee will see 1 card; admin will see all.

- [ ] **Step 3: Verify the file compiles**

Run: `flutter analyze lib/src/ui/screens/employee_list_screen.dart`
Expected: No issues

- [ ] **Step 4: Commit**

```bash
git add lib/src/ui/screens/employee_list_screen.dart
git commit -m "feat: employee list screen now shows self-only data for employees via provider filtering"
```

---

### Task 6: Full Analysis and Verification

**Files:** All modified files

- [ ] **Step 1: Run full analysis**

Run: `cd flutter_app && flutter analyze`
Expected: No issues (0 errors, 0 warnings)

- [ ] **Step 2: Run build_runner if needed**

If any model files were changed (they weren't in this plan), run:
```bash
cd flutter_app && dart run build_runner build --delete-conflicting-outputs
```

- [ ] **Step 3: Verify the app builds**

Run: `cd flutter_app && flutter build apk --debug`
Expected: Build succeeds with no errors

- [ ] **Step 4: Final commit**

```bash
git add -A
git commit -m "feat: role-based access control — employees see only their own data, admin sees all"
```

---

## Self-Review Checklist

1. **Spec coverage:** ✅ RoleGuard created, dashboard conditional rendering, employee list provider filtering, time logs already covered by existing code
2. **No placeholders:** ✅ All code blocks contain complete, copy-pasteable Dart code
3. **Type consistency:** ✅ `RoleGuard` uses same role field names as `AuthState` and `ApiClient` interceptor (`role`, `employeeId`, `id`, `_id`)
4. **DRY:** ✅ Reusing existing `AuthState` and provider patterns — no new providers needed
5. **YAGNI:** ✅ No route guards, no backend changes beyond what the API already supports
