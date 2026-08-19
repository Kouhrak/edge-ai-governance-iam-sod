import 'package:flutter/material.dart';
import '../../../features/loader/domain/entities/ble_device.dart';
import '../../theme/design_tokens.dart';
import '../atoms/status_badge.dart';

/// Spanish label and badge tone for a BLE connection state.
extension BleConnectionStateUi on BleConnectionState {
  String get label {
    switch (this) {
      case BleConnectionState.disconnected:
        return 'Desconectado';
      case BleConnectionState.connecting:
        return 'Conectando…';
      case BleConnectionState.connected:
        return 'Conectado';
    }
  }

  StatusTone get tone {
    switch (this) {
      case BleConnectionState.disconnected:
        return StatusTone.neutral;
      case BleConnectionState.connecting:
        return StatusTone.warning;
      case BleConnectionState.connected:
        return StatusTone.success;
    }
  }
}

/// BLE device card — name, MAC, connection StatusBadge and optional
/// trailing actions (Studio device list).
class DeviceCard extends StatelessWidget {
  final BleDevice device;
  final VoidCallback onTap;
  final List<Widget>? actions;

  const DeviceCard({
    super.key,
    required this.device,
    required this.onTap,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: DesignTokens.spaceSm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(DesignTokens.spaceMd),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      device.name,
                      style: const TextStyle(
                        fontSize: DesignTokens.textLg,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: DesignTokens.spaceXs),
                    Text(
                      device.mac,
                      style: TextStyle(
                        fontSize: DesignTokens.textSm,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: DesignTokens.spaceSm),
                    StatusBadge(
                      label: device.connectionState.label,
                      tone: device.connectionState.tone,
                    ),
                  ],
                ),
              ),
              if (actions != null)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: actions!,
                ),
            ],
          ),
        ),
      ),
    );
  }
}