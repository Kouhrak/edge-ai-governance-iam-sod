import 'package:flutter/material.dart';
import '../../../../core/theme/design_tokens.dart';

/// Checklist item for production security verification
class ChecklistItem {
  final String id;
  final String title;
  final String description;
  final bool isCritical;
  bool isCompleted;

  ChecklistItem({
    required this.id,
    required this.title,
    required this.description,
    this.isCritical = false,
    this.isCompleted = false,
  });
}

/// Loader Checklist Page - "Checklist de Producción"
/// Tactile verification form for technicians before firmware injection
/// High visibility checkboxes for industrial tablet use
class ChecklistPage extends StatefulWidget {
  const ChecklistPage({super.key});

  @override
  State<ChecklistPage> createState() => _ChecklistPageState();
}

class _ChecklistPageState extends State<ChecklistPage> {
  final List<ChecklistItem> _checklistItems = [
    ChecklistItem(
      id: '1',
      title: 'Verificación de Identidad',
      description: 'Confirmar identidad del técnico con credencial biométrica',
      isCritical: true,
    ),
    ChecklistItem(
      id: '2',
      title: 'Estado del Activo',
      description: 'Verificar que el activo esté en modo mantenimiento',
      isCritical: true,
    ),
    ChecklistItem(
      id: '3',
      title: 'Aprobación de Orden',
      description: 'Confirmar que la orden de trabajo esté aprobada por administrador',
      isCritical: true,
    ),
    ChecklistItem(
      id: '4',
      title: 'Conexión BLE',
      description: 'Establecer conexión Bluetooth Low Energy con el dispositivo',
      isCritical: false,
    ),
    ChecklistItem(
      id: '5',
      title: 'Validación SoD',
      description: 'Verificar que no exista conflicto de segregación de funciones',
      isCritical: true,
    ),
    ChecklistItem(
      id: '6',
      title: 'Backup Actual',
      description: 'Crear respaldo del firmware actual antes de inyección',
      isCritical: false,
    ),
    ChecklistItem(
      id: '7',
      title: 'Firmware Verificado',
      description: 'Confirmar integridad del archivo .bin con hash SHA-256',
      isCritical: true,
    ),
  ];

  bool get _allCriticalCompleted {
    return _checklistItems
        .where((item) => item.isCritical)
        .every((item) => item.isCompleted);
  }

  int get _completedCount {
    return _checklistItems.where((item) => item.isCompleted).length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checklist de Producción'),
        backgroundColor: DesignTokens.govBlue,
        foregroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Text(
                '$_completedCount/${_checklistItems.length}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress indicator
          LinearProgressIndicator(
            value: _completedCount / _checklistItems.length,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              _allCriticalCompleted ? DesignTokens.safeGreen : DesignTokens.warningYellow,
            ),
            minHeight: 8,
          ),
          
          // Warning banner if critical items pending
          if (!_allCriticalCompleted)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: DesignTokens.warningYellow.withOpacity(0.2),
              child: Row(
                children: [
                  Icon(Icons.warning, color: DesignTokens.warningYellow),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Complete todos los items críticos para habilitar la inyección',
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          
          // Checklist items
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _checklistItems.length,
              itemBuilder: (context, index) {
                final item = _checklistItems[index];
                return _buildChecklistItem(item);
              },
            ),
          ),
          
          // Action buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _resetChecklist,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Colors.grey),
                    ),
                    child: const Text('Reiniciar'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _allCriticalCompleted ? _proceedToFlash : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _allCriticalCompleted 
                          ? DesignTokens.safeGreen 
                          : Colors.grey,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      disabledBackgroundColor: Colors.grey[300],
                    ),
                    child: const Text(
                      'Proceder a Inyección',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChecklistItem(ChecklistItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: item.isCompleted ? 1 : 3,
      child: InkWell(
        onTap: () => _toggleItem(item),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: item.isCompleted 
                  ? DesignTokens.safeGreen
                  : item.isCritical 
                      ? DesignTokens.safetyRed.withOpacity(0.5)
                      : Colors.grey.withOpacity(0.3),
              width: item.isCompleted ? 2 : 1,
            ),
            color: item.isCompleted 
                ? DesignTokens.safeGreen.withOpacity(0.05)
                : null,
          ),
          child: Row(
            children: [
              // Large tactile checkbox
              Container(
                width: 48, // Minimum touch target size
                height: 48,
                decoration: BoxDecoration(
                  color: item.isCompleted 
                      ? DesignTokens.safeGreen
                      : Colors.transparent,
                  border: Border.all(
                    color: item.isCompleted 
                        ? DesignTokens.safeGreen
                        : item.isCritical 
                            ? DesignTokens.safetyRed
                            : Colors.grey,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: item.isCompleted
                    ? const Icon(Icons.check, color: Colors.white, size: 32)
                    : item.isCritical
                        ? Icon(Icons.star, color: DesignTokens.safetyRed, size: 24)
                        : null,
              ),
              const SizedBox(width: 16),
              
              // Item details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: item.isCompleted ? Colors.grey[600] : Colors.black,
                              decoration: item.isCompleted ? TextDecoration.lineThrough : null,
                            ),
                          ),
                        ),
                        if (item.isCritical)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: DesignTokens.safetyRed.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'CRÍTICO',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: DesignTokens.safetyRed,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.description,
                      style: TextStyle(
                        fontSize: 14,
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

  void _toggleItem(ChecklistItem item) {
    setState(() {
      item.isCompleted = !item.isCompleted;
    });
  }

  void _resetChecklist() {
    setState(() {
      for (var item in _checklistItems) {
        item.isCompleted = false;
      }
    });
  }

  void _proceedToFlash() {
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Inyección'),
        content: const Text(
          '¿Está seguro de que desea proceder con la inyección de firmware? '
          'Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Navigate to firmware injection page
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Iniciando proceso de inyección...'),
                  backgroundColor: DesignTokens.safeGreen,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: DesignTokens.safeGreen,
            ),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }
}