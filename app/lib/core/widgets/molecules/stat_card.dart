import 'package:flutter/material.dart';
import '../../theme/design_tokens.dart';

/// Metric card molecule — 24px bold value in the accent color, icon and
/// optional tap callback (Dashboard metrics).
class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(DesignTokens.spaceMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: DesignTokens.textXl),
                  const Spacer(),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: DesignTokens.textXl2,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: DesignTokens.spaceSm),
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: DesignTokens.textMd,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}