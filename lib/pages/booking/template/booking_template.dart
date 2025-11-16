// pages/booking/template/booking_template.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_family_app/models/contrato_model.dart';
import 'package:pet_family_app/models/pet/pet_model.dart';
import 'package:pet_family_app/pages/booking/modal/show_more/show_more_modal.dart';
import 'package:pet_family_app/pages/edit_booking/edit_booking.dart';
import 'package:pet_family_app/widgets/app_button.dart';
import './pet_icon_bookin_template.dart';

class BookingTemplate extends StatelessWidget {
  final ContratoModel contrato;
  final VoidCallback onTap;
  final VoidCallback onEditar;
  final VoidCallback onCancelar;
  final Function(ContratoModel)? onContratoEditado;

  const BookingTemplate({
    super.key,
    required this.contrato,
    required this.onTap,
    required this.onEditar,
    required this.onCancelar,
    this.onContratoEditado,
  });

  String _formatarData(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _obterNomeStatus(String status) {
    final statusMap = {
      'em_aprovacao': 'Em Aprovação',
      'aprovado': 'Aprovado',
      'em_execucao': 'Em Execução',
      'concluido': 'Concluído',
      'negado': 'Negado',
      'cancelado': 'Cancelado',
    };
    return statusMap[status] ?? 'Desconhecido';
  }

  Color _obterCorStatus(String status) {
    switch (status) {
      case 'em_aprovacao':
        return const Color.fromARGB(255, 250, 155, 12);
      case 'aprovado':
        return const Color.fromARGB(255, 81, 189, 84);
      case 'em_execucao':
        return const Color.fromARGB(255, 85, 197, 201);
      case 'concluido':
        return const Color.fromARGB(255, 172, 172, 172);
      case 'negado':
        return const Color.fromARGB(255, 236, 61, 48);
      case 'cancelado':
        return const Color.fromARGB(255, 133, 12, 4);
      default:
        return const Color.fromARGB(255, 163, 163, 163);
    }
  }

  List<Widget> _buildPetIcons() {
    if (contrato.pets == null || contrato.pets!.isEmpty) {
      return [
        const PetIconBookingTemplate(
          petName: 'Nenhum pet',
        ),
      ];
    }

    return contrato.pets!.map((pet) {
      String petName = 'Pet';

      if (pet is Map<String, dynamic>) {
        petName = pet['nome'] as String? ?? 'Pet';
      } else if (pet is PetModel) {
        petName = pet.nome ?? 'Pet';
      } else if (pet is String) {
        petName = pet;
      }

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: PetIconBookingTemplate(
          petName: petName,
        ),
      );
    }).toList();
  }

