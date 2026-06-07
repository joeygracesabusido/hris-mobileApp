# HRIS Mobile App — AGENTS.md

## Project structure

```
├── lib/
│   ├── main.dart                          # App entry, MaterialApp.router with GoRouter + Riverpod
│   └── src/
│       ├── auth/                          # AuthNotifier + AuthState + authProvider
│       ├── data/
│       │   ├── models/                    # Freezed models: employee.dart, time_log.dart, payroll.dart (+ .freezed.dart / .g.dart)
│       │   └── providers/                 # ApiClient (Dio singleton), EmployeeRepository, TimeLogRepository, PayrollRepository, providers
│       └── ui/
│           ├── screens/                   # dashboard_screen.dart, employee_list_screen.dart, time_log_screen.dart, payroll_screen.dart, payroll_detail_screen.dart
│           └── widgets/                   # app_theme.dart
    ├── assets/images/                         # Must exist on disk (declared in pubspec.yaml); contains .gitkeep
    ├── .env                                   # Required at flutter_app root for flutter_dotenv
    └── test/widget_test.dart                  # Default template — not useful, will fail for this app
```

## State & routing

- **Riverpod** (`flutter_riverpod`) — `NotifierProvider` for auth, `StateNotifierProvider` for employee list, `FutureProvider.family.autoDispose` + `AsyncNotifierProvider.autoDispose` for payroll
- **GoRouter** — routes: `/login`, `/dashboard`, `/employees`, `/time-logs`, `/payroll`, `/payroll/:id`; redirect logic in `main.dart` guards auth state
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

### 2026-05-31 (v3) — Camera init timeout + loading UX overhaul

**Problem:** Face verification screen showed a permanent loading spinner and never opened the camera on either platform.

**Root cause:** Neither `CameraController.initialize()` nor `Permission.camera.request()` had timeouts. On Android, TFLite model (5.2MB) was loaded *before* camera permission — if loading was slow the permission dialog never appeared. On web, if the browser permission dialog was ignored, `getUserMedia` hung forever.

**Done:**
- **Reordered mobile init:** camera permission → camera init → show feed → *then* load TFLite model (user sees camera immediately)
- **Added `.timeout(...)`** to every init step (15s permission, 10s camera list, 15s camera init, 30s TFLite)
- **Progress messages** during loading ("Requesting camera permission...", "Opening camera...", "Loading face recognition model...")
- **Error + Retry button** shown on any init failure (both platforms)
- **Web:** Same timeout + error handling pattern
- `flutter analyze` — no issues
- `flutter build web` — builds successfully

**Files modified:**
- `face_capture_widget_mobile.dart` — reordered init, timeouts, `_retry()` resets + re-initializes all resources, status shown during loading
- `face_capture_widget_web.dart` — timeouts, retry with full reinit, status shown during loading

### 2026-05-31 (v2) — Camera permission fix + web build verification

**Goal:** Fix camera not opening on Android (face verification) but clock-in still succeeding. Verify web (Edge) build.

