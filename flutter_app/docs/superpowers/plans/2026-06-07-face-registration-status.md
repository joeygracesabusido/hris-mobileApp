# Face Registration Status Screen Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a Face Registration button to the Dashboard Quick Actions grid that navigates to a new status screen showing enrollment details with Enroll/Re-enroll action.

**Architecture:** New backend endpoint `GET /api/face/status` checks MongoDB for the logged-in employee's face descriptor. Flutter `FaceStatusScreen` displays enrollment state (enrolled/not enrolled) with formatted date, employee name, and a teal action button. Dashboard `_QuickActionsGrid` adds a 6th item using `Icons.fingerprint` in purple, wrapped in horizontal scroll.

**Tech Stack:** Next.js API Routes, Prisma, Flutter, Dio, GoRouter

---

### Task 1: Backend — `GET /api/face/status` endpoint

**Files:**
- Create: `E:\hris-maam-jhoy\app\api\face\status\route.ts`

- [ ] **Step 1: Create the route file with auth, lookup, and response logic**

Write this file:

```ts
import { NextRequest, NextResponse } from 'next/server';
import prisma from '@/lib/prisma';
import { getRequestSession } from '@/lib/auth-helpers';

export const dynamic = 'force-dynamic';

/**
 * GET /api/face/status
 *
 * Returns the face enrollment status for the authenticated employee.
 * Response:
 *   Enrolled:  { enrolled: true,  employeeName: string, enrolledAt: string }
 *   Not:       { enrolled: false, employeeName: string }
 */
export async function GET(request: NextRequest) {
  try {
    // Authenticate
    let userEmail: string;
    try {
      const session = await getRequestSession(request);
      userEmail = session.userEmail;
    } catch {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }

    // Look up employee by email
    const employee = await prisma.employee.findFirst({
      where: { email: userEmail },
      select: {
        fullName: true,
        faceDescriptor: true,
        faceEnrolledAt: true,
      },
    });

    if (!employee) {
      return NextResponse.json(
        { error: 'Employee not found' },
        { status: 404 }
      );
    }

    const hasDescriptor =
      employee.faceDescriptor && (employee.faceDescriptor as number[]).length > 0;

    if (hasDescriptor) {
      return NextResponse.json({
        enrolled: true,
        employeeName: employee.fullName ?? '',
        enrolledAt: employee.faceEnrolledAt
          ? new Date(employee.faceEnrolledAt).toISOString()
          : null,
      });
    }

    return NextResponse.json({
      enrolled: false,
      employeeName: employee.fullName ?? '',
    });
  } catch (error) {
    console.error('[Face Status API] Error:', error);
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    );
  }
}
```

- [ ] **Step 2: Test the endpoint manually**

Run the backend (`npm run dev`), authenticate via browser, then curl or fetch `GET /api/face/status` and verify the response shape matches the spec.

- [ ] **Step 3: Commit**

```bash
git add app/api/face/status/route.ts
git commit -m "feat(backend): add GET /api/face/status endpoint for enrollment status"
```

---

### Task 2: Flutter — `FaceEnrollmentStatus` model + `getEnrollmentStatus()` in FaceRepository

**Files:**
- Modify: `E:\hris-mobileApp\flutter_app\lib\src\data\providers\face_repository.dart`

- [ ] **Step 1: Add the `FaceEnrollmentStatus` model class**

Add after the existing `FaceVerificationEmployee` class (after line 48):

```dart
class FaceEnrollmentStatus {
  final bool enrolled;
  final String employeeName;
  final DateTime? enrolledAt;

  FaceEnrollmentStatus({
    required this.enrolled,
    required this.employeeName,
    this.enrolledAt,
  });

  factory FaceEnrollmentStatus.fromJson(Map<String, dynamic> json) {
    return FaceEnrollmentStatus(
      enrolled: json['enrolled'] as bool? ?? false,
      employeeName: json['employeeName'] as String? ?? '',
      enrolledAt: json['enrolledAt'] != null
          ? DateTime.parse(json['enrolledAt'] as String)
          : null,
    );
  }
}
```

- [ ] **Step 2: Add the `getEnrollmentStatus` method to `FaceRepository`**

