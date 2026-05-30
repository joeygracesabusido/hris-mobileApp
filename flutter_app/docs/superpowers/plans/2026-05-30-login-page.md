# Login Page Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a login screen that appears on app launch before users can access the employee list.

**Architecture:** GoRouter-based routing with an auth redirect guard, Riverpod `Notifier` for auth state management, secure storage for token persistence. The login screen calls `POST /api/auth/login` and stores the returned token.

**Tech Stack:** Flutter, Riverpod, GoRouter, Dio, FlutterSecureStorage

---

### Task 1: Add go_router dependency

**Files:**
- Modify: `pubspec.yaml`

- [ ] **Step 1: Add go_router to pubspec.yaml**

Insert after the existing dependencies (after `flutter_dotenv` line):

```yaml
  go_router: ^14.0.0
```

- [ ] **Step 2: Install the dependency**

Run:
```bash
cd D:\hris-mobileApp\flutter_app
flutter pub get
```
Expected: `go_router` added to `pubspec.lock`, exit code 0.

- [ ] **Step 3: Commit**

```bash
cd D:\hris-mobileApp\flutter_app
git add pubspec.yaml pubspec.lock
git commit -m "chore: add go_router dependency"
```

---

### Task 2: Create auth state, notifier, and provider

**Files:**
- Create: `lib/src/auth/auth_state.dart`
- Create: `lib/src/auth/auth_notifier.dart`
- Create: `lib/src/auth/auth_provider.dart`

- [ ] **Step 1: Create `lib/src/auth/auth_state.dart`**

```dart
// src/auth/auth_state.dart

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final String? token;
  final String? error;

  const AuthState({
    this.status = AuthStatus.initial,
    this.token,
    this.error,
  });

  const AuthState.initial() : this();
  const AuthState.loading() : this(status: AuthStatus.loading);
  const AuthState.authenticated(String token)
      : this(status: AuthStatus.authenticated, token: token);
  const AuthState.unauthenticated() : this(status: AuthStatus.unauthenticated);
  const AuthState.error(String message)
      : this(status: AuthStatus.error, error: message);

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isLoading => status == AuthStatus.loading;
}
```

- [ ] **Step 2: Create `lib/src/auth/auth_notifier.dart`**

```dart
// src/auth/auth_notifier.dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../data/providers/api_client.dart';
import 'auth_state.dart';

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    _init();
    return const AuthState.initial();
  }

  Future<void> _init() async {
    const storage = FlutterSecureStorage();
    try {
      final token = await storage.read(key: 'auth_token');
      if (token != null && token.isNotEmpty) {
        state = AuthState.authenticated(token);
        return;
      }
    } catch (_) {}
    state = const AuthState.unauthenticated();
  }

  Future<void> login(String email, String password) async {
    state = const AuthState.loading();

    try {
      final response = await ApiClient.instance.dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      final token = response.data['auth_token'] as String?;
      if (token == null || token.isEmpty) {
        state = const AuthState.error('Invalid response from server');
        return;
      }

      const storage = FlutterSecureStorage();
      await storage.write(key: 'auth_token', value: token);
      state = AuthState.authenticated(token);
    } on DioException catch (e) {
      final message = e.response?.data?['message'] as String? ??
          e.message ??
          'Login failed. Please try again.';
      state = AuthState.error(message);
    } catch (e) {
      state = const AuthState.error('An unexpected error occurred');
    }
  }

  Future<void> logout() async {
    const storage = FlutterSecureStorage();
    await storage.delete(key: 'auth_token');
    state = const AuthState.unauthenticated();
  }
}
```

- [ ] **Step 3: Create `lib/src/auth/auth_provider.dart`**

```dart
// src/auth/auth_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_notifier.dart';
import 'auth_state.dart';

final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
```

- [ ] **Step 4: Commit**

```bash
cd D:\hris-mobileApp\flutter_app
git add lib/src/auth/
git commit -m "feat: add auth state, notifier, and provider"
```

---

### Task 3: Create the login screen

**Files:**
- Create: `lib/src/auth/login_screen.dart`

- [ ] **Step 1: Create `lib/src/auth/login_screen.dart`**

```dart
// src/auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../ui/widgets/app_theme.dart';
import 'auth_provider.dart';
import 'auth_state.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authProvider.notifier).login(
          _emailController.text.trim(),
          _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    ref.listen<AuthState>(authProvider, (_, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!)),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo / branding
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: AppTheme.headerGradient,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.business_center,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'HRIS Mobile',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 40),

                  // Email field
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: const Icon(Icons.email_outlined),
                      filled: true,
                      fillColor: AppTheme.cardBackground,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Password field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      filled: true,
                      fillColor: AppTheme.cardBackground,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),

                  // Login button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: authState.isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: authState.isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Login',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
cd D:\hris-mobileApp\flutter_app
git add lib/src/auth/login_screen.dart
git commit -m "feat: add login screen"
```

---

### Task 4: Update main.dart with GoRouter and auth guard

**Files:**
- Modify: `lib/main.dart`

- [ ] **Step 1: Replace `main.dart` content**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'src/auth/auth_provider.dart';
import 'src/auth/auth_state.dart';
import 'src/auth/login_screen.dart';
import 'src/ui/screens/employee_list_screen.dart';
import 'src/ui/widgets/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint('Error loading .env file: $e');
  }

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const _AppWithRouter();
  }
}

class _AppWithRouter extends ConsumerWidget {
  const _AppWithRouter();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    final router = GoRouter(
      initialLocation: '/',
      redirect: (context, state) {
        final isLoginRoute = state.matchedLocation == '/login';

        if (authState.status == AuthStatus.initial) return null;
        if (!authState.isAuthenticated && !isLoginRoute) return '/login';
        if (authState.isAuthenticated && isLoginRoute) return '/employees';
        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/employees',
          builder: (context, state) => const EmployeeListScreen(),
        ),
      ],
    );

    return MaterialApp.router(
      title: 'HRIS Mobile App',
      routerConfig: router,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
    );
  }
}
```

- [ ] **Step 2: Verify the app builds**

Run:
```bash
cd D:\hris-mobileApp\flutter_app
flutter analyze
```
Expected: No errors. (If analysis_options.yaml has strict rules, minor fixes may be needed.)

- [ ] **Step 3: Commit**

```bash
cd D:\hris-mobileApp\flutter_app
git add lib/main.dart
git commit -m "feat: integrate GoRouter with auth redirect guard"
```

---

### Task 5: Verify the build compiles

- [ ] **Step 1: Run flutter analyze and fix any issues**

```bash
cd D:\hris-mobileApp\flutter_app
flutter analyze
```

If any errors appear, fix them. Expected: "No issues found".

- [ ] **Step 2: Commit any fixes**

```bash
cd D:\hris-mobileApp\flutter_app
git add -A
git commit -m "fix: resolve compilation issues"
```
