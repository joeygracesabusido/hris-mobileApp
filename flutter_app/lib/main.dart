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
