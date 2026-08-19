import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/user_identity.dart';
import '../../data/datasources/auth_mock_datasource.dart';
import '../../domain/policies/feature_access.dart';
import '../../../../core/platform/platform_detector.dart';

typedef PlatformResolver = PlatformType Function();

// Events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class LoginRequested extends AuthEvent {
  final String username;
  final String password;

  const LoginRequested({
    required this.username,
    required this.password,
  });

  @override
  List<Object?> get props => [username, password];
}

class TokenLoginRequested extends AuthEvent {
  final String token;

  const TokenLoginRequested({required this.token});

  @override
  List<Object?> get props => [token];
}

class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}

class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

// States
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class Authenticated extends AuthState {
  final UserIdentity user;

  const Authenticated({required this.user});

  @override
  List<Object?> get props => [user];
}

class PlatformBlocked extends AuthState {
  final UserIdentity user;
  final String reason;

  const PlatformBlocked({required this.user, required this.reason});

  @override
  List<Object?> get props => [user, reason];
}

class Unauthenticated extends AuthState {
  const Unauthenticated();
}

class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object?> get props => [message];
}

// Auth Bloc
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthMockDataSource _authDataSource;
  final PlatformResolver _platformResolver;

  AuthBloc({
    AuthMockDataSource? authDataSource,
    PlatformResolver? platformResolver,
  })  : _authDataSource = authDataSource ?? AuthMockDataSource(),
        _platformResolver =
            platformResolver ?? (() => PlatformDetector.currentPlatform),
        super(const AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<TokenLoginRequested>(_onTokenLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<AuthCheckRequested>(_onAuthCheckRequested);
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      // Use mock OIDC data source for authentication
      final tokenResponse = await _authDataSource.authenticate(
        username: event.username,
        password: event.password,
      );

      // Parse JWT claims from id_token
      final idToken = tokenResponse['id_token'] as String;
      final claims = _parseJwtPayload(idToken);

      // Create UserIdentity from claims
      final user = UserIdentity.fromJwtClaims(claims);

      // Enforce role->feature->platform gate before Authenticated
      if (!_isAllowed(user)) {
        emit(PlatformBlocked(
          user: user,
          reason: _blockedReason(_platformResolver()),
        ));
        return;
      }

      emit(Authenticated(user: user));
    } on AuthException catch (e) {
      emit(AuthError(message: e.message));
    } catch (e) {
      emit(AuthError(message: 'Error de autenticación: ${e.toString()}'));
    }
  }

  Future<void> _onTokenLoginRequested(
    TokenLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      // Parse JWT claims directly from the token (mock OIDC semantics)
      final claims = _parseJwtPayload(event.token);
      final user = UserIdentity.fromJwtClaims(claims);

      // Same role->feature->platform gate as password login
      if (!_isAllowed(user)) {
        emit(PlatformBlocked(
          user: user,
          reason: _blockedReason(_platformResolver()),
        ));
        return;
      }

      emit(Authenticated(user: user));
    } catch (e) {
      emit(AuthError(message: 'Error de autenticación: ${e.toString()}'));
    }
  }

  bool _isAllowed(UserIdentity user) {
    return FeatureAccessPolicy.isLoginAllowed(user.rol, _platformResolver());
  }

  static String _blockedReason(PlatformType platform) =>
      'Acceso denegado: su rol requiere la plataforma ${platform.name}.';

  void _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) {
    emit(const Unauthenticated());
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      // Check for existing token in secure storage
      // In real app, this would validate stored JWT
      await Future.delayed(const Duration(milliseconds: 500));

      // For now, emit unauthenticated
      emit(const Unauthenticated());
    } catch (e) {
      emit(const Unauthenticated());
    }
  }

  /// Parse JWT payload without validation (mock only)
  Map<String, dynamic> _parseJwtPayload(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw Exception('Invalid JWT format');
    }

    final payload = parts[1];
    final normalized = base64Url.normalize(payload);
    final decoded = utf8.decode(base64Url.decode(normalized));
    return Map<String, dynamic>.from(json.decode(decoded));
  }
}