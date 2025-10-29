import 'package:flutter/material.dart';

class DatasInformations extends StatelessWidget {
  final Map<String, dynamic>? cachedData;

  const DatasInformations({super.key, this.cachedData});

  @override
  Widget build(BuildContext context) {
    final dates = cachedData?['selected_dates'] as Map<String, dynamic>?;
    final startDateStr = dates?['start_date_str'] as String?;
    final endDateStr = dates?['end_date_str'] as String?;
    final daysCount = dates?['days_count'] as int? ?? 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Período da Hospedagem',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          if (startDateStr == null || endDateStr == null)
            const Text(
              'Datas não selecionadas',
              style: TextStyle(color: Colors.grey),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDateItem('Data de Check-in', startDateStr),
                _buildDateItem('Data de Check-out', endDateStr),
                const SizedBox(height: 8),
                Text(
                  'Total: $daysCount dias',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildDateItem(String label, String dateStr) {
    final date = DateTime.tryParse(dateStr);
    final formattedDate = date != null
        ? '${date.day}/${date.month}/${date.year}'
        : 'Data inválida';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey[600]),
          ),
          Text(
            formattedDate,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
