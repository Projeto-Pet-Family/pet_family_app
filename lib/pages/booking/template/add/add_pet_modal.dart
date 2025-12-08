// pages/edit_booking/modal/add_pet_modal.dart
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:pet_family_app/models/pet/pet_model.dart';
import 'package:pet_family_app/services/contrato_service.dart';
import 'package:pet_family_app/widgets/app_button.dart';
import 'package:pet_family_app/models/contrato_model.dart';

class AddPetModal extends StatefulWidget {
  final int idContrato;
  final int idUsuario;
  final List<dynamic> petsNoContrato;
  final Function(ContratoModel) onPetAdicionado;
  final int? idServicoSelecionado;
  final List<dynamic>? petsComServico;

  const AddPetModal({
    super.key,
    required this.idContrato,
    required this.idUsuario,
    required this.petsNoContrato,
    required this.onPetAdicionado,
    this.idServicoSelecionado,
    this.petsComServico,
  });

  @override
  State<AddPetModal> createState() => _AddPetModalState();
}

class _AddPetModalState extends State<AddPetModal> {
  late ContratoService _contratoService;
  List<PetModel> _petsDoContrato = []; // Alterado: Agora são pets DO CONTRATO
  final List<int> _petsSelecionados = [];
  bool _carregando = true;
  bool _enviando = false;

  // Mapa para rastrear quais pets já têm o serviço
  final Map<int, bool> _petsComServico = {};
  final List<int> _petsDesabilitados = [];

  @override
  void initState() {
    super.initState();
    final dio = Dio();
    _contratoService = ContratoService(dio);
    _carregarPetsDoContrato(); // Alterado para carregar pets DO CONTRATO
  }

  String _getTitulo() {
    if (widget.idServicoSelecionado != null) {
      return 'Adicionar Serviço aos Pets do Contrato';
    }
    return 'Selecionar Pets do Contrato';
  }

