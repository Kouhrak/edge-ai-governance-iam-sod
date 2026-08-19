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
      child: Column(
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
                  Expanded(
                    flex: column.flex,
                    child: Text(
                      column.label,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                if (rows.any((row) => row.actions != null))
                  const SizedBox(width: DesignTokens.spaceXl),
              ],
            ),
          ),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: rows.length,
              itemBuilder: (context, index) {
                final row = rows[index];
                return Container(
                  padding: const EdgeInsets.all(DesignTokens.spaceMd),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey[200]!),
                    ),
                  ),
                  child: Row(
                    children: [
                      for (var c = 0; c < row.cells.length; c++)
                        Expanded(
                          flex: columns[c].flex,
                          child: row.cells[c],
                        ),
                      if (row.actions != null) ...[
                        const SizedBox(width: DesignTokens.spaceSm),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: row.actions!,
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}