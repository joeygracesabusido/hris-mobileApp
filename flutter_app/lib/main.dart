import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'src/auth/auth_provider.dart';
import 'src/auth/auth_state.dart';
import 'src/auth/login_screen.dart';
import 'src/ui/screens/dashboard_screen.dart';
import 'src/ui/screens/employee_list_screen.dart';
import 'src/ui/screens/time_log_screen.dart';
import 'src/ui/screens/attendance_screen.dart';
import 'src/ui/screens/face_enroll_screen.dart';
import 'src/ui/screens/face_status_screen.dart';
import 'src/ui/screens/payroll_screen.dart';
import 'src/ui/screens/payroll_detail_screen.dart';
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
        final isRootRoute = state.matchedLocation == '/';

        if (authState.status == AuthStatus.initial) return null;
        if (!authState.isAuthenticated) return isLoginRoute ? null : '/login';
        if (authState.isAuthenticated && (isLoginRoute || isRootRoute)) return '/dashboard';
        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/employees',
          builder: (context, state) => const EmployeeListScreen(),
        ),
        GoRoute(
          path: '/time-logs',
          builder: (context, state) => const TimeLogScreen(),
        ),
        GoRoute(
          path: '/attendance',
          builder: (context, state) => const AttendanceScreen(),
        ),
        GoRoute(
          path: '/face-enroll',
          builder: (context, state) => const FaceEnrollScreen(),
        ),
        GoRoute(
          path: '/face-status',
          builder: (context, state) => const FaceStatusScreen(),
        ),
        GoRoute(
          path: '/payroll',
          builder: (context, state) => const PayrollScreen(),
        ),
        GoRoute(
          path: '/payroll/:id',
          builder: (context, state) => PayrollDetailScreen(payrollId: state.pathParameters['id']!),
        ),
      ],
    );

    return MaterialApp.router(
      title: 'HRIS Mobile App',
      routerConfig: router,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
    );
  }
}
