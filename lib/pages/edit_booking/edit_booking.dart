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
import 'package:pet_family_app/pages/edit_booking/modal/booking_edited.dart';
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

  @override
  void initState() {
    super.initState();
    _contratoEditado = widget.contrato.copyWith();
    _dio = Dio();
  }

  // Método para adicionar serviços
  void _adicionarServico() {
    final servicosNoContrato = _contratoEditado.servicos ?? [];

    // CONVERSÃO EXPLÍCITA - Linha 68 corrigida
    final List<ServiceModel> servicosConvertidos =
        servicosNoContrato.map((item) {
      if (item is ServiceModel) {
        return item;
      } else if (item is Map<String, dynamic>) {
        // Tente converter para ServiceModel
        try {
          return ServiceModel.fromJson(item);
        } catch (e) {
          print('❌ Erro ao converter item para ServiceModel: $e');
          print('❌ Item: $item');
          // Retorna um ServiceModel vazio ou lança exceção
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
        print('❌ Tipo inesperado: ${item.runtimeType}');
        // Retorna um ServiceModel padrão para evitar erro
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
        servicosNoContrato: servicosConvertidos, // Use a lista convertida
        onServicoAdicionado: (contratoAtualizado) {
          setState(() {
            _contratoEditado = contratoAtualizado;
          });
        },
      ),
    );
  }

  void _processarServicoAdicionado(ContratoModel contratoAtualizado) {
    setState(() {
      _contratoEditado = contratoAtualizado;
    });

    // Atualizar cache
    _cacheAlteracoes['servicos'] = contratoAtualizado.servicos ?? [];

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

  // Método para adicionar pets
  void _adicionarPet() {
    final petsNoContrato = _contratoEditado.pets ?? [];

    print('🎯 Abrindo modal AddPetModal');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        // Criar uma referência para o contexto do modal
        final BuildContext modalContext = context;

        return AddPetModal(
          idContrato: _contratoEditado.idContrato!,
          idUsuario: _contratoEditado.idUsuario,
          petsNoContrato: petsNoContrato,
          onPetAdicionado: (contratoAtualizado) {
            print('🔄 Pet adicionado, atualizando estado...');

            // Atualizar o estado local
            _processarPetAdicionado(contratoAtualizado);

            // Fechar o modal atual
            Navigator.of(modalContext).pop();

            // Reabrir o modal com dados atualizados
            _adicionarPet(); // Chama a si mesmo recursivamente

            // Notificar callback externo
            if (widget.onContratoEditado != null) {
              widget.onContratoEditado!(contratoAtualizado);
            }

            // Mostrar mensagem de sucesso
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Pet adicionado com sucesso!'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
          },
        );
      },
    );
  }

  void _reabrirModalPetAtualizado(ContratoModel contratoAtualizado) {
    // Pequeno delay para garantir que o modal anterior foi fechado
    Future.delayed(Duration(milliseconds: 300), () {
      if (!mounted) return;

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => AddPetModal(
          idContrato: contratoAtualizado.idContrato!,
          idUsuario: contratoAtualizado.idUsuario,
          petsNoContrato: contratoAtualizado.pets ?? [], // Lista ATUALIZADA
          onPetAdicionado: (novoContratoAtualizado) {
            // Processar novo pet adicionado (recursivo)
            _processarPetAdicionado(novoContratoAtualizado);
            Navigator.of(context).pop();
            _reabrirModalPetAtualizado(novoContratoAtualizado);

            if (widget.onContratoEditado != null) {
              widget.onContratoEditado!(novoContratoAtualizado);
            }
          },
        ),
      );
    });
  }

  // No EditBooking, método _processarPetAdicionado:
  void _processarPetAdicionado(ContratoModel contratoAtualizado) {
    print('🔄 Processando pet adicionado');
    print('📊 Pets antes: ${_contratoEditado.pets?.length ?? 0}');
    print('📊 Pets depois: ${contratoAtualizado.pets?.length ?? 0}');

    // Limpar o cache de pets para forçar recarregamento
    if (_cacheAlteracoes.containsKey('pets')) {
      _cacheAlteracoes.remove('pets');
    }

    // Adicionar os novos pets ao cache
    _cacheAlteracoes['pets'] = contratoAtualizado.pets ?? [];

    // Atualizar o estado local
    setState(() {
      _contratoEditado = contratoAtualizado.copyWith();
    });

    print('✅ Pets atualizados: ${_contratoEditado.pets?.length ?? 0}');

    // Mostrar mensagem de sucesso
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pets adicionados com sucesso!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _onContratoAtualizado(ContratoModel contratoAtualizado,
      {String? tipoAlteracao}) {
    print(
        '🔄 _onContratoAtualizado chamado no EditBooking - Tipo: $tipoAlteracao');

    // Armazena no cache apenas as alterações específicas
    if (tipoAlteracao == 'data_inicio' &&
        contratoAtualizado.dataInicio != widget.contrato.dataInicio) {
      _cacheAlteracoes['dataInicio'] = contratoAtualizado.dataInicio;
      print(
          '💾 Data início armazenada no cache: ${contratoAtualizado.dataInicio}');
    }

    if (tipoAlteracao == 'data_fim' &&
        contratoAtualizado.dataFim != widget.contrato.dataFim) {
      _cacheAlteracoes['dataFim'] = contratoAtualizado.dataFim;
      print('💾 Data fim armazenada no cache: ${contratoAtualizado.dataFim}');
    }

    // Para serviços removidos, atualiza imediatamente a UI
    if (tipoAlteracao == 'servico_removido') {
      print('🔄 Serviço removido - atualizando UI imediatamente');
      setState(() {
        _contratoEditado = contratoAtualizado.copyWith();
      });

      // Atualizar cache de serviços
      _cacheAlteracoes['servicos'] = contratoAtualizado.servicos ?? [];
      return;
    }

    // Para pets removidos, atualiza imediatamente a UI
    if (tipoAlteracao == 'pet_removido') {
      print('🔄 Pet removido - atualizando UI imediatamente');
      setState(() {
        _contratoEditado = contratoAtualizado.copyWith();
      });

      // Atualizar cache de pets
      _cacheAlteracoes['pets'] = contratoAtualizado.pets ?? [];
      return;
    }

    // Atualiza a UI com os dados em cache
    _aplicarCacheAoContrato();
  }

  void _aplicarCacheAoContrato() {
    setState(() {
      // Aplica as alterações do cache ao contrato editado
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
          servicos: _cacheAlteracoes['servicos'],
        );
      }

      if (_cacheAlteracoes.containsKey('pets')) {
        _contratoEditado = _contratoEditado.copyWith(
          pets: _cacheAlteracoes['pets'],
        );
      }
    });

    print('📊 Estado atual do cache:');
    _cacheAlteracoes.forEach((key, value) {
      if (value is List) {
        print('  - $key: ${value.length} item(s)');
      } else {
        print('  - $key: $value');
      }
    });
  }

  bool _existemAlteracoes() {
    return _cacheAlteracoes.isNotEmpty;
  }

  // Verificar se o contrato está em status editável
  bool _podeAdicionar() {
    // Status que permitem adição de serviços/pets
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
    print('📊 Alterações a serem salvas: $_cacheAlteracoes');

    try {
      // Simula o salvamento na API
      await _salvarAlteracoesNaAPI();

      // Notifica o callback
      if (widget.onContratoEditado != null) {
        widget.onContratoEditado!(_contratoEditado);
      }

      // Mostra popup de sucesso
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

      // Fecha o modal de edição
      _fecharModal();
    } catch (e) {
      print('❌ Erro ao salvar alterações: $e');
      _mostrarMensagemErro('Erro ao salvar alterações: $e');
    }
  }

  Future<void> _salvarAlteracoesNaAPI() async {
    // Simula o salvamento na API
    await Future.delayed(Duration(milliseconds: 500));
    print('✅ Alterações salvas com sucesso na API');

    // Limpa o cache após salvar
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
      // Pergunta se deseja descartar as alterações
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
              Navigator.of(context).pop(); // Fecha o diálogo
              Navigator.of(context).pop(); // Fecha o modal
            },
            child: Text('Sair', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  String _formatarData(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
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
          // Header no estilo ShowMoreModal
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
                  // Banner de informações do contrato (inspirado no ShowMoreModal)
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

                        // Divisor
                        Container(
                          height: 1,
                          color: Colors.white.withOpacity(0.3),
                        ),

                        const SizedBox(height: 16),

                        // Informações principais
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

                        // Indicador de alterações pendentes
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

                  // Data Information com card
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

                  // Services Information com card
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Text(
                          'Serviços Adicionais',
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
                        textButtonColor:
                            podeAdicionar ? Colors.white : Colors.grey,
                        borderRadius: BorderRadius.circular(50),
                        widthFactor: null,
                        minWidth: null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  ServicesInformation(
                    contrato: _contratoEditado,
                    onContratoAtualizado: _onContratoAtualizado,
                    editavel: podeAdicionar,
                  ),

                  const SizedBox(height: 32),

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
                  ),

                  const SizedBox(height: 32),

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
