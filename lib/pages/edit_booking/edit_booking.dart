import 'package:flutter/material.dart';
import 'package:pet_family_app/models/contrato_model.dart';
import 'package:pet_family_app/pages/edit_booking/informations/data/data_information.dart';
import 'package:pet_family_app/pages/edit_booking/informations/hotel/hotel_information.dart';
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

  @override
  void initState() {
    super.initState();
    _contratoEditado = widget.contrato.copyWith();
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
      return; // Não armazena no cache, já foi processado na API
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
    });

    print('📊 Estado atual do cache:');
    print('  - dataInicio: ${_cacheAlteracoes['dataInicio']}');
    print('  - dataFim: ${_cacheAlteracoes['dataFim']}');
    print('📊 Contrato atualizado na UI:');
    print('  - Data início: ${_contratoEditado.dataInicio}');
    print('  - Data fim: ${_contratoEditado.dataFim}');
  }

  bool _existemAlteracoes() {
    return _cacheAlteracoes.isNotEmpty;
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
      // Aqui você chamaria sua API para salvar as alterações
      await _salvarAlteracoesNaAPI();

      // Notifica o callback com as alterações
      if (widget.onContratoEditado != null) {
        widget.onContratoEditado!(_contratoEditado);
      }

      // Mostra modal de sucesso
      await showModalBottomSheet(
        context: context,
        builder: (BuildContext context) => BookingEdited(),
      );

      // Fecha o modal
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

  @override
  Widget build(BuildContext context) {
    print('🏗️ Build do EditBooking');
    print('📊 Cache: $_cacheAlteracoes');
    print('📊 Contrato UI - Data início: ${_contratoEditado.dataInicio}');
    print('📊 Contrato UI - Data fim: ${_contratoEditado.dataFim}');

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
          // Header (mantido igual)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: _fecharModal,
                  icon: const Icon(Icons.close, size: 24, color: Colors.grey),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 40,
                    minHeight: 40,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Editando agendamento',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _contratoEditado.hospedagemNome ?? 'Agendamento',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (_existemAlteracoes())
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Alterações não salvas',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.orange[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: 1, color: Colors.grey),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  const SizedBox(height: 16),

                  // Hotel Information
                  Container(
                    width: double.infinity,
                    child: HotelInformation(
                      contrato: _contratoEditado,
                      onContratoAtualizado: _onContratoAtualizado,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Data Information
                  Container(
                    width: double.infinity,
                    child: DataInformation(
                      contrato: _contratoEditado,
                      onContratoAtualizado: _onContratoAtualizado,
                      editavel: true,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Services Information
                  Container(
                    width: double.infinity,
                    child: ServicesInformation(
                      contrato: _contratoEditado,
                      onContratoAtualizado: _onContratoAtualizado,
                      editavel: true,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Your Pets Information
                  Container(
                    width: double.infinity,
                    child: YourPetsInformations(
                      contrato: _contratoEditado,
                      onContratoAtualizado: _onContratoAtualizado,
                      editavel: true,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Botões de ação
                  Container(
                    width: double.infinity,
                    child: Column(
                      children: [
                        AppButton(
                          onPressed: _onSalvarAlteracoes,
                          label: 'Salvar Alterações',
                          fontSize: 16,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          // Desabilita o botão se não houver alterações
                          buttonColor:
                              _existemAlteracoes() ? null : Colors.grey[300],
                        ),
                        const SizedBox(height: 12),
                        AppButton(
                          onPressed: _fecharModal,
                          label: 'Cancelar',
                          fontSize: 16,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          buttonColor: Colors.white,
                          textButtonColor: Colors.black,
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
