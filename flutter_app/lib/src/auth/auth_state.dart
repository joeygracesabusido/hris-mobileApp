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
