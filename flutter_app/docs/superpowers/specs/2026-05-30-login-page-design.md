# Login Page Design

## Overview
Add a login screen to the HRIS Flutter mobile app that appears when the app opens. After successful authentication, the user is redirected to the employee list screen.

## Architecture

### Dependencies
- **go_router** — declarative routing with auth redirect guards
- **flutter_riverpod** (already present) — state management for auth state
- **flutter_secure_storage** (already present) — persist auth token
- **dio** (already present) — HTTP client for login API call

### Route Structure
```
/login         → LoginScreen (public)
/employees     → EmployeeListScreen (protected, redirects to /login if unauthenticated)
```

A root redirect checks `AuthState`. If `unauthenticated`, redirect to `/login`. If `authenticated`, redirect to `/employees`.

### Auth Module (`lib/src/auth/`)
```
lib/src/auth/
├── auth_state.dart       — Freezed class for auth state
├── auth_notifier.dart    — Riverpod Notifier for login/logout logic
├── auth_provider.dart    — Riverpod provider definitions
└── login_screen.dart     — Login UI
```

### Data Flow
1. App launches → GoRouter checks auth state → splash/loading indicator while checking secure storage
2. If token exists → set `authenticated` → redirect to `/employees`
3. If no token → set `unauthenticated` → redirect to `/login`
4. User submits email + password → `AuthNotifier.login()` → `POST /api/auth/login` → store token → set `authenticated`
5. On API error → display error in UI, stay on login screen

### Login Screen UI
- Follows existing `AppTheme` (dark mode, teal accent, slate backgrounds)
- Email field with validation (non-empty, email format)
- Password field with validation (non-empty, obscured)
- "Login" button — full width, `AppTheme.primary` color
- Loading state — button shows `CircularProgressIndicator`
- Error state — snackbar or inline error message
- App branding/logo at top (placeholder)

### API Contract
- **Endpoint:** `POST /api/auth/login`
- **Request body:** `{ "email": string, "password": string }`
- **Response:** `{ "auth_token": string }` (or similar containing a token)
- **Error:** HTTP 401 or 422 with error message in body

### Auth State
```dart
@freezed
class AuthState with _$AuthState {
  const factory AuthState.initial() = _Initial;
  const factory AuthState.loading() = _Loading;
  const factory AuthState.authenticated(String token) = _Authenticated;
  const factory AuthState.unauthenticated() = _Unauthenticated;
  const factory AuthState.error(String message) = _Error;
}
```

### Changes to Existing Files
- **`main.dart`** — switch to `MaterialApp.router` with GoRouter
- **`api_client.dart`** — no changes needed (already reads token from secure storage)
- **`employee_list_screen.dart`** — no changes needed

### Future Considerations (Not Implemented Now)
- Token refresh logic
- Auto-logout on token expiry
- "Remember me" toggle
- Biometric authentication
- Forgot password / register screens
