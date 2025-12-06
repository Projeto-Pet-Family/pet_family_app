// pages/booking/template/booking_template.dart
import 'package:flutter/material.dart';
import 'package:pet_family_app/models/avaliacao_model.dart';
import 'package:pet_family_app/models/contrato_model.dart';
import 'package:pet_family_app/models/denuncia_model.dart';
import 'package:pet_family_app/models/pet/pet_model.dart';
import 'package:pet_family_app/pages/booking/modal/remover_pet_modal.dart';
import 'package:pet_family_app/pages/booking/modal/show_more/show_more_modal.dart';
import 'package:pet_family_app/pages/edit_booking/edit_booking.dart';
import 'package:pet_family_app/pages/message/message.dart';
import './pet_icon_bookin_template.dart';
import '../modal/avaliacao_modal.dart';
import '../modal/denuncia_modal.dart';
import '../modal/remover_servico_modal.dart';

class BookingTemplate extends StatefulWidget {
  final ContratoModel contrato;
  final VoidCallback onTap;
  final VoidCallback onEditar;
  final VoidCallback onCancelar;
  final VoidCallback onExcluir;
  final Function(ContratoModel)? onContratoEditado;
  final Future<void> Function(int idServico)? onRemoverServico;
  final Future<void> Function(int idPet)? onRemoverPet;
  final AvaliacaoModel? avaliacaoExistente;
  final DenunciaModel? denunciaExistente;

  const BookingTemplate({
    super.key,
    required this.contrato,
    required this.onTap,
    required this.onEditar,
    required this.onCancelar,
    required this.onExcluir,
    this.onContratoEditado,
    this.onRemoverServico,
    this.onRemoverPet,
    this.avaliacaoExistente,
    this.denunciaExistente,
  });

  @override
  State<BookingTemplate> createState() => _BookingTemplateState();
}

class _BookingTemplateState extends State<BookingTemplate> {
  bool _loading = false;
  bool _removingService = false;
  bool _removingPet = false;

