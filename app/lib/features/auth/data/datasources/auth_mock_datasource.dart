import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../../domain/entities/user_identity.dart';

/// Mock OIDC Data Source for Sprint 1
/// Simulates OIDC authentication flow with JWT token generation
/// In production, this would connect to actual OIDC provider
class AuthMockDataSource {
  // Mock user database
  final Map<String, Map<String, dynamic>> _mockUsers = {
    'admin': {
      'password': 'admin123',
      'id': 'user_001',
      'username': 'admin_principal',
      'email': 'admin@edge-ai-governance.com',
      'role': 'administrador',
      'active': true,
    },
    'tech': {
      'password': 'tech123',
      'id': 'user_002',
      'username': 'tech_mantenimiento',
      'email': 'tech@edge-ai-governance.com',
      'role': 'tecnico',
      'active': true,
    },
    'oper': {
      'password': 'oper123',
      'id': 'user_003',
      'username': 'operador_piso',
      'email': 'operador@edge-ai-governance.com',
      'role': 'operador',
      'active': true,
    },
    'ext': {
      'password': 'ext123',
      'id': 'user_004',
      'username': 'externo_auditor',
      'email': 'externo@edge-ai-governance.com',
      'role': 'externo',
      'active': true, // D-08: policy is the single role-denial point
    },
  };

  /// Simulate OIDC authentication
  /// Returns JWT token if credentials are valid
  Future<Map<String, dynamic>> authenticate({
    required String username,
    required String password,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Check if user exists
    final user = _mockUsers[username.toLowerCase()];
    if (user == null) {
      throw AuthException('USER_NOT_FOUND', 'Usuario no encontrado');
    }

    // Check password
    if (user['password'] != password) {
      throw AuthException('INVALID_PASSWORD', 'Contraseña incorrecta');
    }

    // Check if user is active
    if (user['active'] != true) {
      throw AuthException('USER_INACTIVE', 'Usuario inactivo');
    }

    // Generate mock JWT token
    final token = _generateMockJwt(user);

    return {
      'access_token': token,
      'token_type': 'Bearer',
      'expires_in': 3600,
      'refresh_token': _generateRefreshToken(),
      'id_token': token, // In OIDC, id_token is the JWT with user claims
      'scope': 'openid profile email',
    };
  }

  /// Generate mock JWT token
  /// In production, this would be signed by the OIDC provider
  String _generateMockJwt(Map<String, dynamic> user) {
    final now = DateTime.now();
    final expiration = now.add(const Duration(hours: 1));

    // Header
    final header = {
      'alg': 'RS256',
      'typ': 'JWT',
      'kid': 'mock-key-id-001',
    };

    // Payload
    final payload = {
      'iss': 'https://edge-ai-governance-iam-sod.com',
      'sub': user['id'],
      'aud': 'edge-ai-governance-client',
      'exp': expiration.millisecondsSinceEpoch ~/ 1000,
      'iat': now.millisecondsSinceEpoch ~/ 1000,
      'jti': 'token_${now.millisecondsSinceEpoch}',
      'preferred_username': user['username'],
      'email': user['email'],
      'role': user['role'],
      'active': user['active'],
      'email_verified': true,
      'locale': 'es-MX',
    };

    // Encode to base64 (mock - not actually signed)
    final headerEncoded = base64Url.encode(utf8.encode(json.encode(header)));
    final payloadEncoded = base64Url.encode(utf8.encode(json.encode(payload)));
    
    // Mock signature (in production, this would be RSA signed)
    final signatureInput = '$headerEncoded.$payloadEncoded';
    final signature = sha256.convert(utf8.encode(signatureInput)).toString();
    final signatureEncoded = base64Url.encode(utf8.encode(signature.substring(0, 32)));

    return '$headerEncoded.$payloadEncoded.$signatureEncoded';
  }

  /// Generate refresh token
  String _generateRefreshToken() {
    final now = DateTime.now();
    return 'refresh_${now.millisecondsSinceEpoch}_${_generateRandomString(32)}';
  }

  /// Generate random string for tokens
  String _generateRandomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    final result = StringBuffer();
    for (var i = 0; i < length; i++) {
      result.write(chars[(random + i) % chars.length]);
    }
    return result.toString();
  }

  /// Validate JWT token
  Future<bool> validateToken(String token) async {
    try {
      // Split token
      final parts = token.split('.');
      if (parts.length != 3) {
        return false;
      }

      // Decode payload
      final payload = json.decode(utf8.decode(base64Url.decode(parts[1])));
      
      // Check expiration
      final exp = payload['exp'] as int;
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      
      return exp > now;
    } catch (e) {
      return false;
    }
  }

  /// Refresh access token
  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // In real app, this would validate refresh token with OIDC provider
    // For mock, we just generate new tokens
    final now = DateTime.now();
    final newAccessToken = 'new_access_${now.millisecondsSinceEpoch}';
    final newRefreshToken = 'new_refresh_${now.millisecondsSinceEpoch}';

    return {
      'access_token': newAccessToken,
      'token_type': 'Bearer',
      'expires_in': 3600,
      'refresh_token': newRefreshToken,
    };
  }

  /// Logout - revoke tokens
  Future<void> logout(String accessToken) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));

    // In real app, this would revoke tokens with OIDC provider
    // For mock, we just return success
  }
}

/// Custom exception for authentication errors
class AuthException implements Exception {
  final String code;
  final String message;

  const AuthException(this.code, this.message);

  @override
  String toString() => 'AuthException($code): $message';
}

/// Extension to convert JWT claims to UserIdentity
extension JwtClaimsExtension on Map<String, dynamic> {
  UserIdentity toUserIdentity() {
    return UserIdentity.fromJwtClaims(this);
  }
}