// pages/hotel/hotel.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_family_app/models/service_model.dart';
import 'package:provider/provider.dart';
import 'package:pet_family_app/pages/hotel/template/employee/employee_template.dart';
import 'package:pet_family_app/pages/hotel/template/service_template.dart';
import 'package:pet_family_app/widgets/app_bar_return.dart';
import 'package:pet_family_app/widgets/app_button.dart';
import 'package:pet_family_app/providers/hospedagem_provider.dart';
import 'package:pet_family_app/pages/message/message.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  late HospedagemProvider _hospedagemProvider;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _isInitialized = false;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  Future<void> _salvarHotelNoCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (widget.hotelData != null &&
          widget.hotelData!['idhospedagem'] != null) {
        final hotelId = widget.hotelData!['idhospedagem'] as int;

        await prefs.setInt('id_hospedagem_selecionada', hotelId);
        await prefs.setString('hotel_nome', widget.hotelData!['nome'] ?? '');
        await prefs.setString(
            'hotel_logradouro', widget.hotelData!['logradouro'] ?? '');
        await prefs.setString(
            'hotel_cidade', widget.hotelData!['cidade'] ?? '');
        await prefs.setString(
            'hotel_estado', widget.hotelData!['estado'] ?? '');
        await prefs.setString('hotel_valor_diaria',
            widget.hotelData!['valor_diaria']?.toString() ?? '0.00');

        print('✅ Hotel salvo no cache - ID: $hotelId');
      }
    } catch (e) {
      print('❌ Erro ao salvar hotel no cache: $e');
    }
  }

  void _initializeData() {
    if (_isInitialized || widget.hotelData == null) return;

    final hotelId = widget.hotelData!['idhospedagem'];
    if (hotelId != null) {
      _salvarHotelNoCache();

      final provider = Provider.of<HospedagemProvider>(context, listen: false);
      provider.setHotelData(widget.hotelData!);
      provider.carregarServicos(hotelId);

      _isInitialized = true;
    }
  }

  void _abrirTelaMensagem(BuildContext context) {
    if (widget.hotelData == null || widget.hotelData?['idhospedagem'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dados do hotel incompletos')),
      );
      return;
    }

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

  Future<int?> _obterIdUsuarioLogado() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt('idUsuario');
    } catch (e) {
      print('❌ Erro ao obter ID do usuário: $e');
      return null;
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

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const AppBarReturn(route: '/core-navigation'),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Consumer<HospedagemProvider>(
                builder: (context, hospedagemProvider, child) {
                  if (!_isInitialized) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _initializeData();
                    });
                  }

                  return _buildHotelContent(hospedagemProvider);
                },
              ),
            ),
          ],
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

  Widget _buildHotelContent(HospedagemProvider hospedagemProvider) {
    final hotel = widget.hotelData!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHotelHeader(hotel),
        _buildServicesSection(hospedagemProvider),
        _buildDivider(),
        /* _buildEmployeesSection(), */
        _buildActionButtons(),
      ],
    );
  }

  Widget _buildHotelHeader(Map<String, dynamic> hotel) {
    final String nome = hotel['nome'] ?? 'Nome não disponível';
    final String valorDiaria =
        _formatarPreco(hotel['valor_diaria']?.toString() ?? '0.00');
    final enderecoCompleto = _buildEnderecoCompleto(hotel);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Ícone e Nome do Hotel
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                const Icon(Icons.house, size: 80),
                Text(
                  nome,
                  style: const TextStyle(
                    fontSize: 35, // REDUZIDO de 50 para 35
                    fontWeight: FontWeight.w300, // Alterado de w200 para w300
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ],
        ),
        
        // Endereço completo
        Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 12),
          child: Text(
            enderecoCompleto,
            style: const TextStyle(
              fontWeight: FontWeight.w300, // Alterado de w100 para w300
              color: Colors.black,
              fontSize: 16, // Aumentado de 15 para 16
            ),
          ),
        ),
        
        // Valor da diária (AGORA ABAIXO DO ENDEREÇO)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF159800),
            borderRadius: BorderRadius.circular(8),
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
              const Text(
                'VALOR DA DIÁRIA',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.monetization_on_outlined,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$valorDiaria / dia',
                    style: const TextStyle(
                      fontSize: 22, // Ajustado de 25 para 22
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Divider(color: Color(0xFFCCCCCC), thickness: 1),
        ),
      ],
    );
  }

  Widget _buildServicesSection(HospedagemProvider hospedagemProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Serviços extras',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w300, // Alterado de w200 para w300
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 20),
        if (hospedagemProvider.isLoading) _buildLoadingWidget(),
        if (hospedagemProvider.error != null && !hospedagemProvider.isLoading)
          _buildErrorWidget(hospedagemProvider.error!),
        if (hospedagemProvider.servicos.isEmpty &&
            !hospedagemProvider.isLoading &&
            hospedagemProvider.error == null)
          _buildEmptyServicesWidget(),
        if (hospedagemProvider.servicos.isNotEmpty)
          _buildServicesList(hospedagemProvider.servicos),
      ],
    );
  }

  Widget _buildLoadingWidget() {
    return const Padding(
      padding: EdgeInsets.all(20),
      child: Center(
        child: Column(
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 10),
            Text(
              'Carregando serviços...',
              style: TextStyle(
                fontWeight: FontWeight.w300, // Alterado de w100 para w300
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.error_outline, size: 50, color: Colors.red),
            const SizedBox(height: 10),
            const Text(
              'Erro ao carregar serviços',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              error.length > 50 ? '${error.substring(0, 50)}...' : error,
              style: const TextStyle(
                fontWeight: FontWeight.w300, // Alterado de w100 para w300
                color: Colors.grey,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                final hotelId = widget.hotelData!['idhospedagem'];
                if (hotelId != null) {
                  Provider.of<HospedagemProvider>(context, listen: false)
                      .carregarServicos(hotelId);
                }
              },
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyServicesWidget() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.construction, size: 50, color: Colors.grey),
            const SizedBox(height: 10),
            const Text(
              'Nenhum serviço extra disponível',
              style: TextStyle(
                fontWeight: FontWeight.w300, // Alterado de w100 para w300
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'Esta hospedagem ainda não cadastrou serviços extras',
              style: TextStyle(
                fontWeight: FontWeight.w300, // Alterado de w100 para w300
                color: Colors.grey[400],
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServicesList(List<ServiceModel> servicos) {
    return Column(
      children: servicos.map((servico) {
        return ServiceTemplate(
          service: servico.descricao,
          price: 'R\$ ${servico.preco.toStringAsFixed(2)}',
        );
      }).toList(),
    );
  }

  Widget _buildDivider() => const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Divider(
          thickness: 1,
          color: Color(0xFFCCCCCC),
        ),
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
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: () => _abrirTelaMensagem(context),
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
                        fontWeight: FontWeight.w300, // Alterado de w200 para w300
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
              fontSize: 25,
            ),
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
      hotel['estado'],
    ]
        .where((element) => element != null && element.toString().isNotEmpty)
        .toList();
    return parts.join(', ');
  }

  String _formatarPreco(String preco) {
    final valor = double.tryParse(preco) ?? 0.0;
    return 'R\$${valor.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  void _navigateToSchedule() {
    final hotelId = widget.hotelData?['idhospedagem'];
    final hotelNome = widget.hotelData?['nome'] ?? 'Hotel';
    final valorDiaria = widget.hotelData?['valor_diaria']?.toString() ?? '0.00';

    if (hotelId != null) {
      // Salva os dados no cache
      _salvarHotelNoCache();
      _salvarValorDiariaNoCache(valorDiaria);

      // Garante que o id da hospedagem está salvo no cache
      _salvarIdHospedagemNoCache(hotelId);

      context.go(
        '/choose-pet',
        extra: {
          'hotelId': hotelId,
          'hotelNome': hotelNome,
        },
      );
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
            ),
          ],
        ),
      );
    }
  }

  Future<void> _salvarIdHospedagemNoCache(int idHospedagem) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('id_hospedagem_selecionada', idHospedagem);
      print('💾 ID da hospedagem salvo no cache: $idHospedagem');
    } catch (e) {
      print('❌ Erro ao salvar ID da hospedagem no cache: $e');
    }
  }
}