**Root cause:**
1. **Mobile:** `FaceCaptureWidget` (`face_capture_widget_mobile.dart`) called `availableCameras()` and `CameraController.initialize()` **without requesting runtime camera permission**. On Android 13+, manifest declaration alone is insufficient — `permission_handler` runtime grant is required. Denied permission caused camera init to fail silently → widget hung on loading spinner → no face verification → but on web the simulation always succeeded.
2. **Web:** `face_capture_widget_web.dart` is a simulation with no real camera. It always auto-succeeds with `matchDistance: 0.12` (below 0.6 threshold). This is intentional (ML Kit + TFLite don't support web), but the user testing on web saw "camera doesn't open, clock in happens."

**Done:**
- **Mobile:** Added `permission_handler` camera permission request (`Permission.camera.request()`) before `availableCameras()` in `face_capture_widget_mobile.dart:_initialize()`. If denied → widget shows "Camera permission denied" error and returns (no `onVerify` call → clock in blocked).
- **Web:** Replaced fake simulation (`face_capture_widget_web.dart`) with real camera using `camera` package (`camera_web`). No more auto-bypass — user must grant camera permission AND manually tap "Capture" to take a selfie. If no camera available or permission denied → clock in is blocked.
- Verified `flutter build web` succeeds with no compilation errors.
- Verified `flutter analyze` — no issues.

**Files modified:**
- `flutter_app/lib/src/ui/widgets/face_capture_widget_mobile.dart` — added `permission_handler` import + `Permission.camera.request()` before camera init
- `flutter_app/lib/src/ui/widgets/face_capture_widget_web.dart` — replaced fake simulation with `camera` package real camera feed + capture button

### 2026-05-31 (v4) — TFLite model asset loading fix on SM-A075F

**Problem:** "Initialization error: Unable to load asset" for `mobile_face_net.tflite` on Samsung SM-A075F.

**Root cause:**
1. **AAPT2 compression:** Android's build system compresses `.tflite` files by default. `tflite_flutter`'s `Interpreter.fromAsset()` uses memory-mapped loading which fails on compressed assets. Fixed with `aaptOptions { noCompress("tflite") }` in `build.gradle.kts`.
2. **`Interpreter.fromAsset()` internal path resolution:** On certain devices (SM-A075F), `Interpreter.fromAsset()` fails to resolve the asset even when uncompressed. Replaced with manual `rootBundle.load()` → temp file → `Interpreter.fromFile()` to bypass the internal asset loading logic.

**Done:**
- Added `aaptOptions { noCompress("tflite") }` to `android/app/build.gradle.kts:17-19` — prevents Android AAPT2 compression of `.tflite` assets
- Replaced `Interpreter.fromAsset('ml/mobile_face_net.tflite')` with `rootBundle.load('assets/ml/mobile_face_net.tflite')` → write to `Directory.systemTemp/mobile_face_net.tflite` → `Interpreter.fromFile()`
- Added 20s timeouts on `rootBundle.load()` and the file write step
- Cleaned up unused `dart:typed_data` import
- Built debug APK and installed via adb

**Testing status:** Fix applied, APK installed — pending clock-in test on SM-A075F.

**Files modified:**
- `flutter_app/android/app/build.gradle.kts` — added `aaptOptions { noCompress("tflite") }`
- `flutter_app/lib/src/ui/widgets/face_capture_widget_mobile.dart` — replaced `Interpreter.fromAsset` with manual asset load + temp file + `Interpreter.fromFile`

### 2026-06-07 — Server-side face verification + web FaceDetector interop fix + skin-tone fallback removal

**Goal:** Replace on-device embedding comparison with server-side MongoDB face verification. Fix web FaceDetector interop that silently failed. Remove skin-tone fallback that allowed hand-bypass.

**Done:**
- **Backend:** Created `POST /api/face/verify` route — accepts `{ faceDescriptor: [128 floats] }`, compares Euclidean distance (< 0.6) against ALL employees' stored descriptors in MongoDB, returns `{ matched, employee, distance }`
- **FaceRepository** (`face_repository.dart`): Added `FaceVerificationResult`, `FaceVerificationEmployee` models + `verifyFace(List<double> descriptor)` method
- **FaceCaptureWidget** (all 3 platforms): `onVerify` callback signature updated to include `List<double>? descriptor` parameter
- **AttendanceScreen**: Mobile path uses server-side `verifyFace()` — if no match, shows **"Face not registered in the system"** alert. Web path uses FaceDetector presence only (no embedding)
- **Skin-tone fallback REMOVED** (`face_capture_widget_web.dart`): Previously, if FaceDetector API failed or returned no faces, the code fell back to a skin-color pixel check that could be triggered by a hand. Removed entirely — no more bypass.
- **Web FaceDetector interop fixed:**
  - Replaced `html.window as JSObject` (silent runtime cast failure in dartdevc) with `globalContext` from `dart:js_interop`
  - Replaced HTMLImageElement + data URL (cross-library cast issue) with pure JS `Blob` from raw JPEG bytes via `Uint8List.toJS`
  - Removed `dart:html` and `dart:convert` imports entirely
- `flutter analyze` — **0 issues** ✅

**Root cause of hand bypass:** The skin-tone fallback (`_hasSkinTone`) checked average pixel color in the red/brown range. A hand/fist in the frame has similar skin-tone RGB values to a face, so it passed the check. Removed because the proper browser FaceDetector API (fixed in this session) is the only valid face detection path on web.

**Files created:**
- `app/api/face/verify/route.ts` (backend — server-side face verification endpoint)

**Files modified (Flutter):**
- `lib/src/data/providers/face_repository.dart` — added `verifyFace()`, `FaceVerificationResult`, `FaceVerificationEmployee`
- `lib/src/ui/widgets/face_capture_widget.dart` — `onVerify` signature updated with descriptor param
- `lib/src/ui/widgets/face_capture_widget_mobile.dart` — passes descriptor through `onVerify`
- `lib/src/ui/widgets/face_capture_widget_web.dart` — removed skin-tone fallback, fixed FaceDetector interop, removed `dart:html`/`dart:convert`, passes `null` descriptor
- `lib/src/ui/widgets/face_capture_widget_stub.dart` — `onVerify` signature updated
- `lib/src/ui/screens/attendance_screen.dart` — server-side face verification flow

### 2026-06-07 (v2) — Face verification distance 1.6 on SM-A075F — descriptor validation + diagnostic logging

**Problem:** Face verification on Samsung SM-A075F fails with Euclidean distance of ~1.64 (threshold: 0.6). Error shown: "Face not recognized (distance: 1.64)".

**Root cause:** The enrolled face descriptor was captured **before** the stride fix on 2026-05-31. The old `_cameraImageToImg` used `width` instead of `bytesPerRow` for stride indexing, producing garbled pixel data → wrong embedding → stored in MongoDB. After the stride fix, the verification pipeline generates correct embeddings, but they don't match the garbled stored one (distance 1.64).

**Diagnostic confirmation:** Added `debugPrint` that outputs first 5 values + sum-of-squares energy for both generated and stored descriptors. The energy check exposes garbled descriptors (energy typically < 1.0 for corrupted data vs. 50-200 for valid face embeddings).

**Done:**

**`face_capture_widget_mobile.dart`:**
- Added `_validateDescriptor()` (line 575-591) — checks for empty, NaN/Infinity, all-zero, energy < 1.0 or > 500
- `_runModel()` (line 417-447) — validates descriptor after TFLite inference before returning; logs first 5 values + descriptor length
- `_processImage` verify branch (line 228-238) — diagnostic logging of descriptor energy and distance to debug console

**`face_enroll_screen.dart`** (line 21-44):
- Pre-enrollment validation — rejects descriptors with NaN, energy < 1.0 (quality too low), or energy > 500 (anomalous)
- Shows specific error messages per failure mode to guide user (better lighting, center face)

**`attendance_screen.dart`** (line 200-249):
- After fetching stored descriptor from backend, validates: empty → "Please enroll", NaN/corrupted → "Please re-enroll", energy out of range → "poor quality, please re-enroll"
- `on DioException` catches 404 separately ("not enrolled") vs network errors
- Generic `catch` shows "unexpected error occurred"

**Files modified (Flutter):**
- `lib/src/ui/widgets/face_capture_widget_mobile.dart` — descriptor validation, diagnostic logging
- `lib/src/ui/screens/face_enroll_screen.dart` — pre-enrollment descriptor quality check
- `lib/src/ui/screens/attendance_screen.dart` — stored descriptor validation, error differentiation

### 2026-06-07 — Payroll feature with Riverpod 2.0

**Goal:** Build a functional payroll screen displaying computed Philippine payroll data with full payslip detail view, using Riverpod 2.0 auto-dispose providers. Role-aware: admin sees all, employee sees own.

**Done:**
- Created `PayrollRecord` freezed model with all Philippine payroll fields (basic salary, OT, holiday pay, SSS, PhilHealth, Pag-IBIG, withholding tax, deductions, net pay)
- Created `PayrollRepository` with `getPayrolls()` (GET /payroll, optional employeeId filter) and `computePayroll()` (POST /payroll)
- Created Riverpod 2.0 providers: `payrollListProvider.family.autoDispose<List<PayrollRecord>, String?>` (null = fetch all for admin), `processPayrollProvider` as `AsyncNotifierProvider.autoDispose` for compute form state
- Created `PayrollScreen` — list view with payslip cards (period, employee name, net pay, status badge), pull-to-refresh, empty state. Admin-only FAB triggers process payroll bottom sheet with date pickers and frequency selector
- Created `PayrollDetailScreen` — full payslip breakdown: Employee info header, Earnings section (basic salary, OT, holiday pay, gross), Deductions section (SSS, PhilHealth, Pag-IBIG, tax, late/undertime, other), Net Pay with gradient banner
- Wired `/payroll` and `/payroll/:id` routes in GoRouter + dashboard "Payroll" button navigation
- `flutter analyze` — **0 issues** ✅, `build_runner` — clean ✅

**Architecture:** Freezed model → Repository → Riverpod 2.0 `FutureProvider.family.autoDispose` for list + `AsyncNotifierProvider.autoDispose` for compute form → PayrollScreen (list) → PayrollDetailScreen (payslip). Role-aware via `RoleGuard`.

**Files created:**
- `flutter_app/lib/src/data/models/payroll.dart` (+ generated `.freezed.dart`, `.g.dart`)
- `flutter_app/lib/src/data/providers/payroll_repository.dart`
- `flutter_app/lib/src/data/providers/payroll_provider.dart`
- `flutter_app/lib/src/ui/screens/payroll_screen.dart`
- `flutter_app/lib/src/ui/screens/payroll_detail_screen.dart`

**Files modified (Flutter):**
- `lib/main.dart` — added `/payroll`, `/payroll/:id` routes + screen imports
- `lib/src/ui/screens/dashboard_screen.dart` — wired Payroll button navigation in `_onTap`

**Commits:** `044f895`, `90d2689`, `9656236`, `2c24266`, `13b876c`, `267df6d`

## CI / lint

- Lint rules via `package:flutter_lints/flutter.yaml` — no custom overrides.
- No CI workflows, no pre-commit hooks, no task runner.
