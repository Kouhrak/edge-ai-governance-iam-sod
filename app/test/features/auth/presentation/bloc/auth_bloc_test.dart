import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';

import 'package:edge_ai_iam_sod/core/platform/platform_type.dart';
import 'package:edge_ai_iam_sod/features/auth/data/datasources/auth_mock_datasource.dart';
import 'package:edge_ai_iam_sod/features/auth/domain/entities/user_identity.dart';
import 'package:edge_ai_iam_sod/features/auth/presentation/bloc/auth_bloc.dart';

void main() {
  group('AuthBloc login gate', () {
    blocTest<AuthBloc, AuthState>(
      'emits Authenticated for administrador on web',
      build: () => AuthBloc(platformResolver: () => PlatformType.web),
      // AuthMockDataSource simulates a 1s network delay; wait for it.
      wait: const Duration(milliseconds: 1200),
      act: (bloc) =>
          bloc.add(const LoginRequested(username: 'admin', password: 'admin123')),
      expect: () => [
        isA<AuthLoading>(),
        isA<Authenticated>()
            .having((state) => state.user.rol, 'rol', UserRole.administrador),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits PlatformBlocked for administrador on mobile and never Authenticated',
      build: () => AuthBloc(platformResolver: () => PlatformType.mobile),
      wait: const Duration(milliseconds: 1200),
      act: (bloc) =>
          bloc.add(const LoginRequested(username: 'admin', password: 'admin123')),
      expect: () => [
        isA<AuthLoading>(),
        isA<PlatformBlocked>()
            .having((state) => state.user.rol, 'rol', UserRole.administrador)
            .having((state) => state.reason, 'reason', isNotEmpty),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits Authenticated for tecnico on desktop',
      build: () => AuthBloc(platformResolver: () => PlatformType.desktop),
      wait: const Duration(milliseconds: 1200),
      act: (bloc) =>
          bloc.add(const LoginRequested(username: 'tech', password: 'tech123')),
      expect: () => [
        isA<AuthLoading>(),
        isA<Authenticated>()
            .having((state) => state.user.rol, 'rol', UserRole.tecnico),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits PlatformBlocked for externo on any platform',
      build: () => AuthBloc(platformResolver: () => PlatformType.web),
      wait: const Duration(milliseconds: 1200),
      act: (bloc) =>
          bloc.add(const LoginRequested(username: 'ext', password: 'ext123')),
      expect: () => [
        isA<AuthLoading>(),
        isA<PlatformBlocked>()
            .having((state) => state.user.rol, 'rol', UserRole.externo),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits AuthError for bad credentials',
      build: () => AuthBloc(platformResolver: () => PlatformType.web),
      wait: const Duration(milliseconds: 1200),
      act: (bloc) =>
          bloc.add(const LoginRequested(username: 'admin', password: 'wrong')),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthError>(),
      ],
    );
  });

  group('AuthBloc token login', () {
    blocTest<AuthBloc, AuthState>(
      'emits Authenticated for operador token on mobile',
      build: () => AuthBloc(platformResolver: () => PlatformType.mobile),
      act: (bloc) async {
        final datasource = AuthMockDataSource();
        final response =
            await datasource.authenticate(username: 'oper', password: 'oper123');
        bloc.add(TokenLoginRequested(token: response['id_token'] as String));
      },
      expect: () => [
        isA<AuthLoading>(),
        isA<Authenticated>()
            .having((state) => state.user.rol, 'rol', UserRole.operador),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits PlatformBlocked for externo token',
      build: () => AuthBloc(platformResolver: () => PlatformType.mobile),
      act: (bloc) async {
        final datasource = AuthMockDataSource();
        final response =
            await datasource.authenticate(username: 'ext', password: 'ext123');
        bloc.add(TokenLoginRequested(token: response['id_token'] as String));
      },
      expect: () => [
        isA<AuthLoading>(),
        isA<PlatformBlocked>()
            .having((state) => state.user.rol, 'rol', UserRole.externo),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits AuthError for invalid token',
      build: () => AuthBloc(platformResolver: () => PlatformType.mobile),
      act: (bloc) => bloc.add(const TokenLoginRequested(token: 'not-a-jwt')),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthError>(),
      ],
    );
  });

  group('AuthBloc logout', () {
    blocTest<AuthBloc, AuthState>(
      'emits Unauthenticated on LogoutRequested',
      build: () => AuthBloc(platformResolver: () => PlatformType.web),
      act: (bloc) => bloc.add(const LogoutRequested()),
      expect: () => [isA<Unauthenticated>()],
    );
  });
}