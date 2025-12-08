import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:pet_family_app/models/contrato_model.dart';
import 'package:pet_family_app/models/pet/pet_model.dart';
import 'package:pet_family_app/models/service_model.dart';
import 'package:pet_family_app/pages/booking/template/add/add_pet_modal.dart';
import 'package:pet_family_app/pages/booking/template/add/add_service_modal.dart';
import 'package:pet_family_app/pages/edit_booking/informations/data/data_information.dart';
import 'package:pet_family_app/pages/edit_booking/informations/services/services_information.dart';
import 'package:pet_family_app/pages/edit_booking/informations/your_pets/your_pets_informations.dart';
import 'package:pet_family_app/widgets/app_button.dart';

class EditBooking extends StatefulWidget {
  final ContratoModel contrato;
  final Function(ContratoModel)? onContratoEditado;

  const EditBooking({
    super.key,
    required this.contrato,
    this.onContratoEditado,
  });

  static Future<void> show({
    required BuildContext context,
    required ContratoModel contrato,
    Function(ContratoModel)? onContratoEditado,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditBooking(
        contrato: contrato,
        onContratoEditado: onContratoEditado,
      ),
    );
  }

  @override
  State<EditBooking> createState() => _EditBookingState();
}

class _EditBookingState extends State<EditBooking> {
  late ContratoModel _contratoEditado;
  final Map<String, dynamic> _cacheAlteracoes = {};
  late Dio _dio;

  // Estados para controle de exclusão de serviços
  bool _modoExclusaoServicos = false;
  final List<int> _servicosSelecionadosParaExclusao = [];

  @override
  void initState() {
    super.initState();
    _contratoEditado = widget.contrato.copyWith();
    _dio = Dio();
  }

