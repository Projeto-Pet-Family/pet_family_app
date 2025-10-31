import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:pet_family_app/pages/hotel/template/employee/employee_template.dart';
import 'package:pet_family_app/pages/hotel/template/service_template.dart';
import 'package:pet_family_app/widgets/app_bar_return.dart';
import 'package:pet_family_app/widgets/app_button.dart';
import 'package:pet_family_app/widgets/rating_stars.dart';
import 'package:pet_family_app/providers/hotel_provider.dart';

class Hotel extends StatefulWidget {
  final Map<String, dynamic>? hotelData;

  const Hotel({
    super.key,
    required this.hotelData,
  });

  @override
  State<Hotel> createState() => _HotelState();
}

class _HotelState extends State<Hotel> {
  late HotelProvider _hotelProvider;

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
        print('🔄 Inicializando serviços para hotel ID: $hotelId');
        _hotelProvider.fetchServicos(hotelId);
      } else {
        print('⚠️  ID da hospedagem não encontrado nos dados do hotel');
      }
    } else {
      print('⚠️  Dados do hotel são nulos');
    }
  }

  @override
  void didUpdateWidget(Hotel oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Recarregar serviços se os dados do hotel mudaram
    if (widget.hotelData != oldWidget.hotelData) {
      _initializeData();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.hotelData == null) {
      return _buildErrorScreen();
    }

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
                  builder: (context, hotelProvider, child) {
                    return _buildHotelContent(hotelProvider);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorScreen() {
    return Scaffold(
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
              const Icon(
                Icons.error_outline,
                size: 80,
                color: Colors.red,
              ),
              const SizedBox(height: 20),
              const Text(
                'Hotel não encontrado',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Não foi possível carregar os dados do hotel. '
                'Por favor, tente novamente.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => context.go('/core-navigation'),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
                child: const Text('Voltar para Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHotelContent(HotelProvider hotelProvider) {
    final hotel = widget.hotelData!;
    final enderecoCompleto = _buildEnderecoCompleto(hotel);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHotelHeader(hotel, enderecoCompleto),
        _buildServicesSection(hotelProvider),
        _buildDivider(),
        _buildEmployeesSection(),
        _buildActionButtons(),
      ],
    );
  }

  Widget _buildHotelHeader(
      Map<String, dynamic> hotel, String enderecoCompleto) {
    final String nome = hotel['nome'] ?? 'Nome não disponível';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                const Icon(
                  Icons.house,
                  size: 80,
                ),
                Text(
                  nome,
                  style: const TextStyle(
                    fontSize: 50,
                    fontWeight: FontWeight.w200,
                    color: Colors.black,
                  ),
                )
              ],
            ),
            Column(
              children: [
                const Text(
                  'Aberto',
                  style: TextStyle(
                    fontSize: 40,
                    color: Color(0xFF60F700),
                    fontWeight: FontWeight.w200,
                  ),
                ),
                const Text(
                  '08:00 as 19:30',
                  style: TextStyle(
                    fontSize: 20,
                    color: Color(0xFF4A4A4A),
                    fontWeight: FontWeight.w100,
                  ),
                ),
              ],
            )
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  enderecoCompleto,
                  style: const TextStyle(
                    fontWeight: FontWeight.w100,
                    color: Colors.black,
                    fontSize: 15,
                  ),
                ),
              ),
              const Text(
                'há 2.5km',
                style: TextStyle(
                  fontWeight: FontWeight.w100,
                  color: Colors.black,
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ),
        _buildRatingSection(),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Divider(
            color: Color(0xFFCCCCCC),
            thickness: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildRatingSection() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '4.5',
              style: TextStyle(
                fontWeight: FontWeight.w100,
                color: Colors.black,
                fontSize: 20,
              ),
            ),
            SizedBox(width: 5),
            RatingStars(
              colorStar: Colors.black,
            ),
          ],
        ),
        Text(
          '2500 avaliações',
          style: TextStyle(
            fontWeight: FontWeight.w100,
            color: Colors.black,
            fontSize: 20,
          ),
        ),
      ],
    );
  }

  Widget _buildServicesSection(HotelProvider hotelProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Serviços',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w200,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 20),

        // Estado de carregamento
        if (hotelProvider.isLoading)
          const Padding(
            padding: EdgeInsets.all(20),
            child: Center(
              child: Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 10),
                  Text(
                    'Carregando serviços...',
                    style: TextStyle(
                      fontWeight: FontWeight.w100,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          )

        // Estado de erro
        else if (hotelProvider.errorMessage.isNotEmpty)
          _buildErrorSection(hotelProvider)

        // Estado com serviços carregados
        else if (hotelProvider.servicos.isNotEmpty)
          Column(
            children: hotelProvider.servicos.map((servico) {
              final String descricao = servico['descricao'] ?? 'Serviço';
              final String preco = servico['preco']?.toString() ?? '0.00';
              final String nome = servico['nome'] ?? descricao;

              return ServiceTemplate(
                service: nome,
                price: _formatarPreco(preco),
              );
            }).toList(),
          )

        // Estado sem serviços
        else
          const Padding(
            padding: EdgeInsets.all(20),
            child: Center(
              child: Text(
                'Nenhum serviço disponível',
                style: TextStyle(
                  fontWeight: FontWeight.w100,
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildErrorSection(HotelProvider hotelProvider) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Column(
          children: [
            const Icon(
              Icons.error_outline,
              size: 50,
              color: Colors.red,
            ),
            const SizedBox(height: 10),
            Text(
              hotelProvider.errorMessage,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: () {
                final hotelId = widget.hotelData?['idhospedagem'];
                if (hotelId != null) {
                  hotelProvider.fetchServicos(hotelId);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Tentar Novamente'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Divider(
        thickness: 1,
        color: Color(0xFFCCCCCC),
      ),
    );
  }

  Widget _buildEmployeesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Funcionários',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w100,
            color: Colors.black,
          ),
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
              EmployeeTemplate(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        const SizedBox(height: 40),
        Align(
          alignment: Alignment.center,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: Size.zero,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onPressed: () {
              // TODO: Implementar funcionalidade de mensagem
              _showMessageDialog();
            },
            child: IntrinsicWidth(
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.chat,
                    size: 20,
                    color: Colors.black,
                  ),
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
            onPressed: () {
              _navigateToSchedule();
            },
            label: 'Agendar aqui',
            fontSize: 25,
          ),
        ),
      ],
    );
  }

  String _buildEnderecoCompleto(Map<String, dynamic> hotel) {
    final String numero = hotel['numero']?.toString() ?? '';
    final String complemento = hotel['complemento'] ?? '';
    final String logradouro = hotel['logradouro'] ?? '';
    final String bairro = hotel['bairro'] ?? '';
    final String cidade = hotel['cidade'] ?? '';
    final String estado = hotel['estado'] ?? '';

    final enderecoParts = [
      if (logradouro.isNotEmpty) logradouro,
      if (numero.isNotEmpty) numero,
      if (complemento.isNotEmpty) complemento,
      if (bairro.isNotEmpty) bairro,
      if (cidade.isNotEmpty) cidade,
      if (estado.isNotEmpty) estado,
    ];

    return enderecoParts.join(', ');
  }

  String _formatarPreco(String preco) {
    try {
      final valor = double.tryParse(preco) ?? 0.0;
      return 'R\$${valor.toStringAsFixed(2).replaceAll('.', ',')}';
    } catch (e) {
      return 'R\$0,00';
    }
  }

  void _showMessageDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enviar Mensagem'),
          content: const Text(
            'Funcionalidade de mensagem em desenvolvimento. '
            'Em breve você poderá enviar mensagens diretamente para o hotel.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _navigateToSchedule() {
    final hotelId = widget.hotelData?['idhospedagem'];
    final hotelNome = widget.hotelData?['nome'] ?? 'Hotel';

    if (hotelId != null) {
      print('🏨 Navegando para agendamento - Hotel ID: $hotelId');
      context.go('/choose-pet', extra: {
        'hotelId': hotelId,
        'hotelNome': hotelNome,
      });
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Erro'),
            content: const Text(
                'Não foi possível identificar o hotel para agendamento.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }
}
