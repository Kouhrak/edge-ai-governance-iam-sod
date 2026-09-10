import 'package:flutter/material.dart';
import '../../../../../core/theme/design_tokens.dart';
import '../../../../../core/widgets/atoms/status_badge.dart';
import '../../../../../core/widgets/organisms/data_table.dart' as dt;
import '../../../../auth/domain/entities/user_identity.dart';

/// Access management section — institutional users table with role badges,
/// active state and per-row edit/delete actions.
class AccessManagementSection extends StatelessWidget {
  const AccessManagementSection({super.key});

  static const List<Map<String, dynamic>> _users = [
    {
      'username': 'admin_principal',
      'email': 'admin@edge-ai.com',
      'role': UserRole.administrador,
      'active': true,
      'lastLogin': '2026-08-18 10:30',
    },
    {
      'username': 'tech_mantenimiento',
      'email': 'tech@edge-ai.com',
      'role': UserRole.tecnico,
      'active': true,
      'lastLogin': '2026-08-18 09:15',
    },
    {
      'username': 'operador_piso',
      'email': 'operador@edge-ai.com',
      'role': UserRole.operador,
      'active': true,
      'lastLogin': '2026-08-18 08:00',
    },
    {
      'username': 'externo_auditor',
      'email': 'externo@edge-ai.com',
      'role': UserRole.externo,
      'active': false,
      'lastLogin': '2026-08-15 14:20',
    },
  ];

  static StatusTone _roleTone(UserRole role) {
    switch (role) {
      case UserRole.administrador:
        return StatusTone.brand;
      case UserRole.superUsuario:
        return StatusTone.danger;
      case UserRole.tecnico:
        return StatusTone.success;
      case UserRole.operador:
        return StatusTone.warning;
      case UserRole.externo:
        return StatusTone.neutral;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(DesignTokens.spaceLg),
      children: [
        const Text(
          'Usuarios institucionales',
          style: TextStyle(
            fontSize: DesignTokens.textLg,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          'Cuentas registradas y sus roles en el sistema',
          style: TextStyle(fontSize: DesignTokens.textSm, color: Colors.grey[600]),
        ),
        const SizedBox(height: DesignTokens.spaceMd),
        dt.DataTable(
          columns: const [
            dt.DataTableColumn(label: 'Usuario', flex: 2),
            dt.DataTableColumn(label: 'Email', flex: 2),
            dt.DataTableColumn(label: 'Rol'),
            dt.DataTableColumn(label: 'Estado'),
            dt.DataTableColumn(label: 'Último Login', flex: 2),
            dt.DataTableColumn(label: 'Acciones'),
          ],
          rows: [
            for (final user in _users)
              dt.DataTableRow(
                cells: [
                  Text(user['username'] as String),
                  Text(user['email'] as String),
                  StatusBadge(
                    label: (user['role'] as UserRole).displayName,
                    tone: _roleTone(user['role'] as UserRole),
                  ),
                  Icon(
                    user['active'] as bool
                        ? Icons.check_circle
                        : Icons.cancel,
                    color: user['active'] as bool
                        ? DesignTokens.safeGreen
                        : DesignTokens.safetyRed,
                  ),
                  Text(user['lastLogin'] as String),
                ],
                actions: [
                  IconButton(
                    icon: const Icon(Icons.edit, size: DesignTokens.textXl),
                    onPressed: () {},
                    tooltip: 'Editar',
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.delete,
                      size: DesignTokens.textXl,
                      color: DesignTokens.safetyRed,
                    ),
                    onPressed: () {},
                    tooltip: 'Eliminar',
                  ),
                ],
              ),
          ],
        ),
      ],
    );
  }
}