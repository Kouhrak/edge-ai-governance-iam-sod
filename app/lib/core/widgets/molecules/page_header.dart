import 'package:flutter/material.dart';
import '../../theme/design_tokens.dart';

/// Section header molecule — title, optional subtitle, optional search
/// field and trailing actions.
class PageHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  final String? searchHint;
  final ValueChanged<String>? onSearchChanged;

  const PageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
    this.searchHint,
    this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
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
              if (subtitle != null) ...[
                const SizedBox(height: DesignTokens.spaceXs),
                Text(
                  subtitle!,
                  style: TextStyle(
                    fontSize: DesignTokens.textMd,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ],
          ),
        ),
        if (searchHint != null) ...[
          SizedBox(
            width: 260,
            child: TextField(
              onChanged: onSearchChanged ?? (_) {},
              decoration: InputDecoration(
                hintText: searchHint,
                prefixIcon: const Icon(Icons.search),
                isDense: true,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(DesignTokens.radiusMd),
                ),
              ),
            ),
          ),
          const SizedBox(width: DesignTokens.spaceMd),
        ],
        ...?actions,
      ],
    );
  }
}