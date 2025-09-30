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
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initializeData();
  }

  void _initializeData() {
    final hotelProvider = Provider.of<HotelProvider>(context, listen: false);
    final hotelId = widget.hotelData?['idhospedagem'];
    
    if (hotelId != null) {
      hotelProvider.fetchServicos(hotelId);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Verifica se hotelData é nulo
    if (widget.hotelData == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/core-navigation'),
          ),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text(
                'Erro ao carregar dados do hotel',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Os dados do hotel não foram encontrados.',
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
            ],
          ),
        ),
      );
    }

    return ChangeNotifierProvider(
      create: (context) => HotelProvider(),
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

  Widget _buildHotelContent(HotelProvider hotelProvider) {
    final hotel = widget.hotelData!; // Agora sabemos que não é nulo
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

  Widget _buildHotelHeader(Map<String, dynamic> hotel, String enderecoCompleto) {
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
        
        // Estado de carregamento ou erro
        if (hotelProvider.isLoading)
          const Center(
            child: CircularProgressIndicator(),
          )
        else if (hotelProvider.errorMessage.isNotEmpty)
          _buildErrorSection(hotelProvider)
        else if (hotelProvider.servicos.isNotEmpty)
          ...hotelProvider.servicos.map((servico) {
            final String descricao = servico['descricao'] ?? 'Serviço';
            final String preco = servico['preco'] ?? '0.00';
            
            return ServiceTemplate(
              service: descricao,
              price: _formatarPreco(preco),
            );
          }).toList()
        else
          const Text(
            'Nenhum serviço disponível',
            style: TextStyle(
              fontWeight: FontWeight.w100,
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
      ],
    );
  }

  Widget _buildErrorSection(HotelProvider hotelProvider) {
    return Center(
      child: Column(
        children: [
          Text(
            hotelProvider.errorMessage,
            style: const TextStyle(
              color: Colors.red,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              final hotelId = widget.hotelData?['idhospedagem'];
              if (hotelId != null) {
                hotelProvider.fetchServicos(hotelId);
              }
            },
            child: const Text('Tentar Novamente'),
          ),
        ],
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
              context.go('/choose-pet');
            },
            label: 'Agendar aqui',
            fontSize: 25,
          ),
        ),
      ],
    );
  }

  // Método auxiliar para construir o endereço completo
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

  // Método para formatar o preço no padrão brasileiro
  String _formatarPreco(String preco) {
    try {
      final valor = double.tryParse(preco) ?? 0.0;
      return 'R\$${valor.toStringAsFixed(2).replaceAll('.', ',')}';
    } catch (e) {
      return 'R\$0,00';
    }
  }
}