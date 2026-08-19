import 'package:flutter/material.dart';
import '../../theme/design_tokens.dart';
import '../atoms/status_badge.dart';

/// Production checklist card — 48x48 tactile checkbox, optional CRÍTICO
/// badge (safetyRed). Consumed by tests now; Loader production checklist
/// reuses it in Sprint 2.
class ChecklistCard extends StatelessWidget {
  final String title;
  final String description;
  final bool isCritical;
  final bool isCompleted;
  final VoidCallback onToggle;

  const ChecklistCard({
    super.key,
    required this.title,
    required this.description,
    this.isCritical = false,
    this.isCompleted = false,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: DesignTokens.spaceSm),
      child: InkWell(
        onTap: onToggle,
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        child: Container(
          padding: const EdgeInsets.all(DesignTokens.spaceMd),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
            border: Border.all(
              color: isCompleted
                  ? DesignTokens.safeGreen
                  : isCritical
                      ? DesignTokens.safetyRed.withValues(alpha: 0.5)
                      : Colors.grey.withValues(alpha: 0.3),
              width: isCompleted ? 2 : 1,
            ),
            color: isCompleted
                ? DesignTokens.safeGreen.withValues(alpha: 0.05)
                : null,
          ),
          child: Row(
            children: [
              Container(
                width: DesignTokens.tactileMinSize,
                height: DesignTokens.tactileMinSize,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? DesignTokens.safeGreen
                      : Colors.transparent,
                  border: Border.all(
                    color: isCompleted
                        ? DesignTokens.safeGreen
                        : isCritical
                            ? DesignTokens.safetyRed
                            : Colors.grey,
                    width: 2,
                  ),
                  borderRadius:
                      BorderRadius.circular(DesignTokens.radiusSm),
                ),
                child: isCompleted
                    ? const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 32,
                      )
                    : isCritical
                        ? Icon(
                            Icons.star,
                            color: DesignTokens.safetyRed,
                            size: DesignTokens.textXl,
                          )
                        : null,
              ),
              const SizedBox(width: DesignTokens.spaceMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontSize: DesignTokens.textLg,
                              fontWeight: FontWeight.bold,
                              color: isCompleted
                                  ? Colors.grey[600]
                                  : Colors.black,
                              decoration: isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                        ),
                        if (isCritical)
                          const StatusBadge(
                            label: 'CRÍTICO',
                            tone: StatusTone.danger,
                          ),
                      ],
                    ),
                    const SizedBox(height: DesignTokens.spaceXs),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: DesignTokens.textMd,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}