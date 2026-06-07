# Attendance with Facial Recognition & GPS — Mobile App

## Overview
Add an **Attendance** feature to the HRIS Flutter mobile app that validates the user's GPS location against office geofences and performs on-device facial recognition before allowing clock-in/clock-out. Also provide face enrollment from the mobile app.

## Architecture

```
┌──────────────────────────────────────────────────────┐
│  Flutter App (on-device ML)                          │
│                                                      │
│  AttendanceScreen                                    │
│  ├─ Step 1: GPS check (geolocator)                   │
│  │    → Haversine vs OfficeLocation geofences        │
│  ├─ Step 2: Face verification                        │
│  │    → camera + google_mlkit_face_detection         │
│  │    → TFLite MobileFaceNet → 128-dim embedding     │
│  │    → Euclidean distance vs stored descriptor       │
│  └─ Step 3: Clock In/Out                             │
│       → POST /api/time-logs {employeeId, type,       │
│         latitude, longitude}                         │
│                                                      │
│  FaceEnrollScreen                                    │
│  └─ camera → ML Kit → TFLite → PUT /api/employees   │
└──────────────────────────────────────────────────────┘
         │                                    │
         │ GPS + result                       │ face descriptor
         ▼                                    ▼
┌──────────────────────────┐  ┌───────────────────────────────┐
│ POST /api/time-logs      │  │ PUT /api/employees/{id}/face  │
│ (existing, add GPS)      │  │ (existing)                    │
│ GET /api/office-location  │  │ GET /api/employees/{id}/     │
│ (existing)                │  │   face-descriptor (existing)  │
└──────────────────────────┘  └───────────────────────────────┘
```

## New Dependencies (pubspec.yaml)
- `geolocator: ^12.0.0` — device GPS location
- `camera: ^0.11.0` — camera preview and frame capture
- `google_mlkit_face_detection: ^0.12.0` — ML Kit face detection
- `tflite_flutter: ^0.11.0` — TFLite inference for face embedding
- `permission_handler: ^11.3.0` — runtime permissions

## TFLite Model
- **MobileFaceNet** — lightweight CNN outputting 128-dim face embeddings
- Bundled at `assets/ml/mobile_face_net.tflite`
- Input: 112×112 RGB face crop, normalized to [-1, 1]
- Output: 128-dim float array
- Distance threshold: 0.6 (Euclidean)

## Flows

### Attendance (Clock In / Clock Out)
1. Load attendance screen → fetch GPS + office locations
2. Calculate distance to nearest geofence (Haversine)
3. If outside geofence → show error, disable buttons
4. User taps Clock In or Clock Out:
   a. Fetch stored face descriptor: `GET /api/employees/{id}/face-descriptor`
   b. If not enrolled → redirect to enrollment
   c. Open camera overlay
   d. Detect face → TFLite embedding → compare (Euclidean < 0.6)
   e. On match → POST /api/time-logs with GPS coords
   f. On no match → retry (max 3 attempts)

### Face Enrollment
1. Open camera preview with oval guide overlay
2. Auto-detect face → generate embedding
3. Display preview + success message
4. Auto-save: `PUT /api/employees/{id}/face {faceDescriptor: [...]}`

## New Screens & Routes
| Route | Screen | Widget |
|-------|--------|--------|
| `/attendance` | AttendanceScreen | Full flow |
| `/face-enroll` | FaceEnrollScreen | Enrollment only |

## New Files
| File | Purpose |
|------|---------|
| `lib/src/ui/screens/attendance_screen.dart` | Main attendance flow |
| `lib/src/ui/screens/face_enroll_screen.dart` | Face enrollment |
| `lib/src/ui/widgets/face_capture_widget.dart` | Reusable camera + detection widget |
| `lib/src/data/providers/face_repository.dart` | Face API calls |
| `assets/ml/mobile_face_net.tflite` | FaceNet TFLite model |

## Modified Files
| File | Change |
|------|--------|
| `pubspec.yaml` | Add deps + assets/ml/ |
| `lib/main.dart` | Add routes |
| `lib/src/ui/screens/dashboard_screen.dart` | Add "Attendance" button |
| `lib/src/data/providers/time_log_repository.dart` | Add GPS params |
| `lib/src/data/providers/api_client.dart` | Ensure office-location endpoint works with X-Auth headers |

## Verification
- GPS: Backend validates geofence server-side (existing Haversine check)
- Face: Euclidean distance < 0.6 (same as web app threshold)
- On 3 failed face attempts → show "Contact HR for manual verification"
