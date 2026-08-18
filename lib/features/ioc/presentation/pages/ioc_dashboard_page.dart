import 'package:flutter/material.dart';
import '../../../../core/theme/design_tokens.dart';
import '../../../auth/domain/entities/user_identity.dart';

/// IOC Dashboard Page - Panel de Control Administrativo
/// Desktop layout for administrative management
/// Shows user list and roles controlled by AuthBloc
class IocDashboardPage extends StatefulWidget {
  final UserIdentity currentUser;

  const IocDashboardPage({super.key, required this.currentUser});

  @override
  State<IocDashboardPage> createState() => _IocDashboardPageState();
}

class _IocDashboardPageState extends State<IocDashboardPage> {
  int _selectedNavItem = 0;
  
  // Mock users list - in real app, this comes from database
  final List<Map<String, dynamic>> _mockUsers = [
    {
      'id': '1',
      'username': 'admin_principal',
      'email': 'admin@edge-ai.com',
      'role': UserRole.administrador,
      'active': true,
      'lastLogin': '2026-08-18 10:30',
    },
    {
      'id': '2',
      'username': 'tech_mantenimiento',
      'email': 'tech@edge-ai.com',
      'role': UserRole.tecnico,
      'active': true,
      'lastLogin': '2026-08-18 09:15',
    },
    {
      'id': '3',
      'username': 'operador_piso',
      'email': 'operador@edge-ai.com',
      'role': UserRole.operador,
      'active': true,
      'lastLogin': '2026-08-18 08:00',
    },
    {
      'id': '4',
      'username': 'externo_auditor',
      'email': 'externo@edge-ai.com',
      'role': UserRole.externo,
      'active': false,
      'lastLogin': '2026-08-15 14:20',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Side navigation panel
          _buildSideNavigation(),
          
          // Main content area
          Expanded(
            child: _buildMainContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildSideNavigation() {
    return Container(
      width: 250,
      color: const Color(DesignTokens.govBlue),
      child: Column(
        children: [
          // User info header
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Text(
                    widget.currentUser.username.substring(0, 2).toUpperCase(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(DesignTokens.govBlue),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.currentUser.username,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  widget.currentUser.rol.displayName,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          
          const Divider(color: Colors.white30),
          
          // Navigation items
          _buildNavItem(0, Icons.dashboard, 'Dashboard'),
          _buildNavItem(1, Icons.people, 'Usuarios'),
          _buildNavItem(2, Icons.security, 'SoD Matrix'),
          _buildNavItem(3, Icons.inventory, 'Activos'),
          _buildNavItem(4, Icons.history, 'Auditoría'),
          
          const Spacer(),
          
          // Logout button
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  // TODO: Dispatch logout event
                },
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text(
                  'Cerrar Sesión',
                  style: TextStyle(color: Colors.white),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white30),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedNavItem == index;
    
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? Colors.white : Colors.white70,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.white70,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedTileColor: Colors.white.withOpacity(0.1),
      onTap: () {
        setState(() {
          _selectedNavItem = index;
        });
      },
    );
  }

  Widget _buildMainContent() {
    return Container(
      color: Colors.grey[100],
      child: Column(
        children: [
          // Top bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            color: Colors.white,
            child: Row(
              children: [
                Text(
                  _getNavItemTitle(),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                // Search field
                SizedBox(
                  width: 300,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Buscar...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Add user button
                if (_selectedNavItem == 1)
                  ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Add new user
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Agregar Usuario'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(DesignTokens.safeGreen),
                    ),
                  ),
              ],
            ),
          ),
          
          // Content based on selected nav item
          Expanded(
            child: _buildContentForNavItem(),
          ),
        ],
      ),
    );
  }

  String _getNavItemTitle() {
    switch (_selectedNavItem) {
      case 0:
        return 'Dashboard';
      case 1:
        return 'Gestión de Usuarios';
      case 2:
        return 'Matriz SoD';
      case 3:
        return 'Gestión de Activos';
      case 4:
        return 'Registro de Auditoría';
      default:
        return 'Dashboard';
    }
  }

  Widget _buildContentForNavItem() {
    switch (_selectedNavItem) {
      case 0:
        return _buildDashboardContent();
      case 1:
        return _buildUsersContent();
      case 2:
        return _buildSoDContent();
      case 3:
        return _buildAssetsContent();
      case 4:
        return _buildAuditContent();
      default:
        return _buildDashboardContent();
    }
  }

  Widget _buildDashboardContent() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats cards
          Row(
            children: [
              _buildStatCard('Usuarios Activos', '3', Icons.people, const Color(DesignTokens.safeGreen)),
              const SizedBox(width: 16),
              _buildStatCard('Activos Registrados', '12', Icons.inventory, const Color(DesignTokens.govBlue)),
              const SizedBox(width: 16),
              _buildStatCard('Violaciones SoD', '0', Icons.warning, const Color(DesignTokens.safetyRed)),
              const SizedBox(width: 16),
              _buildStatCard('Última Auditoría', 'Hoy', Icons.history, const Color(DesignTokens.warningYellow)),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Recent activity
          Expanded(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Actividad Reciente',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView(
                        children: [
                          _buildActivityItem('tech_mantenimiento', 'Inició sesión', '10:30 AM'),
                          _buildActivityItem('admin_principal', 'Aprobó orden de trabajo #456', '09:45 AM'),
                          _buildActivityItem('operador_piso', 'Completó checklist de seguridad', '09:00 AM'),
                          _buildActivityItem('tech_mantenimiento', 'Inyectó firmware en PLC-001', '08:30 AM'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 24),
                  const Spacer(),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityItem(String user, String action, String time) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: const Color(DesignTokens.govBlue).withOpacity(0.1),
        child: Text(
          user.substring(0, 2).toUpperCase(),
          style: const TextStyle(
            color: Color(DesignTokens.govBlue),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(action),
      subtitle: Text(user),
      trailing: Text(
        time,
        style: TextStyle(color: Colors.grey[600]),
      ),
    );
  }

  Widget _buildUsersContent() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Card(
        child: Column(
          children: [
            // Table header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border(
                  bottom: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              child: const Row(
                children: [
                  Expanded(flex: 2, child: Text('Usuario', style: TextStyle(fontWeight: FontWeight.bold))),
                  Expanded(flex: 2, child: Text('Email', style: TextStyle(fontWeight: FontWeight.bold))),
                  Expanded(flex: 1, child: Text('Rol', style: TextStyle(fontWeight: FontWeight.bold))),
                  Expanded(flex: 1, child: Text('Estado', style: TextStyle(fontWeight: FontWeight.bold))),
                  Expanded(flex: 1, child: Text('Último Login', style: TextStyle(fontWeight: FontWeight.bold))),
                  Expanded(flex: 1, child: Text('Acciones', style: TextStyle(fontWeight: FontWeight.bold))),
                ],
              ),
            ),
            
            // Table body
            Expanded(
              child: ListView.builder(
                itemCount: _mockUsers.length,
                itemBuilder: (context, index) {
                  final user = _mockUsers[index];
                  return _buildUserRow(user);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserRow(Map<String, dynamic> user) {
    final role = user['role'] as UserRole;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: _getRoleColor(role).withOpacity(0.1),
                  child: Text(
                    user['username'].substring(0, 2).toUpperCase(),
                    style: TextStyle(
                      color: _getRoleColor(role),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(user['username'], style: const TextStyle(fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          Expanded(flex: 2, child: Text(user['email'])),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getRoleColor(role).withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                role.displayName,
                style: TextStyle(
                  color: _getRoleColor(role),
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Icon(
              user['active'] ? Icons.check_circle : Icons.cancel,
              color: user['active'] ? const Color(DesignTokens.safeGreen) : const Color(DesignTokens.safetyRed),
            ),
          ),
          Expanded(flex: 1, child: Text(user['lastLogin'])),
          Expanded(
            flex: 1,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: () {
                    // TODO: Edit user
                  },
                  tooltip: 'Editar',
                ),
                IconButton(
                  icon: const Icon(Icons.delete, size: 20, color: Color(DesignTokens.safetyRed)),
                  onPressed: () {
                    // TODO: Delete user
                  },
                  tooltip: 'Eliminar',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.administrador:
        return const Color(DesignTokens.govBlue);
      case UserRole.tecnico:
        return const Color(DesignTokens.safeGreen);
      case UserRole.operador:
        return const Color(DesignTokens.warningYellow);
      case UserRole.externo:
        return Colors.grey;
      case UserRole.superUsuario:
        return const Color(DesignTokens.safetyRed);
    }
  }

  Widget _buildSoDContent() {
    return const Padding(
      padding: EdgeInsets.all(24),
      child: Card(
        child: Center(
          child: Text(
            'Matriz SoD - Próximamente',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ),
      ),
    );
  }

  Widget _buildAssetsContent() {
    return const Padding(
      padding: EdgeInsets.all(24),
      child: Card(
        child: Center(
          child: Text(
            'Gestión de Activos - Próximamente',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ),
      ),
    );
  }

  Widget _buildAuditContent() {
    return const Padding(
      padding: EdgeInsets.all(24),
      child: Card(
        child: Center(
          child: Text(
            'Registro de Auditoría - Próximamente',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ),
      ),
    );
  }
}