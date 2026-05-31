# HRIS Mobile App — AGENTS.md

## Project structure

```
├── lib/
│   ├── main.dart                          # App entry, MaterialApp.router with GoRouter + Riverpod
│   └── src/
│       ├── auth/                          # AuthNotifier + AuthState + authProvider
│       ├── data/
│       │   ├── models/                    # Freezed models: employee.dart, time_log.dart (+ .freezed.dart / .g.dart)
│       │   └── providers/                 # ApiClient (Dio singleton), EmployeeRepository, TimeLogRepository, providers
│       └── ui/
│           ├── screens/                   # dashboard_screen.dart, employee_list_screen.dart, time_log_screen.dart
│           └── widgets/                   # app_theme.dart
    ├── assets/images/                         # Must exist on disk (declared in pubspec.yaml); contains .gitkeep
    ├── .env                                   # Required at flutter_app root for flutter_dotenv
    └── test/widget_test.dart                  # Default template — not useful, will fail for this app
```

## State & routing

- **Riverpod** (`flutter_riverpod`) — `NotifierProvider` for auth, `StateNotifierProvider` for employee list
- **GoRouter** — routes: `/login`, `/dashboard`, `/employees`, `/time-logs`; redirect logic in `main.dart` guards auth state
- Auth persisted via `FlutterSecureStorage` (mobile) / `SharedPreferences` (web)

## Commands

```sh
# Run app
flutter run

# Code generation (freezed / json_serializable)
dart run build_runner build --delete-conflicting-outputs

# Analyze
flutter analyze

# Tests (only widget_test.dart exists, needs real tests)
flutter test
```

## Known quirks

- `assets/images/` must exist on disk or Flutter errors. Keep `.gitkeep` if empty.
- `.env` file at `flutter_app/.env` with `API_BASE_URL` key is loaded at startup.
- Generated files (`*.freezed.dart`, `*.g.dart`) are checked in — run `build_runner` after editing model classes.
- `debugShowCheckedModeBanner: false` set in `main.dart:76`.
- `lib/src/.keep` and `lib/src/ui/screens/.keep` are structural placeholders.
- **Cookie forwarding**: Backend API uses cookie-based auth (Set-Cookie on login, checked on every request). Flutter's Dio doesn't auto-forward cookies. `ApiClient` has an interceptor that injects `X-Auth-Id`, `X-Auth-Role`, `X-Auth-Email` headers built from the stored `user_data` (set in `auth_notifier.dart:_setAuthHeaders`). Backend helper `getRequestSession` in `E:\hris-maam-jhoy\lib\auth-helpers.ts` falls back to these headers when cookies aren't present (for Flutter web where `Cookie` header is forbidden). If you add new API routes, ensure the interceptor or cookie setup covers them.

### 2026-05-30 — Time logs UX + timezone display fix

**Goal:** Improve TimeLogScreen UX (navigation, search) and fix wrong In/Out time display (3:57 PM instead of 7:57 AM).

**Done:**
- Added styled back button in TimeLogScreen AppBar navigating to `/dashboard`
- Converted `TimeLogScreen` from `ConsumerWidget` to `ConsumerStatefulWidget` for search state
- Added search `TextField` filtering time logs by employee name or employee ID (case-insensitive, as-you-type)
- Fixed In/Out time showing +8 hours: removed `_toManila` / `_manilaOffset` from display helpers
  - Root cause: backend `getManilaNow()` stores Manila wall-clock timestamps as Date objects (parsed as UTC by server). Adding +8h in Flutter doubled the offset.
  - Backend `getManilaNow()` left unchanged — day-boundary logic in `getManilaToday()` depends on internal consistency of this approach.

**Files modified:**
- `flutter_app/lib/src/ui/screens/time_log_screen.dart` — back button, search, removed timezone conversion

## Session history

### 2026-05-30 — Time logs page + auth fix

**Goal:** Add employee time logs page to Flutter app. Debugged blank screen (401).

**Done:**
- Created `time_log.dart` (freezed model with `TimeLogEmployee`, `TimeLogShift`), `time_log_repository.dart`, `time_log_list_provider.dart`, `time_log_screen.dart`
- Added `/time-logs` route in `main.dart` + wired dashboard "Time Logs" button
- Debugged blank display: backend cookie auth not forwarded by Dio; `Cookie` is a forbidden header on web
- Fixed: switched to custom `X-Auth-Id`, `X-Auth-Role`, `X-Auth-Email` headers in `ApiClient` interceptor and `auth_notifier.dart`
- Added `getRequestSession()` helper in backend (`lib/auth-helpers.ts`) — checks cookies first, falls back to `X-Auth-*` headers
- Updated `/api/time-logs` and `/api/employees` routes (GET, POST, PUT, DELETE) to use `getRequestSession()`

