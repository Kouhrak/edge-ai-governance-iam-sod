import 'package:flutter/material.dart';
import '../../theme/design_tokens.dart';
import '../atoms/app_button.dart';
import '../molecules/nav_item.dart';

/// Navigation entry descriptor for [SideNavigation].
class NavItemData {
  final IconData icon;
  final String label;

  const NavItemData({required this.icon, required this.label});
}

/// 250px govBlue side column: user header (avatar + role), nav items,
/// logout. Composes the NavItem molecule.
class SideNavigation extends StatelessWidget {
  final List<NavItemData> items;
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final String username;
  final String roleLabel;
  final String avatarInitials;
  final VoidCallback onLogout;

  const SideNavigation({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelect,
    required this.username,
    required this.roleLabel,
    required this.avatarInitials,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: DesignTokens.govBlue,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(DesignTokens.spaceMd),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Text(
                    avatarInitials,
                    style: const TextStyle(
                      fontSize: DesignTokens.textXl,
                      fontWeight: FontWeight.bold,
                      color: DesignTokens.govBlue,
                    ),
                  ),
                ),
                const SizedBox(height: DesignTokens.spaceSm),
                Text(
                  username,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: DesignTokens.textMd,
                  ),
                ),
                Text(
                  roleLabel,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: DesignTokens.textSm,
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white30),
          for (var i = 0; i < items.length; i++)
            NavItem(
              icon: items[i].icon,
              label: items[i].label,
              selected: i == selectedIndex,
              onTap: () => onSelect(i),
            ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(DesignTokens.spaceMd),
            child: SizedBox(
              width: double.infinity,
              child: AppButton(
                label: 'Cerrar Sesión',
                onPressed: onLogout,
                variant: AppButtonVariant.outlined,
                icon: Icons.logout,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}