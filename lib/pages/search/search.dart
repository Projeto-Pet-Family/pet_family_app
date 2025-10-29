import 'package:flutter/material.dart';
import 'package:pet_family_app/models/hospedagem_model.dart';
import 'package:pet_family_app/pages/search/hotel_template.dart';
import 'package:pet_family_app/repository/hospedagem_repository.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final HospedagemRepository _hospedagemRepository = HospedagemRepository();
  List<HospedagemModel> _hospedagens = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _carregarHospedagens();
  }

  Future<void> _carregarHospedagens() async {
    try {
      final hospedagens = await _hospedagemRepository.lerHospedagem();
      setState(() {
        _hospedagens = hospedagens;
        _isLoading = false;
        _errorMessage = '';
      });

      print('🏨 Total de hospedagens carregadas: ${hospedagens.length}');
      for (var hospedagem in hospedagens) {
        print('🏨 - ${hospedagem.nome} (ID: ${hospedagem.idHospedagem})');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Erro ao carregar hospedagens: $e';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar hospedagens: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Align(
            alignment: Alignment.center,
            child: const Text(
              'Hospedagens',
              style: TextStyle(
                fontSize: 35,
                fontWeight: FontWeight.w200,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : _hospedagens.isEmpty
                  ? const Center(child: Text('Nenhuma hospedagem encontrada'))
                  : RefreshIndicator(
                      onRefresh: _carregarHospedagens,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _hospedagens.length,
                        itemBuilder: (context, index) {
                          final hospedagem = _hospedagens[index];

                          return HotelTemplate(
                            name: hospedagem.nome,
                            street: hospedagem.logradouro,
                            number: hospedagem.numero,
                            neighborhood: hospedagem.bairro,
                            city: hospedagem.cidade,
                            state: hospedagem.estado,
                            uf: hospedagem.sigla,
                            zipCode: hospedagem.cep,
                            complement: hospedagem.complemento,
                            idHotel: hospedagem.idHospedagem,
                          );
                        },
                      ),
                    ),
    );
  }
}
