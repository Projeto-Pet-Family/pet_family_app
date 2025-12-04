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
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
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

  String _formatarData(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
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
                        onPressed: () {},
                        label: 'Adicionar',
                        fontSize: 14,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        buttonColor: const Color(0xff8692DE),
                        textButtonColor: Colors.white,
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
                    editavel: true,
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
                        onPressed: () {},
                        label: 'Adicionar',
                        fontSize: 14,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        buttonColor: const Color(0xff8692DE),
                        textButtonColor: Colors.white,
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
                    editavel: true,
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
