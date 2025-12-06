// pages/edit_booking/modal/add_pet_modal.dart
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:pet_family_app/models/pet/pet_model.dart';
import 'package:pet_family_app/services/contrato_service.dart';
import 'package:pet_family_app/widgets/app_button.dart';
import 'package:pet_family_app/models/contrato_model.dart';
import 'package:http/http.dart' as http;

class AddPetModal extends StatefulWidget {
  final int idContrato;
  final int idUsuario;
  final List<dynamic> petsNoContrato;
  final Function(ContratoModel) onPetAdicionado;

  const AddPetModal({
    super.key,
    required this.idContrato,
    required this.idUsuario,
    required this.petsNoContrato,
    required this.onPetAdicionado,
  });

  @override
  State<AddPetModal> createState() => _AddPetModalState();
}

class _AddPetModalState extends State<AddPetModal> {
  late ContratoService _contratoService;
  List<PetModel> _petsDisponiveis = [];
  final List<int> _petsSelecionados = [];
  bool _carregando = true;
  bool _enviando = false;

  @override
  void initState() {
    super.initState();
    final dio = Dio();
    _contratoService = ContratoService(dio: dio, client: http.Client());
    _carregarPetsDisponiveis();
  }

  // No AddPetModal, método _carregarPetsDisponiveis corrigido:
  Future<void> _carregarPetsDisponiveis() async {
    try {
      final dio = Dio();

      print('🔄 Carregando pets para usuário: ${widget.idUsuario}');

      // 1. Extrair IDs dos pets já no contrato
      List<int> petsContratoIds = [];

      for (var pet in widget.petsNoContrato) {
        if (pet is Map) {
          // O ID correto está em 'idpet' (minúsculo) baseado nos logs anteriores
          final dynamic id = pet['idpet'] ?? pet['idPet'] ?? pet['id'];

          if (id != null) {
            final intId =
                id is int ? id : (id is String ? int.tryParse(id) : null);
            if (intId != null) {
              petsContratoIds.add(intId);
              print('✅ ID do pet no contrato: $intId');
            }
          }
        }
      }

      print('🔍 IDs dos pets JÁ no contrato: $petsContratoIds');

      // 2. Buscar todos os pets do usuário
      final response = await dio.get(
        'https://bepetfamily.onrender.com/contrato/${widget.idContrato}/pet',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      print('✅ Response status: ${response.statusCode}');
      print('📦 Tipo do response.data: ${response.data.runtimeType}');

      if (response.statusCode == 200) {
        // 3. Processar a resposta CORRETAMENTE
        List<dynamic> petsList = [];

        if (response.data is Map) {
          final Map<String, dynamic> responseMap = response.data;
          print('🗺️ Chaves do Map: ${responseMap.keys}');

          // A resposta tem estrutura: {message: ..., data: {... pets: [...]}}
          if (responseMap.containsKey('data')) {
            final data = responseMap['data'];
            if (data is Map && data.containsKey('pets')) {
              petsList = data['pets'] ?? [];
              print('📊 Encontrado pets em data.pets: ${petsList.length} pets');
            }
          }
        }

        if (petsList.isEmpty) {
          print('⚠️ Nenhum pet encontrado na resposta');
          setState(() {
            _petsDisponiveis = [];
            _carregando = false;
          });
          return;
        }

        // 4. Criar lista de PetModel CORRETAMENTE
        final todosPets = petsList.map<PetModel>((petJson) {
          print('📝 Processando pet JSON: $petJson');

          // Extrair ID CORRETAMENTE - o campo é 'idPet' (com P maiúsculo)
          final dynamic id = petJson['idPet'] ?? petJson['id'];
          final int petId =
              id is int ? id : (id is String ? int.tryParse(id) ?? 0 : 0);

          return PetModel(
            idPet: petId,
            nome: petJson['nome'] ?? 'Pet sem nome',
            sexo: petJson['sexo'] ?? 'Não informado',
            descricaoRaca:
                petJson['descricaoRaca'] ?? petJson['raca'] ?? 'Não informada',
          );
        }).toList();

        // 5. Log dos pets carregados
        print('📋 TODOS os pets do usuário:');
        for (var pet in todosPets) {
          print('   - ${pet.nome} (ID: ${pet.idPet})');
        }

        // 6. Filtrar pets disponíveis (não estão no contrato)
        final petsDisponiveis = todosPets.where((pet) {
          final disponivel = !petsContratoIds.contains(pet.idPet);
          print(
              '   ${pet.nome} (ID: ${pet.idPet}) - ${disponivel ? '✅ DISPONÍVEL' : '❌ JÁ NO CONTRATO'}');
          return disponivel;
        }).toList();

        setState(() {
          _petsDisponiveis = petsDisponiveis;
          _carregando = false;
        });

        print('🎯 Pets disponíveis para adicionar: ${_petsDisponiveis.length}');
      } else {
        throw Exception('Erro ao carregar pets: Status ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      print('❌ Erro ao carregar pets: $e');
      print('📝 Stack trace: $stackTrace');

      setState(() {
        _carregando = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar pets: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  // No AddPetModal, método _adicionarPets:
  Future<void> _adicionarPets() async {
    if (_petsSelecionados.isEmpty) {
      _mostrarMensagem('Selecione pelo menos um pet');
      return;
    }

    setState(() => _enviando = true);

    try {
      print('➕ Adicionando pets ao contrato: $_petsSelecionados');
      final contratoAtualizado = await _contratoService.adicionarPetContrato(
        idContrato: widget.idContrato,
        pets: _petsSelecionados,
      );

      print('✅ Pets adicionados com sucesso!');

      // Atualizar o contrato na tela pai
      widget.onPetAdicionado(contratoAtualizado);

      if (mounted) {
        // Fecha o modal
        Navigator.of(context).pop();

        // Mostra mensagem de sucesso
        _mostrarMensagemSucesso('Pet(s) adicionado(s) com sucesso!');
      }
    } catch (e, stackTrace) {
      print('❌ Erro ao adicionar pets: $e');
      print('📝 Stack trace: $stackTrace');
      _mostrarErro('Erro ao adicionar pets: $e');
    } finally {
      if (mounted) {
        setState(() => _enviando = false);
      }
    }
  }

  void _abrirNovoModalAtualizado(ContratoModel contratoAtualizado) {
    // Adicionar um pequeno delay para garantir que o modal anterior foi fechado
    Future.delayed(Duration(milliseconds: 300), () {
      if (!mounted) return;

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => AddPetModal(
          idContrato: widget.idContrato,
          idUsuario: widget.idUsuario,
          petsNoContrato:
              contratoAtualizado.pets ?? [], // Usar a lista ATUALIZADA
          onPetAdicionado: widget.onPetAdicionado,
        ),
      );
    });
  }

  void _mostrarMensagem(String mensagem) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _mostrarMensagemSucesso(String mensagem) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _mostrarErro(String mensagem) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }

  Widget _buildItemPet(PetModel pet) {
    final selecionado = _petsSelecionados.contains(pet.idPet);
    final racaExibida =
        pet.descricaoRaca ?? pet.descricaoRaca ?? 'Raça não informada';

    return GestureDetector(
      onTap: () {
        setState(() {
          if (selecionado) {
            _petsSelecionados.remove(pet.idPet);
          } else {
            _petsSelecionados.add(pet.idPet!);
          }
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:
              selecionado ? Color(0xff8692DE).withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selecionado ? Color(0xff8692DE) : Colors.grey[300]!,
            width: selecionado ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar do pet
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xff8692DE).withOpacity(0.2),
              ),
              child: Icon(
                Icons.pets,
                color: Color(0xff8692DE),
                size: 30,
              ),
            ),

            SizedBox(width: 16),

            // Informações do pet
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pet.nome ?? 'Nome não informado',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    racaExibida,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            // Checkbox
            Checkbox(
              value: selecionado,
              onChanged: (value) {
                setState(() {
                  if (value == true) {
                    _petsSelecionados.add(pet.idPet!);
                  } else {
                    _petsSelecionados.remove(pet.idPet);
                  }
                });
              },
              activeColor: Color(0xff8692DE),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListaPets() {
    if (_carregando) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Color(0xff8692DE),
            ),
            SizedBox(height: 16),
            Text(
              'Carregando pets...',
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    if (_petsDisponiveis.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pets_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              'Todos os seus pets já estão incluídos!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'Não há mais pets disponíveis para adicionar.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 20),
      itemCount: _petsDisponiveis.length,
      itemBuilder: (context, index) => _buildItemPet(_petsDisponiveis[index]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Container(
          color: Colors.black.withOpacity(0.5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Modal content
              Container(
                height: MediaQuery.of(context).size.height * 0.85,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    // Header com drag handle
                    Container(
                      padding: EdgeInsets.only(top: 12, bottom: 8),
                      child: Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),

                    // Título e botão fechar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Adicionar Pets',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xff8692DE),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: Icon(Icons.close, size: 24),
                            color: Colors.grey[600],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 16),

                    // Contador de selecionados
                    if (_petsSelecionados.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Color(0xff8692DE).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Color(0xff8692DE).withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: Color(0xff8692DE),
                                size: 18,
                              ),
                              SizedBox(width: 8),
                              Text(
                                '${_petsSelecionados.length} pet(s) selecionado(s)',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xff8692DE),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    SizedBox(height: 16),

                    // Lista de pets (Expandida para ocupar espaço)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _buildListaPets(),
                      ),
                    ),

                    // Botões (sempre na parte inferior)
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: Offset(0, -2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          AppButton(
                            onPressed: _enviando || _petsSelecionados.isEmpty
                                ? null
                                : _adicionarPets,
                            label:
                                _enviando ? 'Adicionando...' : 'Adicionar Pets',
                            fontSize: 16,
                            padding: EdgeInsets.symmetric(vertical: 16),
                            buttonColor: _petsSelecionados.isEmpty
                                ? Colors.grey[300]
                                : Color(0xff8692DE),
                            textButtonColor: _petsSelecionados.isEmpty
                                ? Colors.grey[600]
                                : Colors.white,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          SizedBox(height: 12),
                          AppButton(
                            onPressed: _enviando
                                ? null
                                : () => Navigator.of(context).pop(),
                            label: 'Cancelar',
                            fontSize: 16,
                            padding: EdgeInsets.symmetric(vertical: 16),
                            buttonColor: Colors.white,
                            textButtonColor: Colors.black,
                            borderSide: BorderSide(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