  // Método para alternar modo de exclusão
  void _alternarModoExclusaoServicos() {
    final temServicos = _contratoEditado.servicosGerais?.isNotEmpty ?? false;

    if (!temServicos && !_modoExclusaoServicos) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não há serviços para excluir'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _modoExclusaoServicos = !_modoExclusaoServicos;
      if (!_modoExclusaoServicos) {
        _servicosSelecionadosParaExclusao.clear();
      }
    });
  }

  // Toggle seleção de serviço
  void _toggleSelecaoServico(int idServico) {
    setState(() {
      if (_servicosSelecionadosParaExclusao.contains(idServico)) {
        _servicosSelecionadosParaExclusao.remove(idServico);
      } else {
        _servicosSelecionadosParaExclusao.add(idServico);
      }
    });
  }

  // Excluir serviços selecionados
  Future<void> _excluirServicosSelecionados() async {
    if (_servicosSelecionadosParaExclusao.isEmpty) return;

    try {
      print(
          '🗑️ Excluindo serviços selecionados: $_servicosSelecionadosParaExclusao');

      // Função auxiliar para extrair ID do serviço
      int? _extrairIdServico(dynamic servico) {
        if (servico == null) return null;

        if (servico is ServiceModel) {
          return servico.idservico;
        } else if (servico is Map<String, dynamic>) {
          final dynamic id = servico['idservico'];
          if (id is int) return id;
          if (id is String) return int.tryParse(id);
          return null;
        }
        return null;
      }

      // Filtrar serviços, removendo os selecionados
      final servicosAtuais = _contratoEditado.servicosGerais ?? [];
      final servicosFiltrados = servicosAtuais.where((servico) {
        final id = _extrairIdServico(servico);
        if (id == null) return true; // Mantém se não conseguir extrair ID
        return !_servicosSelecionadosParaExclusao.contains(id);
      }).toList();

      print('📊 Total de serviços antes: ${servicosAtuais.length}');
      print('📊 Total de serviços depois: ${servicosFiltrados.length}');

      // Atualizar o contrato
      final contratoAtualizado = _contratoEditado.copyWith(
        servicosGerais: servicosFiltrados,
      );

      // Atualizar cache
      _cacheAlteracoes['servicos'] = servicosFiltrados;

      final quantidadeExcluida = _servicosSelecionadosParaExclusao.length;

      setState(() {
        _contratoEditado = contratoAtualizado;
        _servicosSelecionadosParaExclusao.clear();
        _modoExclusaoServicos = false;
      });

      // Notificar callback
      if (widget.onContratoEditado != null) {
        widget.onContratoEditado!(contratoAtualizado);
      }

      // Mostrar mensagem de sucesso
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('$quantidadeExcluida serviço(s) excluído(s) com sucesso!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e, stackTrace) {
      print('❌ Erro ao excluir serviços: $e');
      print('📝 Stack trace: $stackTrace');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao excluir serviços: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  // Método para adicionar serviços
  void _adicionarServico() {
    final servicosNoContrato = _contratoEditado.servicosGerais ?? [];
    final petsNoContrato = _contratoEditado.pets ?? [];

    // Converter serviços para ServiceModel
    final List<ServiceModel> servicosConvertidos =
        servicosNoContrato.map((item) {
      if (item is ServiceModel) {
        return item;
      } else if (item is Map<String, dynamic>) {
        try {
          return ServiceModel.fromJson(item);
        } catch (e) {
          return ServiceModel(
            idservico: item['idservico'] ?? 0,
            idhospedagem: item['idhospedagem'] ?? 0,
            descricao: item['descricao']?.toString() ?? 'Serviço desconhecido',
            preco: (item['preco'] is String)
                ? double.tryParse(item['preco']) ?? 0.0
                : (item['preco'] as num?)?.toDouble() ?? 0.0,
          );
        }
      } else {
        return ServiceModel(
          idservico: 0,
          idhospedagem: 0,
          descricao: 'Serviço inválido',
          preco: 0.0,
        );
      }
    }).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddServiceModal(
        idContrato: _contratoEditado.idContrato!,
        idHospedagem: _contratoEditado.idHospedagem!,
        servicosNoContrato: servicosConvertidos,
        petsNoContrato: petsNoContrato,
        onServicoAdicionado: _processarServicoAdicionado,
      ),
    );
  }

  void _processarServicoAdicionado(ContratoModel contratoAtualizado) {
    print('🔄 Serviço adicionado, atualizando estado...');

    // Limpar o cache de serviços
    if (_cacheAlteracoes.containsKey('servicos')) {
      _cacheAlteracoes.remove('servicos');
    }

    // Adicionar os novos serviços ao cache
    _cacheAlteracoes['servicos'] = contratoAtualizado.servicosGerais ?? [];

    // Atualizar o estado local
    setState(() {
      _contratoEditado = contratoAtualizado.copyWith();
    });

    // Notificar callback
    if (widget.onContratoEditado != null) {
      widget.onContratoEditado!(contratoAtualizado);
    }

    // Mostrar mensagem de sucesso
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Serviços adicionados com sucesso!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _adicionarPet() {
    final petsNoContrato = _contratoEditado.pets ?? [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return AddPetModal(
          idContrato: _contratoEditado.idContrato!,
          idUsuario: _contratoEditado.idUsuario,
          petsNoContrato: petsNoContrato,
          onPetAdicionado: _processarPetAdicionado,
        );
      },
    );
  }

  void _processarPetAdicionado(ContratoModel contratoAtualizado) {
    print('🔄 Processando pet adicionado - Contrato recebido:');
    print('📊 ID Contrato: ${contratoAtualizado.idContrato}');
    print('🐕 Total de pets: ${contratoAtualizado.pets?.length ?? 0}');

    // Forçar uma atualização completa do estado
    setState(() {
      // IMPORTANTE: Criar uma nova instância completamente nova
      _contratoEditado = ContratoModel.fromJson(contratoAtualizado.toJson());

      // Atualizar o cache
      _cacheAlteracoes['pets'] = _contratoEditado.pets ?? [];
    });

    // Mostrar mensagem de sucesso
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pets adicionados com sucesso!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );

    // Notificar o callback pai
    if (widget.onContratoEditado != null) {
      widget.onContratoEditado!(_contratoEditado);
    }

    // Forçar rebuild de widgets específicos
    _forcarAtualizacaoTela();
  }

// Adicione este método para forçar atualização da tela
  void _forcarAtualizacaoTela() {
    // Usar um Future para garantir que o estado seja atualizado
    Future.delayed(Duration.zero, () {
      if (mounted) {
        setState(() {
          // Marcar que precisa recarregar
          // Isso vai forçar o YourPetsInformations a recarregar
        });
      }
    });
  }

  void _onContratoAtualizado(ContratoModel contratoAtualizado,
      {String? tipoAlteracao}) {
    print('🔄 _onContratoAtualizado - Tipo: $tipoAlteracao');

    // Para serviços removidos
    if (tipoAlteracao == 'servico_removido') {
      _contratoEditado = contratoAtualizado.copyWith();
      _cacheAlteracoes['servicos'] = contratoAtualizado.servicosGerais ?? [];
      return;
    }

    // Para pets removidos
    if (tipoAlteracao == 'pet_removido') {
      _contratoEditado = contratoAtualizado.copyWith();
      _cacheAlteracoes['pets'] = contratoAtualizado.pets ?? [];
      return;
    }

    // Para alterações de datas
    if (tipoAlteracao == 'data_inicio' &&
        contratoAtualizado.dataInicio != widget.contrato.dataInicio) {
      _cacheAlteracoes['dataInicio'] = contratoAtualizado.dataInicio;
    }

    if (tipoAlteracao == 'data_fim' &&
        contratoAtualizado.dataFim != widget.contrato.dataFim) {
      _cacheAlteracoes['dataFim'] = contratoAtualizado.dataFim;
    }

    // Atualizar UI com cache
    _aplicarCacheAoContrato();
  }

  void _aplicarCacheAoContrato() {
    setState(() {
      if (_cacheAlteracoes.containsKey('dataInicio')) {
        _contratoEditado = _contratoEditado.copyWith(
          dataInicio: _cacheAlteracoes['dataInicio'],
        );
      }

      if (_cacheAlteracoes.containsKey('dataFim')) {
        _contratoEditado = _contratoEditado.copyWith(
          dataFim: _cacheAlteracoes['dataFim'],
        );
      }

      if (_cacheAlteracoes.containsKey('servicos')) {
        _contratoEditado = _contratoEditado.copyWith(
          servicosGerais: _cacheAlteracoes['servicos'],
        );
      }

      if (_cacheAlteracoes.containsKey('pets')) {
        _contratoEditado = _contratoEditado.copyWith(
          pets: _cacheAlteracoes['pets'],
        );
      }
    });
  }

  bool _existemAlteracoes() {
    return _cacheAlteracoes.isNotEmpty;
  }

  bool _podeAdicionar() {
    final statusEditaveis = ['em_aprovacao', 'pendente', 'confirmado'];
    return statusEditaveis.contains(_contratoEditado.status);
  }

  void _onSalvarAlteracoes() async {
    if (!_existemAlteracoes()) {
      print('ℹ️ Nenhuma alteração para salvar');
      _fecharModal();
      return;
    }

    print('💾 Salvando alterações na API...');

    try {
      // Simular salvamento na API
      await _salvarAlteracoesNaAPI();

      // Notificar callback
      if (widget.onContratoEditado != null) {
        widget.onContratoEditado!(_contratoEditado);
      }

      // Mostrar popup de sucesso
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle,
                size: 60,
                color: Colors.green[400],
              ),
              const SizedBox(height: 20),
              const Text(
                'Alterações Salvas!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Suas alterações foram salvas com sucesso.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff8692DE),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                ),
                child: const Text('OK'),
              ),
            ),
          ],
        ),
      );

      // Fechar modal
      _fecharModal();
    } catch (e) {
      print('❌ Erro ao salvar alterações: $e');
      _mostrarMensagemErro('Erro ao salvar alterações: $e');
    }
  }

  Future<void> _salvarAlteracoesNaAPI() async {
    await Future.delayed(Duration(milliseconds: 500));
    print('✅ Alterações salvas com sucesso na API');
    _cacheAlteracoes.clear();
  }

  void _mostrarMensagemErro(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _fecharModal() {
    if (_existemAlteracoes()) {
      _mostrarDialogoConfirmacaoSaida();
    } else {
      Navigator.of(context).pop();
    }
  }

  void _mostrarDialogoConfirmacaoSaida() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Descartar alterações?'),
        content: Text('Existem alterações não salvas. Deseja realmente sair?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: Text(
              'Sair',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  String _formatarData(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  // Widget para construir o cabeçalho da seção de serviços
  Widget _buildCabecalhoServicos(bool podeAdicionar) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título e botões
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Serviços Adicionais',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xff8692DE),
              ),
            ),

            // Botões de ação
            Row(
              children: [
                AppButton(
                  onPressed: podeAdicionar ? _adicionarServico : null,
                  label: 'Adicionar',
                  fontSize: 14,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  buttonColor: podeAdicionar
                      ? const Color(0xff8692DE)
                      : Colors.grey[300],
                  textButtonColor: podeAdicionar ? Colors.white : Colors.grey,
                  borderRadius: BorderRadius.circular(50),
                  widthFactor: null,
                  minWidth: null,
                ),
              ],
            ),
          ],
        ),

        // Banner do modo exclusão (aparece só quando ativado)
        if (_modoExclusaoServicos)
          Container(
            margin: const EdgeInsets.only(top: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red[100]!),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.delete_outline,
                      color: Colors.red[600],
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Modo Exclusão',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.red[600],
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Selecione os serviços que deseja excluir',
                            style: TextStyle(
                              color: Colors.red[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Botão Cancelar
                    TextButton(
                      onPressed: _alternarModoExclusaoServicos,
                      child: Text(
                        'Cancelar',
                        style: TextStyle(
                          color: Colors.red[600],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                // Contador e botão excluir (só aparece se houver selecionados)
                if (_servicosSelecionadosParaExclusao.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.red[200]!),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${_servicosSelecionadosParaExclusao.length} selecionado(s)',
                                style: TextStyle(
                                  color: Colors.red[800],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _servicosSelecionadosParaExclusao.clear();
                                });
                              },
                              child: Text(
                                'Limpar',
                                style: TextStyle(
                                  color: Colors.red[600],
                                  fontSize: 12,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                        ElevatedButton.icon(
                          onPressed: _excluirServicosSelecionados,
                          icon: const Icon(Icons.delete, size: 16),
                          label: const Text('Excluir'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final podeAdicionar = _podeAdicionar();

    return Container(
      height: MediaQuery.of(context).size.height * 0.95,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const Icon(
                    Icons.close,
                    size: 30,
                    color: Colors.black,
                  ),
                ),
                const Text(
                  'PetFamily',
                  style: TextStyle(
                    fontWeight: FontWeight.w100,
                    color: Color(0xFF8F8F8F),
                    fontSize: 18,
                  ),
                ),
                const SizedBox(width: 30),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Banner de informações do contrato
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xff8692DE),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.edit,
                              size: 40,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _contratoEditado.hospedagemNome ??
                                        'Agendamento',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      _contratoEditado.statusFormatado,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          height: 1,
                          color: Colors.white.withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              size: 20,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                '${_formatarData(_contratoEditado.dataInicio)} - ${_formatarData(_contratoEditado.dataFim ?? _contratoEditado.dataInicio)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (widget.contrato.hospedagemEndereco != null) ...[
                          const SizedBox(height: 12),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(top: 2),
                                child: Icon(
                                  Icons.location_on,
                                  size: 20,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  widget.contrato.hospedagemEndereco!,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                        if (_existemAlteracoes()) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.orange),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.warning_amber,
                                  size: 20,
                                  color: Colors.orange[800],
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Existem alterações não salvas',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.orange[800],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Data Information
                  const Text(
                    'Datas da Hospedagem',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff8692DE),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DataInformation(
                    contrato: _contratoEditado,
                    onContratoAtualizado: _onContratoAtualizado,
                    editavel: true,
                  ),

                  const SizedBox(height: 32),

                  // Services Information
                  _buildCabecalhoServicos(podeAdicionar),
                  const SizedBox(height: 12),

                  ServicesInformation(
                    contrato: _contratoEditado,
                    editavel: podeAdicionar,
                    modoExclusao: _modoExclusaoServicos,
                    servicosSelecionados: _servicosSelecionadosParaExclusao,
                    onServicoSelecionado: _toggleSelecaoServico,
                  ),

                  const SizedBox(height: 32),

                  // Pets incluídos
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Text(
                          'Pets incluídos',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff8692DE),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      AppButton(
                        onPressed: podeAdicionar ? _adicionarPet : null,
                        label: 'Adicionar',
                        fontSize: 14,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        buttonColor: podeAdicionar
                            ? const Color(0xff8692DE)
                            : Colors.grey[300],
                        textButtonColor:
                            podeAdicionar ? Colors.white : Colors.grey,
                        borderRadius: BorderRadius.circular(50),
                        widthFactor: null,
                        minWidth: null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  YourPetsInformations(
                    contrato: _contratoEditado,
                    onContratoAtualizado: _onContratoAtualizado,
                    editavel: podeAdicionar,
                    dio: Dio(),
                  ),

                  const SizedBox(height: 32),

                  // Botões de ação
                  AppButton(
                    onPressed: _onSalvarAlteracoes,
                    label: 'Salvar Alterações',
                    fontSize: 16,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    buttonColor: Color(0xff8692DE),
                    textButtonColor: Colors.white,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  const SizedBox(height: 12),
                  AppButton(
                    onPressed: _fecharModal,
                    label: 'Fechar',
                    fontSize: 16,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    buttonColor: Colors.white,
                    textButtonColor: Colors.black,
                    borderSide: BorderSide(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(50),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
