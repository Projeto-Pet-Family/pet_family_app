// pages/booking/modal/remover_servico_modal.dart
import 'package:flutter/material.dart';

class RemoverServicoModal extends StatefulWidget {
  final List<dynamic> servicos;

  const RemoverServicoModal({
    super.key,
    required this.servicos,
  });

  @override
  State<RemoverServicoModal> createState() => _RemoverServicoModalState();
}

class _RemoverServicoModalState extends State<RemoverServicoModal> {
  int? _servicoSelecionado;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Remover Serviço',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Selecione o serviço que deseja remover:',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 20),
          
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: widget.servicos.length,
              itemBuilder: (context, index) {
                final servico = widget.servicos[index];
                String servicoNome = 'Serviço';
                String servicoValor = '';
                int? servicoId;
                
                if (servico is Map<String, dynamic>) {
                  servicoNome = servico['nome'] ?? 'Serviço';
                  servicoId = servico['id'];
                  if (servico['valor'] != null) {
                    final valor = servico['valor'] is num ? servico['valor'] as num : 0.0;
                    servicoValor = 'R\$${valor.toStringAsFixed(2).replaceAll('.', ',')}';
                  }
                } else if (servico is String) {
                  servicoNome = servico;
                }
                
                final bool isSelected = _servicoSelecionado == servicoId;
                
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  color: isSelected ? Colors.blue[50] : null,
                  child: ListTile(
                    leading: const Icon(Icons.room_service, color: Colors.blue),
                    title: Text(servicoNome),
                    subtitle: servicoValor.isNotEmpty ? Text(servicoValor) : null,
                    trailing: isSelected 
                        ? const Icon(Icons.check_circle, color: Colors.blue)
                        : null,
                    onTap: servicoId != null ? () {
                      setState(() {
                        _servicoSelecionado = servicoId;
                      });
                    } : null,
                  ),
                );
              },
            ),
          ),
          
          const SizedBox(height: 20),
          
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () => Navigator.pop(context, null),
                  child: const Text('Cancelar'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _servicoSelecionado != null 
                        ? Colors.red 
                        : Colors.grey[300],
                    foregroundColor: _servicoSelecionado != null 
                        ? Colors.white 
                        : Colors.grey[600],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: _servicoSelecionado != null
                      ? () => Navigator.pop(context, _servicoSelecionado)
                      : null,
                  child: const Text('Remover'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}