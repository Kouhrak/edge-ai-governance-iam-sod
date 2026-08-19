import 'package:flutter/material.dart';
import '../../theme/design_tokens.dart';

/// White top bar with 24px bold title, optional subtitle, optional search
/// field and trailing actions.
class TopBar extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? searchHint;
  final ValueChanged<String>? onSearchChanged;
  final List<Widget>? actions;

  const TopBar({
    super.key,
    required this.title,
    this.subtitle,
    this.searchHint,
    this.onSearchChanged,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.spaceLg,
        vertical: DesignTokens.spaceMd,
      ),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: DesignTokens.textXl2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: DesignTokens.textSm,
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ),
          if (searchHint != null) ...[
            SizedBox(
              width: 300,
              child: TextField(
                onChanged: onSearchChanged ?? (_) {},
                decoration: InputDecoration(
                  hintText: searchHint,
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(DesignTokens.radiusMd),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: DesignTokens.spaceMd,
                  ),
                ),
              ),
            ),
            const SizedBox(width: DesignTokens.spaceMd),
          ],
          ...?actions,
        ],
      ),
    );
  }
}