// booking/template/booking_template.dart
import 'package:flutter/material.dart';
import 'package:pet_family_app/models/contrato_model.dart';

class BookingTemplate extends StatelessWidget {
  final ContratoModel contrato;
  final VoidCallback onTap;

  const BookingTemplate({
    super.key,
    required this.contrato,
    required this.onTap,
  });

  String _formatarData(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _obterNomeStatus(int idStatus) {
    final statusMap = {
      1: 'Em Aprovação',
      2: 'Aprovado',
      3: 'Em Execução',
      4: 'Concluído',
      5: 'Negado',
      6: 'Cancelado',
    };
    return statusMap[idStatus] ?? 'Desconhecido';
  }

  Color _obterCorStatus(int idStatus) {
    switch (idStatus) {
      case 1:
        return Colors.orange;
      case 2:
        return Colors.green;
      case 3:
        return Colors.blue;
      case 4:
        return Colors.grey;
      case 5:
        return Colors.red;
      case 6:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header com ID e Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Agendamento #${contrato.idContrato ?? "N/A"}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _obterCorStatus(contrato.idStatus).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border:
                        Border.all(color: _obterCorStatus(contrato.idStatus)),
                  ),
                  child: Text(
                    _obterNomeStatus(contrato.idStatus),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: _obterCorStatus(contrato.idStatus),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Período
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${_formatarData(contrato.dataInicio ?? DateTime.now())} - ${_formatarData(contrato.dataFim ?? DateTime.now())}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Hospedagem
            Row(
              children: [
                Icon(Icons.home, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  'Hospedagem #${contrato.idHospedagem}',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),

            if (contrato.dataCriacao != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    'Criado em ${_formatarData(contrato.dataCriacao!)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