  void _abrirTelaMensagem() {
    if (widget.contrato.idUsuario == null ||
        widget.contrato.idHospedagem == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dados do contrato incompletos')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Message(
          idusuario: widget.contrato.idUsuario!,
          idhospedagem: widget.contrato.idHospedagem!,
          nomeHospedagem: widget.contrato.hospedagemNome ?? 'Hospedagem',
        ),
      ),
    );
  }

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
    if (widget.contrato.pets == null || widget.contrato.pets!.isEmpty) {
      return [
        const PetIconBookingTemplate(
          petName: 'Nenhum pet',
        ),
      ];
    }

    return widget.contrato.pets!.map((pet) {
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

  void _abrirModalDetalhes() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ShowMoreModalTemplate(contrato: widget.contrato),
    );
  }

  void _abrirTelaEdicao() {
    EditBooking.show(
      context: context,
      contrato: widget.contrato,
      onContratoEditado: (contratoAtualizado) {
        print('🔄 Contrato editado no BookingTemplate');

        // Atualizar o widget pai se houver callback
        if (widget.onContratoEditado != null) {
          widget.onContratoEditado!(contratoAtualizado);
        }

        // FORÇAR REBUILD DO BookingTemplate
        setState(() {
          // Se o contrato for mutável, você pode atualizar seus pets aqui
          // Mas geralmente o callback externo já atualiza
          print(
              '🔄 Pets incluídos atualizados: ${contratoAtualizado.pets?.length ?? 0}');
        });

        // Mostrar mensagem de sucesso
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Contrato atualizado com sucesso!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      },
    );
  }

  void _abrirModalAvaliacao() {
    if (!widget.contrato.podeAvaliar) {
      _mostrarMensagemAvaliacaoNaoDisponivel();
      return;
    }

    AvaliacaoModal.show(
      context: context,
      contrato: widget.contrato,
      onAvaliacaoCriada: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Avaliação enviada com sucesso!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      },
      avaliacaoExistente: widget.avaliacaoExistente,
    );
  }

  void _abrirModalDenuncia() {
    if (!widget.contrato.podeDenunciar) {
      _mostrarMensagemDenunciaNaoDisponivel();
      return;
    }

    DenunciaModal.show(
      context: context,
      contrato: widget.contrato,
      onDenunciaCriada: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Denúncia enviada com sucesso!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      },
      denunciaExistente: widget.denunciaExistente,
    );
  }

  // NOVO: Abrir modal para remover serviços
  Future<void> _abrirModalRemoverServico() async {
    if (widget.contrato.servicos == null || widget.contrato.servicos!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não há serviços para remover')),
      );
      return;
    }

    if (widget.onRemoverServico == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Funcionalidade de remover serviços não está disponível')),
      );
      return;
    }

    final servicoRemovido = await showModalBottomSheet<int?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RemoverServicoModal(
        servicos: widget.contrato.servicos!,
      ),
    );

    if (servicoRemovido != null) {
      await _removerServico(servicoRemovido);
    }
  }

  // NOVO: Abrir modal para remover pets
  Future<void> _abrirModalRemoverPet() async {
    if (widget.contrato.pets == null || widget.contrato.pets!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não há pets para remover'),
        ),
      );
      return;
    }

    if (widget.onRemoverPet == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Funcionalidade de remover pets não está disponível'),
        ),
      );
      return;
    }

    final petRemovido = await showModalBottomSheet<int?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RemoverPetModal(
        pets: widget.contrato.pets!,
      ),
    );

    if (petRemovido != null) {
      await _removerPet(petRemovido);
    }
  }

  // NOVO: Remover serviço
  Future<void> _removerServico(int idServico) async {
    if (widget.onRemoverServico == null) return;

    setState(() {
      _removingService = true;
    });

    try {
      print(
          '🔄 Removendo serviço ID: $idServico do contrato ${widget.contrato.idContrato}');

      await widget.onRemoverServico!(idServico);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Serviço removido com sucesso!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );

      // Atualiza a lista de serviços localmente
      if (widget.contrato.servicos != null) {
        widget.contrato.servicos!.removeWhere((servico) {
          if (servico is Map<String, dynamic>) {
            return servico['id'] == idServico;
          }
          return false;
        });

        // Atualiza o contrato se houver callback
        if (widget.onContratoEditado != null) {
          widget.onContratoEditado!(widget.contrato);
        }

        // Força rebuild do widget
        setState(() {});
      }
    } catch (e) {
      print('❌ Erro ao remover serviço: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Erro ao remover serviço'),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'Tentar novamente',
            onPressed: () => _removerServico(idServico),
          ),
        ),
      );
    } finally {
      setState(() {
        _removingService = false;
      });
    }
  }

  // NOVO: Remover pet
  Future<void> _removerPet(int idPet) async {
    if (widget.onRemoverPet == null) return;

    setState(() {
      _removingPet = true;
    });

    try {
      print(
          '🔄 Removendo pet ID: $idPet do contrato ${widget.contrato.idContrato}');

      await widget.onRemoverPet!(idPet);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pet removido com sucesso!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );

      // Atualiza a lista de pets localmente
      if (widget.contrato.pets != null) {
        widget.contrato.pets!.removeWhere((pet) {
          if (pet is Map<String, dynamic>) {
            return pet['id'] == idPet;
          } else if (pet is PetModel) {
            return pet.idPet == idPet;
          }
          return false;
        });

        // Atualiza o contrato se houver callback
        if (widget.onContratoEditado != null) {
          widget.onContratoEditado!(widget.contrato);
        }

        // Força rebuild do widget
        setState(() {});
      }
    } catch (e) {
      print('❌ Erro ao remover pet: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Erro ao remover pet'),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'Tentar novamente',
            onPressed: () => _removerPet(idPet),
          ),
        ),
      );
    } finally {
      setState(() {
        _removingPet = false;
      });
    }
  }

  void _mostrarMensagemAvaliacaoNaoDisponivel() {
    String mensagem = '';

    switch (widget.contrato.status) {
      case 'em_aprovacao':
        mensagem = 'Avaliação disponível apenas para hospedagens concluídas.';
        break;
      case 'aprovado':
        mensagem = 'Aguarde a conclusão da hospedagem para avaliar.';
        break;
      case 'em_execucao':
        mensagem = 'Avaliação disponível após a conclusão da hospedagem.';
        break;
      case 'negado':
        mensagem = 'Esta hospedagem foi negada e não pode ser avaliada.';
        break;
      case 'cancelado':
        mensagem = 'Esta hospedagem foi cancelada e não pode ser avaliada.';
        break;
      default:
        mensagem = 'Avaliação não disponível no momento.';
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Avaliação Indisponível",
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

  void _mostrarMensagemDenunciaNaoDisponivel() {
    String mensagem = '';

    switch (widget.contrato.status) {
      case 'em_aprovacao':
        mensagem = 'Denúncia disponível apenas para hospedagens concluídas.';
        break;
      case 'aprovado':
        mensagem = 'Aguarde a conclusão da hospedagem para fazer denúncia.';
        break;
      case 'em_execucao':
        mensagem = 'Denúncia disponível após a conclusão da hospedagem.';
        break;
      case 'negado':
        mensagem = 'Esta hospedagem foi negada e não permite denúncia.';
        break;
      case 'cancelado':
        mensagem = 'Esta hospedagem foi cancelada e não permite denúncia.';
        break;
      default:
        mensagem = 'Denúncia não disponível no momento.';
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Denúncia Indisponível",
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

  void _abrirModalConfirmacaoCancelamento() {
    if (!widget.contrato.podeCancelar) {
      _mostrarMensagemNaoCancelavel();
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
                _cancelarHospedagem();
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

  void _mostrarMensagemNaoCancelavel() {
    String mensagem = '';

    switch (widget.contrato.status) {
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

  void _cancelarHospedagem() {
    try {
      print(
          '🚀 Iniciando cancelamento do contrato: ${widget.contrato.idContrato}');
      print('📊 Status atual: ${widget.contrato.status}');

      final contratoCancelado = widget.contrato.copyWith(
        status: 'cancelado',
        dataAtualizacao: DateTime.now(),
      );

      print('📝 Novo status: ${contratoCancelado.status}');

      if (widget.onContratoEditado != null) {
        print('🔄 Chamando onContratoEditado com contrato atualizado');
        widget.onContratoEditado!(contratoCancelado);
      } else {
        print('⚠️ onContratoEditado não está definido');
      }

      print('🔄 Executando onCancelar para chamar a API');
      widget.onCancelar();

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
              _abrirModalConfirmacaoCancelamento();
            },
          ),
        ),
      );
    }
  }

  Widget _buildStatusAvaliacao() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.amber[50],
        border: Border.all(color: Colors.amber[300]!),
        borderRadius: BorderRadius.zero,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.star,
            color: Colors.amber[700],
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            'Já Avaliado',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.amber[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusDenuncia() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.red[50],
        border: Border.all(color: Colors.red[300]!),
        borderRadius: BorderRadius.zero,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.warning,
            color: Colors.red[700],
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            'Já Denunciado',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.red[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBotaoAvaliacao() {
    // Se já existe avaliação, mostra o status em vez do botão
    if (widget.avaliacaoExistente != null) {
      return _buildStatusAvaliacao();
    }

    return _buildBotaoPadrao(
      label: 'Avaliar Hospedagem',
      onPressed: () => _abrirModalAvaliacao(),
      icon: const Icon(Icons.star_outline, size: 20),
    );
  }

  Widget _buildBotaoDenuncia() {
    // Se já existe denúncia, mostra o status em vez do botão
    if (widget.denunciaExistente != null) {
      return _buildStatusDenuncia();
    }

    return _buildBotaoPadrao(
      label: 'Fazer Denúncia',
      onPressed: () => _abrirModalDenuncia(),
      icon: const Icon(Icons.warning_outlined, size: 20),
    );
  }

  Widget _buildBotaoRemoverServico() {
    return _buildBotaoPadrao(
      label: _removingService ? 'Removendo...' : 'Remover Serviço',
      onPressed: _removingService ? null : () => _abrirModalRemoverServico(),
      icon: _removingService
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.remove_circle_outline, size: 20),
    );
  }

  Widget _buildBotaoRemoverPet() {
    return _buildBotaoPadrao(
      label: _removingPet ? 'Removendo...' : 'Remover Pet',
      onPressed: _removingPet ? null : () => _abrirModalRemoverPet(),
      icon: _removingPet
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.pets, size: 20),
    );
  }

  Widget _buildBotaoPadrao({
    required String label,
    required VoidCallback? onPressed,
    Widget? icon,
    Color? backgroundColor,
    BorderRadius? borderRadius,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? const Color(0xffEDEDED),
          foregroundColor: const Color(0xff000000),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius ?? BorderRadius.zero,
            side: const BorderSide(color: Color(0xffCFCCCC)),
          ),
          elevation: 0,
          alignment: Alignment.center,
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (icon != null) icon,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final petIcons = _buildPetIcons();
    final podeAvaliar = widget.contrato.podeAvaliar;
    final podeDenunciar = widget.contrato.podeDenunciar;

    // Verificar condições para mostrar botões de remoção
    final podeRemoverServico = widget.onRemoverServico != null &&
        widget.contrato.servicos != null &&
        widget.contrato.servicos!.isNotEmpty &&
        widget.contrato.podeEditar;

    final podeRemoverPet = widget.onRemoverPet != null &&
        widget.contrato.pets != null &&
        widget.contrato.pets!.isNotEmpty &&
        widget.contrato.podeEditar &&
        widget.contrato.pets!.length >
            1; // Não permite remover se só tiver um pet

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Cabeçalho do contrato
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
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Status
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _obterCorStatus(widget.contrato.status)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _obterCorStatus(widget.contrato.status),
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    _obterNomeStatus(widget.contrato.status).toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _obterCorStatus(widget.contrato.status),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Ícone da hospedagem
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

                // Nome da hospedagem
                Text(
                  widget.contrato.hospedagemNome ?? 'Hospedagem',
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

                // Datas
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
                      '${_formatarData(widget.contrato.dataInicio)} - ${_formatarData(widget.contrato.dataFim ?? widget.contrato.dataInicio)}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xffD9D9D9),
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ),

                // Duração
                if (widget.contrato.duracaoDias != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    '${widget.contrato.duracaoDias} ${widget.contrato.duracaoDias == 1 ? 'dia' : 'dias'}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xffD9D9D9),
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
                const SizedBox(height: 20),

                // Pets
                if (petIcons.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
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

          // Botão Ver Mais
          _buildBotaoPadrao(
            label: 'Ver Mais',
            onPressed: () => _abrirModalDetalhes(),
            icon: const Icon(Icons.arrow_forward, size: 20),
          ),

          // Botão Editar (se aplicável)
          if (widget.contrato.podeEditar)
            _buildBotaoPadrao(
              label: 'Editar',
              onPressed: () => _abrirTelaEdicao(),
              icon: const Icon(Icons.edit, size: 20),
            ),

          // Botão Remover Serviço (NOVO - se aplicável)
          if (podeRemoverServico) _buildBotaoRemoverServico(),

          // Botão Remover Pet (NOVO - se aplicável)
          if (podeRemoverPet) _buildBotaoRemoverPet(),

          // Botão Enviar Mensagem (se aplicável)
          if (widget.contrato.estaAtivo)
            _buildBotaoPadrao(
              label: 'Enviar mensagem',
              onPressed: () => _abrirTelaMensagem(),
              icon: const Icon(Icons.message, size: 20),
            ),

          // Botão Avaliação (APENAS quando status for 'concluido')
          if (podeAvaliar) _buildBotaoAvaliacao(),

          // Botão Denúncia (APENAS quando status for 'concluido')
          if (podeDenunciar) _buildBotaoDenuncia(),

          // Botão Cancelar
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.contrato.status == 'cancelado'
                    ? Colors.grey[300]!
                    : const Color(0xffEDEDED),
                foregroundColor: widget.contrato.status == 'cancelado'
                    ? Colors.grey[600]!
                    : const Color(0xff000000),
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
                  side: BorderSide(
                    color: widget.contrato.status == 'cancelado'
                        ? Colors.grey[400]!
                        : const Color(0xffCFCCCC),
                  ),
                ),
                elevation: 0,
                alignment: Alignment.center,
              ),
              onPressed: widget.contrato.podeCancelar
                  ? () => _abrirModalConfirmacaoCancelamento()
                  : () => _mostrarMensagemNaoCancelavel(),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.contrato.status == 'cancelado'
                        ? 'Cancelado'
                        : 'Cancelar',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Icon(
                    widget.contrato.status == 'cancelado'
                        ? Icons.block
                        : Icons.close,
                    size: 20,
                    color: widget.contrato.status == 'cancelado'
                        ? Colors.grey[600]!
                        : null,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
