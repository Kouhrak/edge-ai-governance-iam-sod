import 'package:flutter/material.dart';
import '../../../../../core/theme/design_tokens.dart';
import '../../../../../core/widgets/atoms/status_badge.dart';
import '../../../../../core/widgets/molecules/stat_card.dart';
import '../../../../../core/widgets/organisms/data_table.dart' as dt;

/// Dashboard section — global access metrics, authorized entry log,
/// security alerts and a static 7-day traffic placeholder.
class DashboardSection extends StatelessWidget {
  const DashboardSection({super.key});

  static const List<(String, String, String)> _authorizedEntries = [
    ('tech_mantenimiento', 'PLC-001', '10:30'),
    ('operador_piso', 'PLC-002', '09:15'),
    ('admin_principal', 'PLC-003', '08:45'),
    ('tech_mantenimiento', 'PLC-004', '08:00'),
  ];

  static const List<(String, String)> _blockedAlerts = [
    ('externo_auditor', 'Intento de acceso no autorizado'),
    ('admin_principal', 'Acceso desde plataforma no autorizada'),
    ('tech_mantenimiento', 'Inyección de firmware sin aprobación SoD'),
  ];

  static const List<(String, int)> _traffic = [
    ('Lun', 6),
    ('Mar', 9),
    ('Mié', 7),
    ('Jue', 12),
    ('Vie', 8),
    ('Sáb', 14),
    ('Dom', 10),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(DesignTokens.spaceLg),
      children: [
        const Row(
          children: [
            Expanded(
              child: StatCard(
                title: 'Usuarios Activos',
                value: '3',
                icon: Icons.people,
                color: DesignTokens.safeGreen,
              ),
            ),
            SizedBox(width: DesignTokens.spaceMd),
            Expanded(
              child: StatCard(
                title: 'Equipos Vinculados',
                value: '12',
                icon: Icons.devices,
                color: DesignTokens.govBlue,
              ),
            ),
            SizedBox(width: DesignTokens.spaceMd),
            Expanded(
              child: StatCard(
                title: 'Alertas de Seguridad',
                value: '2',
                icon: Icons.warning,
                color: DesignTokens.safetyRed,
              ),
            ),
            SizedBox(width: DesignTokens.spaceMd),
            Expanded(
              child: StatCard(
                title: 'Última Auditoría',
                value: 'Hoy',
                icon: Icons.history,
                color: DesignTokens.warningYellow,
              ),
            ),
          ],
        ),
        const SizedBox(height: DesignTokens.spaceLg),
        const Text(
          'Registros de entradas Autorizadas',
          style: TextStyle(
            fontSize: DesignTokens.textLg,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: DesignTokens.spaceMd),
        dt.DataTable(
          columns: const [
            dt.DataTableColumn(label: 'Usuario', flex: 2),
            dt.DataTableColumn(label: 'Dispositivo', flex: 2),
            dt.DataTableColumn(label: 'Hora'),
            dt.DataTableColumn(label: 'Estado'),
          ],
          rows: [
            for (final entry in _authorizedEntries)
              dt.DataTableRow(
                cells: [
                  Text(entry.$1),
                  Text(entry.$2),
                  Text(entry.$3),
                  const StatusBadge(
                    label: 'Autorizado',
                    tone: StatusTone.success,
                  ),
                ],
              ),
          ],
        ),
        const SizedBox(height: DesignTokens.spaceLg),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Flexible(
              flex: 3,
              child: _SecurityAlertsCard(),
            ),
            const SizedBox(width: DesignTokens.spaceMd),
            const Flexible(
              flex: 2,
              child: _TrafficCard(),
            ),
          ],
        ),
      ],
    );
  }
}

class _SecurityAlertsCard extends StatelessWidget {
  const _SecurityAlertsCard();

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
              'Alertas de Seguridad',
              style: TextStyle(
                fontSize: DesignTokens.textLg,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Accesos bloqueados por la política SoD',
              style: TextStyle(fontSize: DesignTokens.textSm, color: Colors.grey[600]),
            ),
            const SizedBox(height: DesignTokens.spaceMd),
            for (final alert in DashboardSection._blockedAlerts)
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: DesignTokens.spaceSm,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.block,
                      size: DesignTokens.textXl,
                      color: DesignTokens.safetyRed,
                    ),
                    const SizedBox(width: DesignTokens.spaceSm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            alert.$1,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          Text(
                            alert.$2,
                            style: TextStyle(
                              fontSize: DesignTokens.textSm,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const StatusBadge(
                      label: 'Bloqueado',
                      tone: StatusTone.danger,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TrafficCard extends StatelessWidget {
  const _TrafficCard();

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
              'Tráfico de Aplicaciones',
              style: TextStyle(
                fontSize: DesignTokens.textLg,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Últimos 7 días',
              style: TextStyle(fontSize: DesignTokens.textSm, color: Colors.grey[600]),
            ),
            const SizedBox(height: DesignTokens.spaceLg),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (final (day, height) in DashboardSection._traffic)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: DesignTokens.spaceLg,
                        height: (height * 4).toDouble().clamp(20.0, 80.0),
                        decoration: BoxDecoration(
                          color: DesignTokens.govBlue,
                          borderRadius: BorderRadius.circular(
                            DesignTokens.radiusSm,
                          ),
                        ),
                      ),
                      const SizedBox(height: DesignTokens.spaceXs),
                      Text(
                        day,
                        style: TextStyle(
                          fontSize: DesignTokens.textXs,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}