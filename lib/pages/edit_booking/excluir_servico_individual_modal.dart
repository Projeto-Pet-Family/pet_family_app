// pages/edit_booking/modal/excluir_servico_individual_modal.dart
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:pet_family_app/models/contrato_model.dart';
import 'package:pet_family_app/services/contrato_service.dart';
import 'package:pet_family_app/widgets/app_button.dart';

class ExcluirServicoIndividualModal extends StatefulWidget {
  final int idContrato;
  final ContratoModel contrato;
  final int idServico;
  final String servicoDescricao;
  final double servicoPreco;
  final int? idPet; // null para serviço geral, int para serviço de pet
  final String? petNome;
  final Function(ContratoModel) onServicoExcluido;

  const ExcluirServicoIndividualModal({
    super.key,
    required this.idContrato,
    required this.contrato,
    required this.idServico,
    required this.servicoDescricao,
    required this.servicoPreco,
    this.idPet,
    this.petNome,
    required this.onServicoExcluido,
  });

  @override
  State<ExcluirServicoIndividualModal> createState() => _ExcluirServicoIndividualModalState();
}

class _ExcluirServicoIndividualModalState extends State<ExcluirServicoIndividualModal> {
  late ContratoService _contratoService;
  bool _excluindo = false;

  @override
  void initState() {
    super.initState();
    final dio = Dio();
    _contratoService = ContratoService(dio);
  }

  Future<void> _excluirServico() async {
    setState(() => _excluindo = true);

    try {
      print('🗑️ Excluindo serviço individual:');
      print('   - Contrato: ${widget.idContrato}');
      print('   - Serviço: ${widget.idServico}');
      print('   - Pet: ${widget.idPet ?? "Geral"}');
      print('   - Descrição: ${widget.servicoDescricao}');

      // Formatar payload para a API
      final payload = {
        "servicosPorPet": [
          {
            "idPet": widget.idPet, // Pode ser null para serviços gerais
            "servicos": [widget.idServico],
          }
        ]
      };

      print('📦 Payload: $payload');

      // Chamar a API para excluir o serviço
      final response = await _contratoService.excluirServicosContrato(
        idContrato: widget.idContrato,
        servicosPorPet: [
          {
            'idPet': widget.idPet,
            'servicos': [widget.idServico],
          }
        ],
      );

      print('✅ Serviço excluído com sucesso!');

      // Fechar modal e notificar
      if (mounted) {
        Navigator.of(context).pop();
        widget.onServicoExcluido(response);
        
        _mostrarMensagemSucesso(
          widget.idPet != null
            ? 'Serviço removido de ${widget.petNome}!'
            : 'Serviço geral removido!'
        );
      }
    } catch (e, stackTrace) {
      print('❌ Erro ao excluir serviço: $e');
      print('📝 Stack trace: $stackTrace');
      
      if (mounted) {
        _mostrarErro('Erro ao excluir serviço: ${e.toString()}');
        setState(() => _excluindo = false);
      }
    }
  }

  void _mostrarMensagemSucesso(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _mostrarErro(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Container(
          color: Colors.black.withOpacity(0.5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Modal content
              GestureDetector(
                onTap: () {}, // Prevenir fechamento
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Ícone de alerta
                      Icon(
                        Icons.warning_rounded,
                        size: 60,
                        color: Colors.orange[700],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Título
                      Text(
                        'Remover Serviço',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[700],
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Descrição do serviço
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.servicoDescricao,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            
                            const SizedBox(height: 8),
                            
                            Text(
                              'Valor: R\$${widget.servicoPreco.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.green,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            
                            if (widget.idPet != null && widget.petNome != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.pets,
                                      size: 16,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      widget.petNome!,
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
                      
                      const SizedBox(height: 20),
                      
                      // Aviso
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.red[200]!),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.red[700],
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Esta ação é irreversível. O serviço será removido do contrato.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.red[800],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Botões
                      Column(
                        children: [
                          AppButton(
                            onPressed: _excluindo ? null : _excluirServico,
                            label: _excluindo ? 'Removendo...' : 'Sim, Remover',
                            fontSize: 16,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            buttonColor: Colors.red,
                            textButtonColor: Colors.white,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          const SizedBox(height: 12),
                          AppButton(
                            onPressed: _excluindo ? null : () => Navigator.of(context).pop(),
                            label: 'Cancelar',
                            fontSize: 16,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            buttonColor: Colors.white,
                            textButtonColor: Colors.black,
                            borderSide: const BorderSide(color: Colors.grey),
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}