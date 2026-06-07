# Face Registration Status Screen — Design Spec

**Date:** 2026-06-07
**Status:** Approved

## Problem

Face enrollment is only accessible from the Attendance screen via a conditional "Enroll Face" button (shown when not enrolled). Users on SM-A075F need a more discoverable and always-accessible entry point for face registration, especially since re-enrollment may be needed after stride fixes.

## Solution

Add a dedicated **Face Registration** button to the Dashboard Quick Actions grid that navigates to a new `FaceStatusScreen` showing enrollment status with detailed info (employee name, enrollment date) and an Enroll/Re-enroll action button.

## Architecture

### Backend — New Endpoint

**`GET /api/face/status`**
- Auth: uses `getRequestSession()` (cookie or X-Auth-* headers)
- Looks up logged-in employee's face descriptor in MongoDB
- Response when enrolled:
  ```json
  {
    "enrolled": true,
    "employeeName": "Juan dela Cruz",
    "enrolledAt": "2026-06-07T10:30:00.000Z"
  }
  ```
- Response when not enrolled:
  ```json
  {
    "enrolled": false,
    "employeeName": "Juan dela Cruz"
  }
  ```

### Flutter — New Screen

**`FaceStatusScreen`** at route `/face-status`

Three visual states:

1. **Loading** — `CircularProgressIndicator` with "Checking enrollment status..." text
2. **Enrolled** — green-bordered card showing employee name, formatted enrollment date/time, and a teal "Re-enroll Face" button → navigates to `/face-enroll`
3. **Not Enrolled** — red-bordered card with explanatory text and a teal "Enroll Now" button → navigates to `/face-enroll`

Error state shows an error card with retry button. 401 redirects to `/login`.

### Flutter — Dashboard Button

Add a 6th item to `_QuickActionsGrid`:
- Icon: `Icons.fingerprint`
- Label: "Face Registration"
- Color: `Color(0xFF6C63FF)` (purple, distinct from Attendance)
- On tap: `context.go('/face-status')`

The grid row wraps in a `SingleChildScrollView(scrollDirection: Axis.horizontal)` to accommodate 6 items on small screens.

### Flutter — Repository

**`FaceRepository` additions:**
- New method: `Future<FaceEnrollmentStatus> getEnrollmentStatus()` — calls `GET /api/face/status`
- New model: `FaceEnrollmentStatus` with fields: `enrolled`, `employeeName`, `enrolledAt?`

## Files Created

| File | Purpose |
|------|---------|
| `lib/src/ui/screens/face_status_screen.dart` | Status screen UI |
| Backend: `app/api/face/status/route.ts` | Enrollment status endpoint |

## Files Modified

| File | Change |
|------|--------|
| `lib/src/ui/screens/dashboard_screen.dart` | Add 6th Quick Action item + horizontal scroll |
| `lib/src/data/providers/face_repository.dart` | Add `getEnrollmentStatus()` method + model |
| `lib/main.dart` | Add `/face-status` route |

## Error Handling

- **401** → redirect to `/login`
- **Network / 500** → error card with retry button
- **Invalid response** → "Unable to check status" message

## Testing

- Verify dashboard shows 6 items, horizontal scroll works on small screens
- Verify enrolled state shows correct date formatting
- Verify not-enrolled state shows "Enroll Now" button
- Verify navigation from status screen to enrollment screen works
- Verify error states display correctly
