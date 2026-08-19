import 'package:flutter_test/flutter_test.dart';

import 'package:edge_ai_iam_sod/core/platform/platform_type.dart';
import 'package:edge_ai_iam_sod/features/auth/domain/entities/user_identity.dart';
import 'package:edge_ai_iam_sod/features/auth/domain/policies/feature_access.dart';

void main() {
  group('FeatureAccessPolicy.isLoginAllowed', () {
    test('administrador and superUsuario allowed on web only', () {
      for (final role in [UserRole.administrador, UserRole.superUsuario]) {
        expect(FeatureAccessPolicy.isLoginAllowed(role, PlatformType.web), isTrue);
        expect(
          FeatureAccessPolicy.isLoginAllowed(role, PlatformType.desktop),
          isFalse,
        );
        expect(
          FeatureAccessPolicy.isLoginAllowed(role, PlatformType.mobile),
          isFalse,
        );
      }
    });

    test('tecnico allowed on desktop only', () {
      expect(
        FeatureAccessPolicy.isLoginAllowed(UserRole.tecnico, PlatformType.desktop),
        isTrue,
      );
      expect(
        FeatureAccessPolicy.isLoginAllowed(UserRole.tecnico, PlatformType.web),
        isFalse,
      );
      expect(
        FeatureAccessPolicy.isLoginAllowed(UserRole.tecnico, PlatformType.mobile),
        isFalse,
      );
    });

    test('operador allowed on mobile only', () {
      expect(
        FeatureAccessPolicy.isLoginAllowed(UserRole.operador, PlatformType.mobile),
        isTrue,
      );
      expect(
        FeatureAccessPolicy.isLoginAllowed(UserRole.operador, PlatformType.web),
        isFalse,
      );
      expect(
        FeatureAccessPolicy.isLoginAllowed(
          UserRole.operador,
          PlatformType.desktop,
        ),
        isFalse,
      );
    });

    test('externo denied on every platform', () {
      for (final platform in PlatformType.values) {
        expect(
          FeatureAccessPolicy.isLoginAllowed(UserRole.externo, platform),
          isFalse,
        );
      }
    });
  });

  group('FeatureAccessPolicy.resolveFeature', () {
    test('maps roles to their feature', () {
      expect(FeatureAccessPolicy.resolveFeature(UserRole.administrador), Feature.ioc);
      expect(FeatureAccessPolicy.resolveFeature(UserRole.superUsuario), Feature.ioc);
      expect(FeatureAccessPolicy.resolveFeature(UserRole.tecnico), Feature.studio);
      expect(FeatureAccessPolicy.resolveFeature(UserRole.operador), Feature.loader);
      expect(FeatureAccessPolicy.resolveFeature(UserRole.externo), isNull);
    });
  });
}