  void _abrirModalDetalhes(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ShowMoreModalTemplate(contrato: contrato),
    );
  }

  void _abrirTelaEdicao(BuildContext context) {
    EditBooking.show(
      context: context,
      contrato: contrato,
      onContratoEditado: onContratoEditado,
    );
  }

  void _abrirTelaMensagem(BuildContext context) {
    context.push(
      '/messages',
      extra: {
        'contratoId': contrato.idContrato,
        'hospedagemNome': contrato.hospedagemNome,
      },
    );
  }

  void _abrirModalConfirmacaoCancelamento(BuildContext context) {
    if (!contrato.podeCancelar) {
      _mostrarMensagemNaoCancelavel(context);
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Confirmar Cancelamento",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text(
            "Tem certeza que deseja cancelar esta hospedagem? Esta ação não pode ser desfeita.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                "Não",
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _cancelarHospedagem(context);
              },
              child: const Text(
                "Sim, Cancelar",
                style: TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  void _mostrarMensagemNaoCancelavel(BuildContext context) {
    String mensagem = '';

    switch (contrato.status) {
      case 'em_execucao':
        mensagem =
            'Não é possível cancelar uma hospedagem em execução. Entre em contato com o anfitrião para mais informações.';
        break;
      case 'concluido':
        mensagem = 'Esta hospedagem já foi concluída e não pode ser cancelada.';
        break;
      case 'negado':
        mensagem = 'Esta hospedagem já foi negada pelo anfitrião.';
        break;
      case 'cancelado':
        mensagem = 'Esta hospedagem já está cancelada.';
        break;
      default:
        mensagem = 'Esta hospedagem não pode ser cancelada no momento.';
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Não é possível cancelar",
            style: TextStyle(color: Colors.orange),
          ),
          content: Text(mensagem),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                "Entendi",
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        );
      },
    );
  }

  // ✅ FUNÇÃO DE CANCELAMENTO CORRIGIDA
  void _cancelarHospedagem(BuildContext context) {
    try {
      print('🚀 Iniciando cancelamento do contrato: ${contrato.idContrato}');
      print('📊 Status atual: ${contrato.status}');

      // Cria uma cópia do contrato com status atualizado para 'cancelado'
      final contratoCancelado = contrato.copyWith(
        status: 'cancelado',
        dataAtualizacao: DateTime.now(),
      );

      print('📝 Novo status: ${contratoCancelado.status}');

      // PRIMEIRO: Atualiza o contrato via callback para atualizar a UI
      if (onContratoEditado != null) {
        print('🔄 Chamando onContratoEditado com contrato atualizado');
        onContratoEditado!(contratoCancelado);
      } else {
        print('⚠️ onContratoEditado não está definido');
      }

      // DEPOIS: Executa a ação de cancelamento (chamada à API)
      print('🔄 Executando onCancelar para chamar a API');
      onCancelar();

      // Feedback visual de sucesso
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Hospedagem cancelada com sucesso!",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );

      print('✅ Cancelamento concluído com sucesso');
    } catch (e) {
      print('❌ Erro durante o cancelamento: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            "Erro ao cancelar hospedagem",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: "Tentar Novamente",
            textColor: Colors.white,
            onPressed: () {
              _abrirModalConfirmacaoCancelamento(context);
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final petIcons = _buildPetIcons();

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ),
            color: const Color(0xff8692DE),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _obterCorStatus(contrato.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _obterCorStatus(contrato.status),
                    width: 1.5,
                  ),
                ),
                child: Text(
                  _obterNomeStatus(contrato.status).toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _obterCorStatus(contrato.status),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.house,
                  size: 60,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                contrato.hospedagemNome ?? 'Hospedagem',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Color(0xffD9D9D9),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${_formatarData(contrato.dataInicio)} - ${_formatarData(contrato.dataFim ?? contrato.dataInicio)}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xffD9D9D9),
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
              if (contrato.duracaoDias != null) ...[
                const SizedBox(height: 8),
                Text(
                  '${contrato.duracaoDias} ${contrato.duracaoDias == 1 ? 'dia' : 'dias'}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xffD9D9D9),
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
              const SizedBox(height: 20),
              if (petIcons.isNotEmpty) ...[
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Pets incluídos:',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        alignment: WrapAlignment.center,
                        children: petIcons,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        AppButton(
          label: 'Ver Mais',
          onPressed: () => _abrirModalDetalhes(context),
          buttonColor: const Color(0xffEDEDED),
          textButtonColor: const Color(0xff000000),
          borderRadiusValue: 0,
          icon: const Icon(Icons.arrow_forward, size: 20),
          borderSide: const BorderSide(color: Color(0xffCFCCCC)),
        ),
        if (contrato.podeEditar)
          AppButton(
            label: 'Editar',
            onPressed: () => _abrirTelaEdicao(context),
            buttonColor: const Color(0xffEDEDED),
            textButtonColor: const Color(0xff000000),
            borderRadiusValue: 0,
            icon: const Icon(Icons.edit, size: 20),
            borderSide: const BorderSide(color: Color(0xffCFCCCC)),
          ),
        if (contrato.estaAtivo)
          AppButton(
            label: 'Enviar mensagem',
            onPressed: () => _abrirTelaMensagem(context),
            buttonColor: const Color(0xffEDEDED),
            textButtonColor: const Color(0xff000000),
            borderRadiusValue: 0,
            icon: const Icon(Icons.message, size: 20),
            borderSide: const BorderSide(color: Color(0xffCFCCCC)),
          ),
        AppButton(
          label: contrato.status == 'cancelado' ? 'Cancelado' : 'Cancelar',
          onPressed: contrato.podeCancelar
              ? () => _abrirModalConfirmacaoCancelamento(context)
              : () => _mostrarMensagemNaoCancelavel(context),
          buttonColor: contrato.status == 'cancelado'
              ? Colors.grey[300]!
              : const Color(0xffEDEDED),
          textButtonColor: contrato.status == 'cancelado'
              ? Colors.grey[600]!
              : const Color(0xff000000),
          icon: Icon(
            contrato.status == 'cancelado' ? Icons.block : Icons.close,
            size: 20,
            color: contrato.status == 'cancelado' ? Colors.grey[600]! : null,
          ),
          borderSide: BorderSide(
            color: contrato.status == 'cancelado'
                ? Colors.grey[400]!
                : const Color(0xffCFCCCC),
          ),
          borderRadius: BorderRadius.only(
            bottomLeft: const Radius.circular(10),
            bottomRight: const Radius.circular(10),
            topLeft:
                contrato.podeEditar ? Radius.zero : const Radius.circular(0),
            topRight:
                contrato.podeEditar ? Radius.zero : const Radius.circular(0),
          ),
        ),
      ],
    );
  }
}
