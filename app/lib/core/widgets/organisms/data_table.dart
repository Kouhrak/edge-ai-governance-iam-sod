import 'package:flutter/material.dart';
import '../../theme/design_tokens.dart';

/// Column descriptor for [DataTable].
class DataTableColumn {
  final String label;
  final int flex;

  const DataTableColumn({required this.label, this.flex = 1});
}

/// Row descriptor for [DataTable] — free-form cells plus optional actions.
class DataTableRow {
  final List<Widget> cells;
  final List<Widget>? actions;

  const DataTableRow({required this.cells, this.actions});
}

/// Header cell with fixed min-width to prevent collapse.
class _DataTableHeaderCell extends StatelessWidget {
  final String label;
  final int flex;

  const _DataTableHeaderCell({required this.label, required this.flex});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: 80.0 * flex),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}

/// Data cell with fixed min-width to prevent collapse.
class _DataTableCell extends StatelessWidget {
  final int flex;
  final Widget child;

  const _DataTableCell({required this.flex, required this.child});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: 80.0 * flex),
      child: child,
    );
  }
}

/// Generic data table organism — bold header row with flexible columns and
/// a scrollable body. Rows may carry trailing action widgets.
class DataTable extends StatelessWidget {
  final List<DataTableColumn> columns;
  final List<DataTableRow> rows;

  const DataTable({
    super.key,
    required this.columns,
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(DesignTokens.spaceMd),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border(
                  bottom: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              child: Row(
                children: [
                  for (final column in columns)
                    _DataTableHeaderCell(
                      label: column.label,
                      flex: column.flex,
                    ),
                  if (rows.any((row) => row.actions != null))
                    SizedBox(
                      width: DesignTokens.spaceXl * 2,
                      child: const Text(
                        'Acciones',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
            ),
            for (final row in rows)
              Container(
                padding: const EdgeInsets.all(DesignTokens.spaceMd),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey[200]!),
                  ),
                ),
                child: Row(
                  children: [
                    for (var c = 0; c < row.cells.length; c++)
                      _DataTableCell(
                        flex: columns[c].flex,
                        child: row.cells[c],
                      ),
                    if (row.actions != null) ...[
                      SizedBox(
                        width: DesignTokens.spaceXl * 2,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: row.actions!,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}