  Future<void> _carregarPetsDoContrato() async {
    try {
      final dio = Dio();

      print('🔄 Buscando pets DO CONTRATO ${widget.idContrato}');

      // USAR A ROTA CORRETA: Buscar pets que já estão no contrato
      final response = await dio.get(
        'https://bepetfamily.onrender.com/contrato/${widget.idContrato}/lerPetsExistentesContrato',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      print('📡 Status da resposta: ${response.statusCode}');
      print('📦 Dados recebidos: ${response.data}');

      if (response.statusCode == 200) {
        List<dynamic> petsList = [];

        // Processar a resposta baseado na estrutura esperada
        if (response.data is List) {
          petsList = response.data;
        } else if (response.data is Map) {
          final Map<String, dynamic> responseMap = response.data;
          
          // Verificar diferentes estruturas possíveis
          if (responseMap.containsKey('data')) {
            final data = responseMap['data'];
            if (data is List) {
              petsList = data;
            } else if (data is Map && data.containsKey('pets')) {
              petsList = data['pets'] ?? [];
            }
          } else if (responseMap.containsKey('pets')) {
            petsList = responseMap['pets'] ?? [];
          } else {
            // Se não encontrar estrutura conhecida, usar o próprio response.data
            // (pode ser uma lista de pets)
            if (responseMap.keys.every((key) => int.tryParse(key) != null)) {
              // Se todas as keys são números (índices), é uma lista em forma de mapa
              petsList = responseMap.values.toList();
            }
          }
        }

        print('📊 Total de pets no contrato: ${petsList.length}');

        // Converter para PetModel
        final petsContrato = petsList.map<PetModel>((petJson) {
          if (petJson is! Map) {
            print('⚠️ Pet não é um Map: $petJson');
            return PetModel(
              idPet: 0,
              nome: 'Pet inválido',
              sexo: 'Não informado',
              descricaoRaca: 'Não informada',
            );
          }

          // Extrair ID do pet
          final dynamic id = petJson['idpet'] ?? petJson['idPet'] ?? petJson['id'];
          final int petId = id is int ? id : (id is String ? int.tryParse(id) ?? 0 : 0);

          // Extrair serviços do pet (se existirem)
          final servicos = petJson['servicos'] ?? petJson['servico'] ?? [];

          print('🐕 Pet ID $petId - Nome: ${petJson['nome']} - Tem serviços: ${servicos is List ? servicos.length : 0}');

          return PetModel(
            idPet: petId,
            nome: petJson['nome'] ?? 'Pet sem nome',
            sexo: petJson['sexo'] ?? 'Não informado',
            descricaoRaca: petJson['descricaoRaca'] ?? petJson['raca'] ?? 'Não informada',
            servicos: servicos is List ? servicos : [], // Adicionar serviços ao modelo
          );
        }).toList();

        // Se temos um serviço específico para adicionar, filtrar pets que NÃO têm este serviço
        List<PetModel> petsFiltrados = petsContrato;
        
        if (widget.idServicoSelecionado != null) {
          print('🔍 Filtrando pets que NÃO têm o serviço ${widget.idServicoSelecionado}');
          
          petsFiltrados = petsContrato.where((pet) {
            // Verificar se o pet tem o serviço
            bool temServico = false;
            
            if (pet.servicos != null && pet.servicos is List) {
              final servicosList = pet.servicos as List;
              temServico = servicosList.any((servico) {
                final dynamic servicoId = servico is Map
                    ? servico['idservico'] ?? servico['idServico'] ?? servico
                    : servico;
                return servicoId == widget.idServicoSelecionado;
              });
            }
            
            if (temServico) {
              print('⚠️ Pet ${pet.nome} (ID: ${pet.idPet}) JÁ TEM o serviço');
              _petsComServico[pet.idPet!] = true;
              _petsDesabilitados.add(pet.idPet!);
            }
            
            return !temServico; // Manter apenas os que NÃO têm o serviço
          }).toList();
          
          print('✅ Pets disponíveis (sem o serviço): ${petsFiltrados.length}');
          print('🚫 Pets que já têm o serviço: ${_petsDesabilitados.length}');
        }

        setState(() {
          _petsDoContrato = petsFiltrados;
          _carregando = false;
        });

      } else {
        throw Exception('Erro ao carregar pets do contrato: Status ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      print('❌ Erro ao carregar pets do contrato: $e');
      print('📝 Stack trace: $stackTrace');

      // Tentar fallback: usar os pets passados via widget
      print('🔄 Tentando usar pets passados via widget...');
      _usarPetsPassadosComoFallback();

      setState(() {
        _carregando = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar pets: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  // Fallback: Usar pets passados via widget
  void _usarPetsPassadosComoFallback() {
    try {
      print('📊 Usando ${widget.petsNoContrato.length} pets do widget como fallback');
      
      final List<PetModel> petsFallback = [];
      
      for (var pet in widget.petsNoContrato) {
        if (pet is Map) {
          final dynamic id = pet['idpet'] ?? pet['idPet'] ?? pet['id'];
          final int petId = id is int ? id : (id is String ? int.tryParse(id) ?? 0 : 0);
          
          final servicos = pet['servicos'] ?? [];
          
          petsFallback.add(PetModel(
            idPet: petId,
            nome: pet['nome'] ?? 'Pet sem nome',
            sexo: pet['sexo'] ?? 'Não informado',
            descricaoRaca: pet['descricaoRaca'] ?? pet['raca'] ?? 'Não informada',
            servicos: servicos is List ? servicos : [],
          ));
        }
      }
      
      // Filtrar por serviço se necessário
      if (widget.idServicoSelecionado != null) {
        final petsFiltrados = petsFallback.where((pet) {
          bool temServico = false;
          
          if (pet.servicos != null && pet.servicos is List) {
            final servicosList = pet.servicos as List;
            temServico = servicosList.any((servico) {
              final dynamic servicoId = servico is Map
                  ? servico['idservico'] ?? servico['idServico'] ?? servico
                  : servico;
              return servicoId == widget.idServicoSelecionado;
            });
          }
          
          if (temServico) {
            _petsDesabilitados.add(pet.idPet!);
          }
          
          return !temServico;
        }).toList();
        
        setState(() {
          _petsDoContrato = petsFiltrados;
        });
      } else {
        setState(() {
          _petsDoContrato = petsFallback;
        });
      }
      
    } catch (e) {
      print('❌ Erro no fallback: $e');
      setState(() {
        _petsDoContrato = [];
      });
    }
  }

  Future<void> _adicionarPets() async {
    if (_petsSelecionados.isEmpty) {
      _mostrarMensagem('Selecione pelo menos um pet');
      return;
    }

    setState(() => _enviando = true);

    try {
      print('➕ Adicionando pets ao contrato: $_petsSelecionados');

      if (widget.idServicoSelecionado != null) {
        // Adicionar pets COM o serviço específico
        await _adicionarPetsComServico();
      } else {
        // Adicionar apenas os pets (sem serviço)
        final contratoAtualizado = await _contratoService.adicionarPetContrato(
          idContrato: widget.idContrato,
          pets: _petsSelecionados,
        );

        print('✅ Pets adicionados com sucesso!');
        widget.onPetAdicionado(contratoAtualizado);
      }

      if (mounted) {
        Navigator.of(context).pop();
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

  Future<void> _adicionarPetsComServico() async {
    try {
      print('➕ Adicionando serviço ${widget.idServicoSelecionado} aos pets: $_petsSelecionados');

      // Formatar os dados para a API
      final servicosPorPet = _petsSelecionados.map((idPet) {
        return {
          'idPet': idPet,
          'servicos': [widget.idServicoSelecionado],
        };
      }).toList();

      print('📦 Dados enviados: $servicosPorPet');

      // Chamar a API para adicionar serviços
      await _contratoService.adicionarServicoContrato(
        idContrato: widget.idContrato,
        servicosPorPet: servicosPorPet,
      );

      // Buscar o contrato atualizado
      final contratoAtualizado = await _contratoService.buscarContratoPorId(widget.idContrato);

      print('✅ Serviço adicionado aos pets com sucesso!');
      widget.onPetAdicionado(contratoAtualizado);
    } catch (e) {
      print('❌ Erro ao adicionar serviço aos pets: $e');
      rethrow;
    }
  }

  Widget _buildHeaderEspecifico() {
    if (widget.idServicoSelecionado != null) {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.blue[700],
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Adicionar serviço aos pets do contrato',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.blue[700],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Apenas pets que ainda não possuem este serviço serão mostrados',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      );
    }
    return const SizedBox();
  }

  bool _isPetDesabilitado(PetModel pet) {
    return _petsDesabilitados.contains(pet.idPet);
  }

  Widget _buildItemPet(PetModel pet) {
    final selecionado = _petsSelecionados.contains(pet.idPet);
    final racaExibida = pet.descricaoRaca ?? 'Raça não informada';
    final desabilitado = _isPetDesabilitado(pet);

    return GestureDetector(
      onTap: desabilitado
          ? null
          : () {
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
          color: desabilitado
              ? Colors.grey[100]
              : (selecionado
                  ? Color(0xff8692DE).withOpacity(0.1)
                  : Colors.white),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: desabilitado
                ? Colors.grey[300]!
                : (selecionado ? Color(0xff8692DE) : Colors.grey[300]!),
            width: selecionado ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
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
                color: desabilitado
                    ? Colors.grey[300]!
                    : Color(0xff8692DE).withOpacity(0.2),
              ),
              child: Icon(
                Icons.pets,
                color: desabilitado ? Colors.grey[500]! : Color(0xff8692DE),
                size: 30,
              ),
            ),

            const SizedBox(width: 16),

            // Informações do pet
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          pet.nome ?? 'Nome não informado',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: desabilitado
                                ? Colors.grey[500]
                                : Colors.black87,
                          ),
                        ),
                      ),
                      if (desabilitado)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange[50],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle,
                                size: 12,
                                color: Colors.orange[700],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Já tem',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.orange[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    racaExibida,
                    style: TextStyle(
                      fontSize: 14,
                      color: desabilitado ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  if (pet.servicos != null && (pet.servicos as List).isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Tem ${(pet.servicos as List).length} serviço(s)',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green[600],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Checkbox ou indicador de desabilitado
            if (desabilitado)
              Icon(
                Icons.block,
                color: Colors.grey[400],
                size: 24,
              )
            else
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
            const SizedBox(height: 16),
            Text(
              'Carregando pets do contrato...',
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    if (_petsDoContrato.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pets_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              widget.idServicoSelecionado != null
                  ? 'Todos os pets já têm este serviço!'
                  : 'Não há pets neste contrato',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              widget.idServicoSelecionado != null
                  ? 'Não há pets disponíveis para adicionar este serviço.'
                  : 'Adicione pets ao contrato primeiro.',
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

    return ListView(
      padding: const EdgeInsets.only(top: 8, bottom: 20),
      children: [
        if (widget.idServicoSelecionado != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'Pets do contrato (sem este serviço)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.green[700],
              ),
            ),
          ),
        ..._petsDoContrato.map((pet) => _buildItemPet(pet)).toList(),
      ],
    );
  }

  String _getBotaoPrincipal() {
    if (widget.idServicoSelecionado != null) {
      return _enviando ? 'Adicionando Serviço...' : 'Adicionar Serviço aos Pets Selecionados';
    }
    return _enviando ? 'Adicionando...' : 'Adicionar Pets Selecionados';
  }

  void _mostrarMensagem(String mensagem) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _mostrarMensagemSucesso(String mensagem) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _mostrarErro(String mensagem) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
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
              Container(
                height: MediaQuery.of(context).size.height * 0.85,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.only(top: 12, bottom: 8),
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

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _getTitulo(),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xff8692DE),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.close, size: 24),
                            color: Colors.grey[600],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    _buildHeaderEspecifico(),

                    if (_petsSelecionados.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Container(
                          padding: const EdgeInsets.all(12),
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
                              const SizedBox(width: 8),
                              Text(
                                '${_petsSelecionados.length} pet(s) selecionado(s)',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xff8692DE),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    const SizedBox(height: 16),

                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _buildListaPets(),
                      ),
                    ),

                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          AppButton(
                            onPressed: _enviando || _petsSelecionados.isEmpty
                                ? null
                                : _adicionarPets,
                            label: _getBotaoPrincipal(),
                            fontSize: 16,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            buttonColor: _petsSelecionados.isEmpty
                                ? Colors.grey[300]
                                : Color(0xff8692DE),
                            textButtonColor: _petsSelecionados.isEmpty
                                ? Colors.grey[600]
                                : Colors.white,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          const SizedBox(height: 12),
                          AppButton(
                            onPressed: _enviando
                                ? null
                                : () => Navigator.of(context).pop(),
                            label: 'Cancelar',
                            fontSize: 16,
                            padding: const EdgeInsets.symmetric(vertical: 16),
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