import 'package:flutter/material.dart';
import '../../../../../core/theme/design_tokens.dart';
import '../../../../../core/widgets/atoms/app_button.dart';
import '../../../../../core/widgets/atoms/status_badge.dart';
import '../../../../../core/widgets/molecules/device_card.dart';
import '../../../../auth/domain/entities/user_identity.dart';
import '../../../../loader/domain/entities/ble_device.dart';

/// Personal and accesses section — institutional user card, linked devices,
/// global status and master actions (SnackBar placeholders).
class PersonalAccessesSection extends StatelessWidget {
  final UserIdentity user;

  const PersonalAccessesSection({super.key, required this.user});

  static const List<BleDevice> _linkedDevices = [
    BleDevice(
      name: 'PLC-001',
      mac: 'C1:51:53:9E:6A:17',
      model: 'S7-1200',
      family: 'SIMATIC',
      hardware: '6ES7214-1HG40-0XB0',
      connectionState: BleConnectionState.connected,
      modifiedBy: 'tech_mantenimiento',
      voltage: 24.0,
      temperature: 45.0,
      authorized: true,
      licenseExpired: false,
    ),
    BleDevice(
      name: 'PLC-002',
      mac: 'C1:51:53:9E:6A:18',
      model: 'S7-1500',
      family: 'SIMATIC',
      hardware: '6ES7511-1AK02-0AB0',
      connectionState: BleConnectionState.disconnected,
      modifiedBy: 'tech_mantenimiento',
      voltage: 24.0,
      temperature: 38.0,
      authorized: true,
      licenseExpired: false,
    ),
    BleDevice(
      name: 'PLC-003',
      mac: 'C1:51:53:9E:6A:19',
      model: 'M221',
      family: 'Modicon',
      hardware: 'TM221CE24R',
      connectionState: BleConnectionState.connected,
      modifiedBy: 'admin_principal',
      voltage: 12.0,
      temperature: 41.0,
      authorized: true,
      licenseExpired: false,
    ),
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
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(DesignTokens.spaceMd),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: DesignTokens.govBlue.withValues(alpha: 0.15),
                  child: Text(
                    _initials,
                    style: const TextStyle(
                      color: DesignTokens.govBlue,
                      fontWeight: FontWeight.bold,
                      fontSize: DesignTokens.textLg,
                    ),
                  ),
                ),
                const SizedBox(width: DesignTokens.spaceMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Usuario Institucional',
                        style: TextStyle(
                          fontSize: DesignTokens.textSm,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: DesignTokens.spaceXs),
                      Text(
                        user.username,
                        style: const TextStyle(
                          fontSize: DesignTokens.textLg,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        user.email,
                        style: TextStyle(
                          fontSize: DesignTokens.textSm,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                StatusBadge(
                  label: user.rol.displayName,
                  tone: _roleTone(user.rol),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: DesignTokens.spaceLg),
        const Text(
          'Equipos vinculados',
          style: TextStyle(
            fontSize: DesignTokens.textLg,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: DesignTokens.spaceMd),
        for (final device in _linkedDevices)
          DeviceCard(device: device, onTap: () {}),
        const SizedBox(height: DesignTokens.spaceLg),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Flexible(
              child: _GlobalStatusCard(),
            ),
            const SizedBox(width: DesignTokens.spaceMd),
            const Flexible(
              child: _MasterActionsCard(),
            ),
          ],
        ),
      ],
    );
  }

  String get _initials {
    final username = user.username;
    return username.length >= 2
        ? username.substring(0, 2).toUpperCase()
        : username.toUpperCase();
  }
}

class _GlobalStatusCard extends StatelessWidget {
  const _GlobalStatusCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(DesignTokens.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Estatus Global',
              style: TextStyle(
                fontSize: DesignTokens.textLg,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: DesignTokens.spaceMd),
            const StatusBadge(label: 'Operativo', tone: StatusTone.success),
            const SizedBox(height: DesignTokens.spaceSm),
            Text(
              'Todos los servicios operativos, sin alertas críticas.',
              style: TextStyle(
                fontSize: DesignTokens.textSm,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MasterActionsCard extends StatelessWidget {
  const _MasterActionsCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(DesignTokens.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Acciones Maestras',
              style: TextStyle(
                fontSize: DesignTokens.textLg,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: DesignTokens.spaceMd),
            SizedBox(
              width: double.infinity,
              child: AppButton(
                label: 'Vincular Studio',
                icon: Icons.link,
                onPressed: () => _showPlaceholder(context, 'Vincular Studio'),
              ),
            ),
            const SizedBox(height: DesignTokens.spaceSm),
            SizedBox(
              width: double.infinity,
              child: AppButton(
                label: 'Vincular Android',
                icon: Icons.smartphone,
                color: DesignTokens.safeGreen,
                onPressed: () => _showPlaceholder(context, 'Vincular Android'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPlaceholder(BuildContext context, String action) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$action disponible en un próximo sprint'),
      ),
    );
  }
}