Add inside the `FaceRepository` class (after the `verifyFace` method, before closing brace):

```dart
  /// Checks the face enrollment status for the authenticated employee.
  Future<FaceEnrollmentStatus> getEnrollmentStatus() async {
    final response = await _dio.get('/face/status');
    return FaceEnrollmentStatus.fromJson(response.data as Map<String, dynamic>);
  }
```

- [ ] **Step 3: Run `flutter analyze` to verify no issues**

Run: `flutter analyze` in the `flutter_app` directory. Expected: 0 issues.

- [ ] **Step 4: Commit**

```bash
git add lib/src/data/providers/face_repository.dart
git commit -m "feat(fluent): add FaceEnrollmentStatus model and getEnrollmentStatus() method"
```

---

### Task 3: Flutter — `FaceStatusScreen` 

**Files:**
- Create: `E:\hris-mobileApp\flutter_app\lib\src\ui\screens\face_status_screen.dart`

- [ ] **Step 1: Create the screen file with all three states (loading, enrolled, not enrolled) and error handling**

Write this file:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/providers/face_repository.dart';
import '../widgets/app_theme.dart';

class FaceStatusScreen extends ConsumerStatefulWidget {
  const FaceStatusScreen({super.key});

  @override
  ConsumerState<FaceStatusScreen> createState() => _FaceStatusScreenState();
}