**Files created:**
- `flutter_app/lib/src/data/models/time_log.dart`
- `flutter_app/lib/src/data/providers/time_log_repository.dart`
- `flutter_app/lib/src/data/providers/time_log_list_provider.dart`
- `flutter_app/lib/src/ui/screens/time_log_screen.dart`

**Files modified (Flutter):**
- `main.dart`, `dashboard_screen.dart`, `api_client.dart`, `auth_notifier.dart`

**Files modified (Backend — `hris-maam-jhoy/`):**
- `lib/auth-helpers.ts`, `app/api/time-logs/route.ts`, `app/api/employees/route.ts`

### 2026-05-31 — Attendance with Facial Recognition + GPS

**Goal:** Add attendance feature with GPS geofence validation and on-device facial recognition.

**Done:**
- Added "Attendance" button on dashboard → navigates to `/attendance`
- Created `AttendanceScreen` with GPS check (geolocator + Haversine vs OfficeLocation geofences)
- Created `FaceCaptureWidget` — reusable camera + ML Kit face detection + TFLite MobileFaceNet embedding
- Created `FaceEnrollScreen` — enroll face from mobile (stores 128-dim descriptor to backend)
- On-device ML pipeline: `camera` → `google_mlkit_face_detection` → `tflite_flutter` (MobileFaceNet) → 128-dim embedding → Euclidean distance (< 0.6)
- Backend office-location routes updated to support X-Auth headers for Flutter requests
- GPS coords sent with clockIn/clockOut for server-side geofence validation
- TFLite model bundled at `assets/ml/mobile_face_net.tflite` (~5.2MB)

**New files (Flutter):**
- `lib/src/data/providers/face_repository.dart` — face descriptor API
- `lib/src/ui/widgets/face_capture_widget.dart` — camera + ML Kit + TFLite
- `lib/src/ui/screens/attendance_screen.dart` — main attendance flow
- `lib/src/ui/screens/face_enroll_screen.dart` — face enrollment

**Modified files (Flutter):**
- `pubspec.yaml` — added geolocator, camera, google_mlkit_face_detection, tflite_flutter, permission_handler, image
- `lib/main.dart` — added `/attendance`, `/face-enroll` routes
- `lib/src/ui/screens/dashboard_screen.dart` — Attendance button
- `lib/src/data/providers/time_log_repository.dart` — GPS params on clockIn/clockOut
- `android/app/src/main/AndroidManifest.xml` — CAMERA + LOCATION permissions

**Modified files (Backend):**
- `app/api/office-location/route.ts` — all methods use `getRequestSession()` for X-Auth header support

### 2026-05-31 — Face verification fix on Samsung SM-A075F

**Goal:** Fix face detection/verification pipeline on Samsung SM-A075F (Galaxy A07, MediaTek Helio P25).

**Done:**
- Fixed `_buildInputImage` bytesPerRow for multi-plane YUV_420_888 → NV21 conversion: Samsung camera HAL delivers YUV_420_888 even when NV21 is requested; `bytesPerRow` must be `image.width` (not the padded stride from the sensor) because `_yuv420ToNv21` produces a compact buffer.
- Fixed `_cameraImageToImg` stride padding for native single-plane NV21: use `cameraImage.planes[0].bytesPerRow` as `yRowStride` instead of assuming `bytesPerRow == width`. SM-A075F delivers NV21 with stride padding, so the old `y * width + x` indexing read wrong memory after row 0.

**Root cause (2 independent stride bugs):**
1. ML Kit face detection input: compact NV21 + wrong bytesPerRow → ML Kit reads garbled rows → no face detected.
2. TFLite embedding input: raw NV21 with stride padding + hardcoded width → wrong Y/UV positions → corrupted face crop → embedding always fails (> 0.6 threshold).

**Important:** Face descriptors enrolled before this fix on SM-A075F must be re-enrolled (stored embeddings are garbled).

**Files modified:**
- `flutter_app/lib/src/ui/widgets/face_capture_widget_mobile.dart` — `_buildInputImage` (:272-273), `_cameraImageToImg` (:411-416)

## CI / lint

- Lint rules via `package:flutter_lints/flutter.yaml` — no custom overrides.
- No CI workflows, no pre-commit hooks, no task runner.
