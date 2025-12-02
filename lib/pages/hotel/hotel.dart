import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:pet_family_app/pages/hotel/template/employee/employee_template.dart';
import 'package:pet_family_app/pages/hotel/template/service_template.dart';
import 'package:pet_family_app/widgets/app_bar_return.dart';
import 'package:pet_family_app/widgets/app_button.dart';
import 'package:pet_family_app/providers/hospedagem_provider.dart';
import 'package:pet_family_app/pages/message/message.dart'; // ADICIONAR ESTE IMPORT
import 'package:shared_preferences/shared_preferences.dart';

class Hotel extends StatefulWidget {
  final Map<String, dynamic>? hotelData;
  const Hotel({super.key, required this.hotelData});

  @override
  State<Hotel> createState() => _HotelState();
}

class _HotelState extends State<Hotel> {
  late HotelProvider _hotelProvider;

  // ADICIONAR MÉTODO PARA ABRIR MENSAGENS
  void _abrirTelaMensagem(BuildContext context) {
    if (widget.hotelData == null || widget.hotelData?['idhospedagem'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dados do hotel incompletos')),
      );
      return;
    }

    // Obter ID do usuário logado do cache
    _obterIdUsuarioLogado().then((idUsuario) {
      if (idUsuario == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuário não identificado')),
        );
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Message(
            idusuario: idUsuario,
            idhospedagem: widget.hotelData!['idhospedagem'],
            nomeHospedagem: widget.hotelData!['nome'] ?? 'Hospedagem',
          ),
        ),
      );
    });
  }

  // MÉTODO PARA OBTER ID DO USUÁRIO DO CACHE
  Future<int?> _obterIdUsuarioLogado() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt('idUsuario'); // Supondo que 'user_id' seja a chave
    } catch (e) {
      print('❌ Erro ao obter ID do usuário: $e');
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _hotelProvider = HotelProvider();
    _initializeData();
  }

  void _initializeData() {
    if (widget.hotelData != null) {
      final hotelId = widget.hotelData?['idhospedagem'];
      if (hotelId != null) {
        _salvarHotelIdNoCache(hotelId);
        _hotelProvider.fetchServicos(hotelId);
      }
    }
  }

  Future<void> _salvarHotelIdNoCache(int hotelId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('current_hotel_id', hotelId);
      print('💾 Hotel ID salvo no cache: $hotelId');
    } catch (e) {
      print('❌ Erro ao salvar hotel ID: $e');
    }
  }

  Future<void> _salvarValorDiariaNoCache(String valorDiaria) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('hotel_daily_rate', valorDiaria);
      print('💾 Valor diária salvo: $valorDiaria');
    } catch (e) {
      print('❌ Erro salvar diária: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.hotelData == null) return _buildErrorScreen();

    return ChangeNotifierProvider.value(
      value: _hotelProvider,
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              const AppBarReturn(route: '/core-navigation'),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Consumer<HotelProvider>(
                  builder: (context, hotelProvider, child) =>
                      _buildHotelContent(hotelProvider),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorScreen() => Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/core-navigation'),
          ),
          title: const Text('Erro'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 80, color: Colors.red),
                const SizedBox(height: 20),
                const Text('Hotel não encontrado',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center),
                const SizedBox(height: 16),
                const Text('Não foi possível carregar os dados do hotel.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16)),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () => context.go('/core-navigation'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 15),
                  ),
                  child: const Text('Voltar para Home'),
                ),
              ],
            ),
          ),
        ),
      );

  Widget _buildHotelContent(HotelProvider hotelProvider) {
    final hotel = widget.hotelData!;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _buildHotelHeader(hotel),
      _buildServicesSection(hotelProvider),
      _buildDivider(),
      _buildEmployeesSection(),
      _buildActionButtons(),
    ]);
  }

  Widget _buildHotelHeader(Map<String, dynamic> hotel) {
    final String nome = hotel['nome'] ?? 'Nome não disponível';
    final String valorDiaria =
        _formatarPreco(hotel['valor_diaria']?.toString() ?? '0.00');
    final enderecoCompleto = _buildEnderecoCompleto(hotel);

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Column(children: [
          const Icon(Icons.house, size: 80),
          Text(nome,
              style: const TextStyle(
                  fontSize: 50,
                  fontWeight: FontWeight.w200,
                  color: Colors.black))
        ]),
        Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
                color: const Color(0xFF159800),
                borderRadius: BorderRadius.circular(8)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Text('$valorDiaria / dia',
                  style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.white))
            ])),
      ]),
      Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Expanded(
                child: Text(enderecoCompleto,
                    style: const TextStyle(
                        fontWeight: FontWeight.w100,
                        color: Colors.black,
                        fontSize: 15)))
          ])),
      const Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Divider(color: Color(0xFFCCCCCC), thickness: 1)),
    ]);
  }

  Widget _buildServicesSection(HotelProvider hotelProvider) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Serviços extras',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w200,
                color: Colors.black)),
        const SizedBox(height: 20),
        if (hotelProvider.isLoading)
          const Padding(
              padding: EdgeInsets.all(20),
              child: Center(
                  child: Column(children: [
                CircularProgressIndicator(),
                SizedBox(height: 10),
                Text('Carregando serviços...',
                    style: TextStyle(
                        fontWeight: FontWeight.w100, color: Colors.grey))
              ]))),
        if (hotelProvider.errorMessage.isNotEmpty)
          _buildErrorSection(hotelProvider),
        if (!hotelProvider.isLoading && hotelProvider.errorMessage.isEmpty)
          Column(
              children: hotelProvider.servicos
                  .map((servico) => ServiceTemplate(
                      service:
                          servico['nome'] ?? servico['descricao'] ?? 'Serviço',
                      price: _formatarPreco(
                          servico['preco']?.toString() ?? '0.00')))
                  .toList()),
        if (!hotelProvider.isLoading &&
            hotelProvider.errorMessage.isEmpty &&
            hotelProvider.servicos.isEmpty)
          const Padding(
              padding: EdgeInsets.all(20),
              child: Center(
                  child: Text('Nenhum serviço disponível',
                      style: TextStyle(
                          fontWeight: FontWeight.w100,
                          color: Colors.grey,
                          fontSize: 16)))),
      ]);

  Widget _buildErrorSection(HotelProvider hotelProvider) => Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            children: [
              const Icon(Icons.error_outline, size: 50, color: Colors.red),
              const SizedBox(height: 10),
              Text(hotelProvider.errorMessage,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                  textAlign: TextAlign.center),
              const SizedBox(height: 15),
              ElevatedButton(
                onPressed: () {
                  final hotelId = widget.hotelData?['idhospedagem'];
                  if (hotelId != null) hotelProvider.fetchServicos(hotelId);
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, foregroundColor: Colors.white),
                child: const Text('Tentar Novamente'),
              ),
            ],
          ),
        ),
      );

  Widget _buildDivider() => const Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Divider(thickness: 1, color: Color(0xFFCCCCCC)));

  Widget _buildEmployeesSection() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Funcionários',
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.w100, color: Colors.black),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                EmployeeTemplate(),
                EmployeeTemplate(),
                EmployeeTemplate(),
                EmployeeTemplate(),
                EmployeeTemplate()
              ],
            ),
          ),
        ],
      );

  Widget _buildActionButtons() => Column(
        children: [
          const SizedBox(height: 40),
          Align(
            alignment: Alignment.center,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  minimumSize: Size.zero,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap),
              onPressed: () => _abrirTelaMensagem(context), // CORRIGIDO AQUI
              child: IntrinsicWidth(
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.chat, size: 20, color: Colors.black),
                    SizedBox(width: 4),
                    Text(
                      'Enviar mensagem',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w200,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 50, 0, 40),
            child: AppButton(
                onPressed: _navigateToSchedule,
                label: 'Agendar aqui',
                fontSize: 25),
          ),
        ],
      );

  String _buildEnderecoCompleto(Map<String, dynamic> hotel) {
    final parts = [
      hotel['logradouro'],
      hotel['numero']?.toString(),
      hotel['complemento'],
      hotel['bairro'],
      hotel['cidade'],
      hotel['estado']
    ]
        .where((element) => element != null && element.toString().isNotEmpty)
        .toList();
    return parts.join(', ');
  }

  String _formatarPreco(String preco) {
    final valor = double.tryParse(preco) ?? 0.0;
    return 'R\$${valor.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  // REMOVER _showMessageDialog ANTIGO E SUBSTITUIR POR _abrirTelaMensagem

  void _navigateToSchedule() {
    final hotelId = widget.hotelData?['idhospedagem'];
    final hotelNome = widget.hotelData?['nome'] ?? 'Hotel';
    final valorDiaria = widget.hotelData?['valor_diaria']?.toString() ?? '0.00';

    if (hotelId != null) {
      _salvarValorDiariaNoCache(valorDiaria);
      context.go('/choose-pet',
          extra: {'hotelId': hotelId, 'hotelNome': hotelNome});
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Erro'),
          content: const Text('Não foi possível identificar o hotel.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            )
          ],
        ),
      );
    }
  }
}
