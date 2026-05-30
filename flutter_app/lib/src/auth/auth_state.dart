// src/auth/auth_state.dart

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final Map<String, dynamic>? user;
  final String? error;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.error,
  });

  const AuthState.initial() : this();
  const AuthState.loading() : this(status: AuthStatus.loading);
  const AuthState.authenticated(Map<String, dynamic> user)
      : this(status: AuthStatus.authenticated, user: user);
  const AuthState.unauthenticated() : this(status: AuthStatus.unauthenticated);
  const AuthState.error(String message)
      : this(status: AuthStatus.error, error: message);

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isLoading => status == AuthStatus.loading;
}
