import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_family_app/pages/hotel/scheduling_accommodation/choose_data/data_template.dart';
import 'package:pet_family_app/widgets/app_bar_return.dart';
import 'package:pet_family_app/widgets/app_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChooseData extends StatefulWidget {
  const ChooseData({super.key});

  @override
  State<ChooseData> createState() => _ChooseDataState();
}

class _ChooseDataState extends State<ChooseData> {
  DateTime? _startDate;
  DateTime? _endDate;
  DateTime? _minEndDate;

  @override
  void initState() {
    super.initState();
    _carregarDatasDoCache();
  }

  // Carrega as datas salvas no cache
  Future<void> _carregarDatasDoCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final startDateMillis = prefs.getInt('selected_start_date');
      final endDateMillis = prefs.getInt('selected_end_date');

      if (startDateMillis != null) {
        setState(() {
          _startDate = DateTime.fromMillisecondsSinceEpoch(startDateMillis);
          _minEndDate = _startDate!.add(const Duration(days: 1));
        });
      }

      if (endDateMillis != null) {
        setState(() {
          _endDate = DateTime.fromMillisecondsSinceEpoch(endDateMillis);
        });
      }

      print(
          '📅 Datas carregadas do cache - Início: $_startDate, Fim: $_endDate');
    } catch (e) {
      print('❌ Erro ao carregar datas do cache: $e');
    }
  }

  // Salva as datas no cache
  Future<void> _salvarDatasNoCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (_startDate != null) {
        await prefs.setInt(
            'selected_start_date', _startDate!.millisecondsSinceEpoch);
      }

      if (_endDate != null) {
        await prefs.setInt(
            'selected_end_date', _endDate!.millisecondsSinceEpoch);
      }

      // Salva também como string para facilitar leitura
      if (_startDate != null && _endDate != null) {
        await prefs.setString(
            'selected_start_date_str', _startDate!.toIso8601String());
        await prefs.setString(
            'selected_end_date_str', _endDate!.toIso8601String());

        // Calcula e salva a quantidade de dias
        final days = _endDate!.difference(_startDate!).inDays;
        await prefs.setInt('selected_days_count', days);
      }

      print('💾 Datas salvas no cache - Início: $_startDate, Fim: $_endDate');
    } catch (e) {
      print('❌ Erro ao salvar datas no cache: $e');
    }
  }

  // Limpa as datas do cache
  Future<void> _limparDatasDoCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.remove('selected_start_date');
      await prefs.remove('selected_end_date');
      await prefs.remove('selected_start_date_str');
      await prefs.remove('selected_end_date_str');
      await prefs.remove('selected_days_count');

      setState(() {
        _startDate = null;
        _endDate = null;
        _minEndDate = null;
      });

      print('🗑️ Datas limpas do cache');
    } catch (e) {
      print('❌ Erro ao limpar datas do cache: $e');
    }
  }

  void _onStartDateSelected(DateTime date) {
    setState(() {
      _startDate = date;
      _minEndDate = date.add(const Duration(days: 1));

      // Se a data final for anterior à nova data inicial, limpa a data final
      if (_endDate != null && _endDate!.isBefore(_minEndDate!)) {
        _endDate = null;
      }
    });

    // Salva automaticamente no cache
    _salvarDatasNoCache();
  }

  void _onEndDateSelected(DateTime date) {
    setState(() {
      _endDate = date;
    });

    // Salva automaticamente no cache
    _salvarDatasNoCache();
  }

  void _navigateToNext() {
    // Garante que as datas estão salvas antes de navegar
    _salvarDatasNoCache();

    context.go('/choose-service');
  }

  // Método para obter a data inicial padrão para o campo de fim
  DateTime get _defaultFirstDateForEnd {
    return _minEndDate ?? DateTime.now().add(const Duration(days: 1));
  }

  // Método para obter a data inicial padrão para o campo de início
  DateTime get _defaultFirstDateForStart {
    return DateTime.now();
  }

  // Método para obter a data final padrão
  DateTime get _defaultLastDate {
    return DateTime.now().add(const Duration(days: 365));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            AppBarReturn(route: '/choose-pet'),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 60),
                  const Align(
                    alignment: Alignment.center,
                    child: Text(
                      'Escolha as datas:',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w200,
                        color: Colors.black,
                      ),
                    ),
                  ),

                  // Mostra as datas selecionadas se existirem
                  if (_startDate != null || _endDate != null) ...[
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Datas selecionadas:',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _startDate != null && _endDate != null
                                      ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year} - ${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                                      : _startDate != null
                                          ? 'Início: ${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                                          : 'Fim: ${_endDate!.day}/${_endDate!.month}/${_endDate!.year}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.green,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                if (_startDate != null && _endDate != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    '${_endDate!.difference(_startDate!).inDays} dias',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: _limparDatasDoCache,
                            icon: const Icon(Icons.clear, color: Colors.green),
                            tooltip: 'Limpar datas',
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 30),

                  // Campo de data de início
                  const Text(
                    'Início:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DataTemplate(
                    firstDate: _defaultFirstDateForStart,
                    lastDate: _defaultLastDate,
                    initialDate: _startDate,
                    onDateSelected: _onStartDateSelected,
                    hintText: 'Selecione a data de início',
                  ),

                  const SizedBox(height: 30),

                  // Campo de data de fim
                  const Text(
                    'Fim:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DataTemplate(
                    firstDate: _defaultFirstDateForEnd,
                    lastDate: _defaultLastDate,
                    initialDate: _endDate,
                    onDateSelected: _onEndDateSelected,
                    hintText: _startDate == null
                        ? 'Selecione a data de início primeiro'
                        : 'Selecione a data de fim',
                    enabled: _startDate !=
                        null, // Desabilita se não tiver data de início
                  ),

                  const SizedBox(height: 40),

                  // Botão para limpar todas as seleções
                  if (_startDate != null || _endDate != null)
                    OutlinedButton(
                      onPressed: _limparDatasDoCache,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text('Limpar Datas'),
                    ),

                  if (_startDate != null || _endDate != null)
                    const SizedBox(height: 16),

                  // Botão próximo
                  if (_startDate != null && _endDate != null)
                    AppButton(
                      onPressed: _navigateToNext,
                      label: 'Próximo',
                      fontSize: 20,
                    ),

                  // Mensagem informativa
                  if (_startDate == null)
                    const Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: Text(
                        '💡 Selecione primeiro a data de início para habilitar a data de fim',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