class _FaceStatusScreenState extends ConsumerState<FaceStatusScreen> {
  final FaceRepository _faceRepo = FaceRepository();
  FaceEnrollmentStatus? _status;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchStatus();
  }

  Future<void> _fetchStatus() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final status = await _faceRepo.getEnrollmentStatus();
      setState(() {
        _status = status;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  String _formatDate(DateTime dt) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final month = months[dt.month - 1];
    final day = dt.day.toString();
    final year = dt.year.toString();

    int hour = dt.hour;
    final period = hour >= 12 ? 'PM' : 'AM';
    if (hour > 12) hour -= 12;
    if (hour == 0) hour = 12;
    final minute = dt.minute.toString().padLeft(2, '0');

    return '$month $day, $year $hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Face Registration'),
        backgroundColor: AppTheme.primary,
        leading: IconButton(
          icon: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(25),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
          ),
          onPressed: () => context.go('/dashboard'),
        ),
      ),
      backgroundColor: AppTheme.background,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Color(0xFF00D1B2)),
            SizedBox(height: 16),
            Text(
              'Checking enrollment status...',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, color: const Color(0xFFFF6B6B), size: 48),
              const SizedBox(height: 16),
              const Text(
                'Unable to check enrollment status',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _fetchStatus,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00D1B2),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_status == null) {
      return const Center(
        child: Text(
          'Unexpected error',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Enrollment Status',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Employee: ${_status!.employeeName}',
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _status!.enrolled
                  ? const Color(0xFF00D1B2).withAlpha(25)
                  : const Color(0xFFFF6B6B).withAlpha(25),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _status!.enrolled
                    ? const Color(0xFF00D1B2).withAlpha(80)
                    : const Color(0xFFFF6B6B).withAlpha(80),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _status!.enrolled ? Icons.check_circle : Icons.info_outline,
                      color: _status!.enrolled
                          ? const Color(0xFF00D1B2)
                          : const Color(0xFFFF6B6B),
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _status!.enrolled ? 'Enrolled' : 'Not Enrolled',
                      style: TextStyle(
                        color: _status!.enrolled
                            ? const Color(0xFF00D1B2)
                            : const Color(0xFFFF6B6B),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if (_status!.enrolled && _status!.enrolledAt != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Enrolled on ${_formatDate(_status!.enrolledAt!)}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
                if (!_status!.enrolled) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'You haven\'t enrolled your face yet. Enroll now to use face verification for attendance.',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => context.go('/face-enroll'),
                  icon: Icon(
                    _status!.enrolled ? Icons.refresh : Icons.face,
                    size: 18,
                  ),
                  label: Text(
                    _status!.enrolled ? 'Re-enroll Face' : 'Enroll Now',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00D1B2),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Run `flutter analyze` to verify no issues**

Run: `flutter analyze` in the `flutter_app` directory. Expected: 0 issues.

- [ ] **Step 3: Commit**

```bash
git add lib/src/ui/screens/face_status_screen.dart
git commit -m "feat(fluent): add FaceStatusScreen with enrolled/not-enrolled states"
```

---

### Task 4: Flutter — Add route + Dashboard Quick Action button

**Files:**
- Modify: `E:\hris-mobileApp\flutter_app\lib\main.dart`
- Modify: `E:\hris-mobileApp\flutter_app\lib\src\ui\screens\dashboard_screen.dart`

- [ ] **Step 1: Add the import for `FaceStatusScreen` in `main.dart`**

Find the existing imports section and add:

```dart
import 'src/ui/screens/face_status_screen.dart';
```

- [ ] **Step 2: Add the `/face-status` route in `main.dart`**

Add a new route entry near the existing routes (after `/face-enroll`):

```dart
GoRoute(
  path: '/face-status',
  builder: (context, state) => const FaceStatusScreen(),
),
```

- [ ] **Step 3: Add the 6th Quick Action item in `dashboard_screen.dart`**

In `_QuickActionsGrid.build()`, add a new `_ActionItem` to the `actions` list:

```dart
final actions = [
  _ActionItem(icon: Icons.fingerprint, label: 'Attendance', color: const Color(0xFF00D1B2)),
  _ActionItem(icon: Icons.fingerprint, label: 'Face Registration', color: const Color(0xFF6C63FF)),
  _ActionItem(icon: Icons.person_add, label: 'Add Employee', color: const Color(0xFF00D1B2)),
  _ActionItem(icon: Icons.event, label: 'Manage Leaves', color: const Color(0xFF6C63FF)),
  _ActionItem(icon: Icons.attach_money, label: 'Payroll', color: const Color(0xFFFF6B6B)),
  _ActionItem(icon: Icons.schedule, label: 'Time Logs', color: const Color(0xFFFFD93D)),
];
```

- [ ] **Step 4: Add navigation handler for "Face Registration" in `_ActionButton._onTap()`**

Update the method to handle the new label:

```dart
void _onTap(BuildContext context) {
  if (item.label == 'Attendance') {
    context.go('/attendance');
  } else if (item.label == 'Time Logs') {
    context.go('/time-logs');
  } else if (item.label == 'Face Registration') {
    context.go('/face-status');
  }
}
```

- [ ] **Step 5: Wrap the `_QuickActionsGrid` Row in a horizontal `SingleChildScrollView`**

In `_QuickActionsGrid.build()`, change the `Row` to be inside a scroll view:

```dart
return SingleChildScrollView(
  scrollDirection: Axis.horizontal,
  child: Row(
    children: actions.map((action) {
      return Expanded(
        flex: 1,
        child: Padding(
          padding: EdgeInsets.only(
            left: action == actions.first ? 0 : 6,
            right: action == actions.last ? 0 : 6,
          ),
          child: _ActionButton(item: action),
        ),
      );
    }).toList(),
  ),
);
```

- [ ] **Step 6: Run `flutter analyze` to verify no issues**

Run: `flutter analyze` in the `flutter_app` directory. Expected: 0 issues.

- [ ] **Step 7: Commit**

```bash
git add lib/main.dart lib/src/ui/screens/dashboard_screen.dart
git commit -m "feat(fluent): add Face Registration button to dashboard and /face-status route"
```

---

### Task 5: Verification — full build check

**Files:** none (verification only)

- [ ] **Step 1: Run `flutter analyze`**

Run: `flutter analyze` in the `flutter_app` directory. Expected: 0 issues.

- [ ] **Step 2: Run `flutter build apk --debug`**

Run: `flutter build apk --debug` in the `flutter_app` directory. Expected: builds successfully with no errors.

- [ ] **Step 3: Manual smoke test checklist (on device)**

When running the app on SM-A075F:
1. Dashboard shows 6 Quick Action items, horizontal scroll works
2. Tapping "Face Registration" navigates to `/face-status`
3. If enrolled: green card shows name + enrollment date + "Re-enroll Face" button
4. If not enrolled: red card shows message + "Enroll Now" button
5. Tapping either button navigates to `/face-enroll`
6. Back button on status screen returns to `/dashboard`
