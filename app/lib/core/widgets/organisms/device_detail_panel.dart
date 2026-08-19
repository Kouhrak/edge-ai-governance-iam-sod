import 'package:flutter/material.dart';
import '../../../features/loader/domain/entities/ble_device.dart';
import '../../theme/design_tokens.dart';
import '../atoms/status_badge.dart';
import '../molecules/device_card.dart';

/// Loader device detail panel — Familia/Modelo, connection StatusBadge,
/// Hardware, MAC, Nombre, Modificada por, Voltaje/Temperatura and
/// Autorizada/Congelada status.
class DeviceDetailPanel extends StatelessWidget {
  final BleDevice device;

  const DeviceDetailPanel({
    super.key,
    required this.device,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(DesignTokens.spaceLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    device.name,
                    style: const TextStyle(
                      fontSize: DesignTokens.textXl,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                StatusBadge(
                  label: device.connectionState.label,
                  tone: device.connectionState.tone,
                ),
              ],
            ),
            const SizedBox(height: DesignTokens.spaceLg),
            _DetailRow(
              label: 'Familia/Modelo',
              value: '${device.family} / ${device.model}',
            ),
            _DetailRow(label: 'Hardware', value: device.hardware),
            _DetailRow(label: 'Dirección MAC', value: device.mac),
            _DetailRow(label: 'Nombre', value: device.name),
            _DetailRow(label: 'Modificada por', value: device.modifiedBy),
            _DetailRow(
              label: 'Voltaje/Temperatura',
              value:
                  '${device.voltage.toStringAsFixed(1)} V / '
                  '${device.temperature.toStringAsFixed(1)} °C',
            ),
            _DetailRow(
              label: 'Autorizada/Congelada',
              value: device.authorized ? 'Autorizada' : 'Congelada',
              valueWidget: StatusBadge(
                label: device.authorized ? 'Autorizada' : 'Congelada',
                tone: device.authorized
                    ? StatusTone.success
                    : StatusTone.danger,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Widget? valueWidget;

  const _DetailRow({
    required this.label,
    required this.value,
    this.valueWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: DesignTokens.spaceSm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 160,
            child: Text(
              label,
              style: TextStyle(
                fontSize: DesignTokens.textSm,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: valueWidget ??
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: DesignTokens.textMd,
                    fontWeight: FontWeight.w500,
                  ),
                ),
          ),
        ],
      ),
    );
  }
}