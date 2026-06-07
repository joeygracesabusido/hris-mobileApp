# Time Logs Page Implementation Plan

> **For agentic workers:** Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a time logs page to the Flutter HRIS mobile app that displays employee time logs from the backend API.

**Architecture:** Follow existing patterns — freezed model for `TimeLog`, Dio repository, Riverpod StateNotifier provider, and a new screen wired into GoRouter. The dashboard's existing "Time Logs" quick action button navigates to the new screen.

**Tech Stack:** Flutter, freezed, dio, flutter_riverpod, go_router

---

### Task 1: TimeLog Freezed Model

**Files:**
- Create: `lib/src/data/models/time_log.dart`

**Fields (based on GET /api/time-logs response):**
- `id` (String), `employeeId` (String), `date` (DateTime), `clockIn` (DateTime?), `clockOut` (DateTime?)
- `workHours` (double), `otHours` (double), `lateMinutes` (int), `undertimeMinutes` (int)
- `notes` (String?), `isEdited` (bool), `editedBy` (String?), `editReason` (String?)
- Nested: `employee` (TimeLogEmployee with fullName, employeeId), `shift` (TimeLogShift?), `holiday` (dynamic?)

- [ ] **Create the freezed model file**

### Task 2: TimeLogRepository

**Files:**
- Create: `lib/src/data/providers/time_log_repository.dart`

**Methods:**
- `getAll()` — GET /time-logs
- `getByEmployeeId(String employeeId)` — GET /time-logs?employeeId=...
- `delete(String id)` — DELETE /time-logs?id=...
- `clockIn(String employeeId)` — POST /time-logs {type: "clockIn"}
- `clockOut(String employeeId)` — POST /time-logs {type: "clockOut"}

- [ ] **Create the repository file**

### Task 3: TimeLogListProvider

**Files:**
- Create: `lib/src/data/providers/time_log_list_provider.dart`

Follow the exact pattern of `employee_list_provider.dart` — StateNotifier with AsyncValue.

- [ ] **Create the provider file**

### Task 4: TimeLogScreen

**Files:**
- Create: `lib/src/ui/screens/time_log_screen.dart`

Display time logs in card list showing: employee name, date, clock-in, clock-out, work hours, late/undertime badges. Pull-to-refresh support.

- [ ] **Create the screen file**

### Task 5: Wire GoRouter Route

**Files:**
- Modify: `lib/main.dart`

Add `/time-logs` route pointing to `TimeLogScreen`.

- [ ] **Add the GoRoute entry**

### Task 6: Wire Dashboard Button

**Files:**
- Modify: `lib/src/ui/screens/dashboard_screen.dart`

Add `onTap` to the "Time Logs" action button → context.go('/time-logs').

- [ ] **Add navigation to the Time Logs button**

### Task 7: Code Generation

- [ ] **Run `dart run build_runner build --delete-conflicting-outputs`**
- [ ] **Run `flutter analyze` to verify no errors**
