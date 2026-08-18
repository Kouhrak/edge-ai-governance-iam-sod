/// User roles for IAM SoD enforcement
/// Each role has specific permissions and restrictions
enum UserRole {
  superUsuario,
  administrador,
  tecnico,
  operador,
  externo,
}

/// Extension to get display name and permissions for each role
extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.superUsuario:
        return 'SuperUsuario';
      case UserRole.administrador:
        return 'Administrador';
      case UserRole.tecnico:
        return 'Técnico';
      case UserRole.operador:
        return 'Operador';
      case UserRole.externo:
        return 'Externo';
    }
  }

  /// Check if this role can approve firmware injection
  bool get canApproveFirmware {
    return this == UserRole.administrador || this == UserRole.superUsuario;
  }

  /// Check if this role can inject firmware
  bool get canInjectFirmware {
    return this == UserRole.tecnico;
  }

  /// Check if this role can configure sensors
  bool get canConfigureSensors {
    return this == UserRole.administrador || 
           this == UserRole.tecnico ||
           this == UserRole.operador;
  }

  /// Check if this role can view dashboard
  bool get canViewDashboard {
    return this != UserRole.externo;
  }
}

/// UserIdentity entity representing authenticated user
/// Contains all necessary claims for SoD enforcement
class UserIdentity {
  final String id;
  final String username;
  final String email;
  final bool active;
  final UserRole rol;
  final DateTime? lastLogin;
  final String? tokenId;

  const UserIdentity({
    required this.id,
    required this.username,
    required this.email,
    required this.active,
    required this.rol,
    this.lastLogin,
    this.tokenId,
  });

  /// Create UserIdentity from JWT claims
  factory UserIdentity.fromJwtClaims(Map<String, dynamic> claims) {
    return UserIdentity(
      id: claims['sub'] ?? '',
      username: claims['preferred_username'] ?? '',
      email: claims['email'] ?? '',
      active: claims['active'] ?? true,
      rol: _parseUserRole(claims['role']),
      lastLogin: claims['last_login'] != null 
          ? DateTime.parse(claims['last_login']) 
          : null,
      tokenId: claims['jti'],
    );
  }

  /// Parse role string to UserRole enum
  static UserRole _parseUserRole(dynamic roleValue) {
    if (roleValue == null) return UserRole.externo;
    
    final roleString = roleValue.toString().toLowerCase();
    
    for (final role in UserRole.values) {
      if (role.name.toLowerCase() == roleString) {
        return role;
      }
    }
    
    return UserRole.externo;
  }

  /// Check if user has specific permission for SoD validation
  bool hasPermission(String permission) {
    switch (permission) {
      case 'approve_firmware':
        return rol.canApproveFirmware;
      case 'inject_firmware':
        return rol.canInjectFirmware;
      case 'configure_sensors':
        return rol.canConfigureSensors;
      case 'view_dashboard':
        return rol.canViewDashboard;
      default:
        return false;
    }
  }

  /// Convert to JWT claims map for token generation
  Map<String, dynamic> toJwtClaims() {
    return {
      'sub': id,
      'preferred_username': username,
      'email': email,
      'active': active,
      'role': rol.name,
      'last_login': lastLogin?.toIso8601String(),
      'jti': tokenId,
    };
  }

  /// Create a copy with updated fields
  UserIdentity copyWith({
    String? id,
    String? username,
    String? email,
    bool? active,
    UserRole? rol,
    DateTime? lastLogin,
    String? tokenId,
  }) {
    return UserIdentity(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      active: active ?? this.active,
      rol: rol ?? this.rol,
      lastLogin: lastLogin ?? this.lastLogin,
      tokenId: tokenId ?? this.tokenId,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserIdentity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'UserIdentity(id: $id, username: $username, rol: ${rol.displayName})';
  }
}