import 'package:flutter/material.dart';
import '../../../../../core/theme/design_tokens.dart';

/// Events section — placeholder card for the events management view.
class EventsSection extends StatelessWidget {
  const EventsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(DesignTokens.spaceLg),
      children: [
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(DesignTokens.spaceXl),
            child: Column(
              children: [
                Icon(Icons.event_busy, size: 48, color: Colors.grey[400]),
                const SizedBox(height: DesignTokens.spaceMd),
                const Text(
                  'En desarrollo',
                  style: TextStyle(
                    fontSize: DesignTokens.textLg,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: DesignTokens.spaceXs),
                Text(
                  'Gestión de eventos disponible en un próximo sprint',
                  style: TextStyle(
                    fontSize: DesignTokens.textSm,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}