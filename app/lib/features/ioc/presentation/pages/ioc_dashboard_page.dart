import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/organisms/side_navigation.dart';
import '../../../../core/widgets/organisms/top_bar.dart';
import '../../../auth/domain/entities/user_identity.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import 'sections/access_management_section.dart';
import 'sections/dashboard_section.dart';
import 'sections/events_section.dart';
import 'sections/personal_accesses_section.dart';

/// IOC Dashboard shell — Penpot web layout: side navigation, top bar and an
/// IndexedStack of the four administrative sections.
class IocDashboardPage extends StatefulWidget {
  final UserIdentity currentUser;

  const IocDashboardPage({super.key, required this.currentUser});

  @override
  State<IocDashboardPage> createState() => _IocDashboardPageState();
}

class _IocDashboardPageState extends State<IocDashboardPage> {
  static const List<NavItemData> _navItems = [
    NavItemData(icon: Icons.dashboard, label: 'Dashboard'),
    NavItemData(icon: Icons.people, label: 'Gestión de Accesos'),
    NavItemData(icon: Icons.badge, label: 'Personal y Accesos'),
    NavItemData(icon: Icons.event, label: 'Gestion de eventos'),
  ];

  int _selectedIndex = 0;

  String get _avatarInitials {
    final username = widget.currentUser.username;
    return username.length >= 2
        ? username.substring(0, 2).toUpperCase()
        : username.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          SideNavigation(
            items: _navItems,
            selectedIndex: _selectedIndex,
            onSelect: (index) => setState(() => _selectedIndex = index),
            username: widget.currentUser.username,
            roleLabel: widget.currentUser.rol.displayName,
            avatarInitials: _avatarInitials,
            onLogout: () =>
                context.read<AuthBloc>().add(const LogoutRequested()),
          ),
          Expanded(
            child: Column(
              children: [
                TopBar(
                  title: _navItems[_selectedIndex].label,
                  searchHint: 'Buscar...',
                ),
                Expanded(
                  child: IndexedStack(
                    index: _selectedIndex,
                    children: [
                      const DashboardSection(),
                      const AccessManagementSection(),
                      PersonalAccessesSection(user: widget.currentUser),
                      const EventsSection(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}