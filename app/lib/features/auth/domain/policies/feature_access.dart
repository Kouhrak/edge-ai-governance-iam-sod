import '../../../../core/platform/platform_type.dart';
import '../entities/user_identity.dart';

/// Features exposed by the IAM SoD platform.
enum Feature { ioc, studio, loader }

/// Role -> feature -> platform access matrix (spec D2).
/// Pure Dart: MUST NOT import Flutter or dart:io (web-safe).
abstract final class FeatureAccessPolicy {
  static const Map<UserRole, Feature> _roleToFeature = {
    UserRole.administrador: Feature.ioc,
    UserRole.superUsuario: Feature.ioc,
    UserRole.tecnico: Feature.studio,
    UserRole.operador: Feature.loader,
  };

  static const Map<Feature, Set<PlatformType>> _featureToPlatforms = {
    Feature.ioc: {PlatformType.web},
    Feature.studio: {PlatformType.desktop},
    Feature.loader: {PlatformType.mobile},
  };

  static Feature? resolveFeature(UserRole role) => _roleToFeature[role];

  static bool isLoginAllowed(UserRole role, PlatformType platform) {
    final feature = resolveFeature(role);
    return feature != null && _featureToPlatforms[feature]!.contains(platform);
  }
}