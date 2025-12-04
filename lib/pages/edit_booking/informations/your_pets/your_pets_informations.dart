import 'package:flutter/material.dart';
import 'package:pet_family_app/models/contrato_model.dart';
import 'package:pet_family_app/models/pet/pet_model.dart';
import 'package:pet_family_app/pages/edit_booking/informations/title_information_template.dart';
import 'package:pet_family_app/pages/edit_booking/informations/your_pets/pets_booking_template.dart';
import 'package:pet_family_app/services/contrato_service.dart';
import 'package:pet_family_app/repository/contrato_repository.dart';
import 'package:dio/dio.dart';

class YourPetsInformations extends StatefulWidget {
  final ContratoModel contrato;
  final Function(ContratoModel, {String? tipoAlteracao})? onContratoAtualizado;
  final bool editavel;
  final VoidCallback? onPetsAtualizados; // NOVO: Callback para notificar mudanças

  const YourPetsInformations({
    super.key,
    required this.contrato,
    this.onContratoAtualizado,
    this.editavel = false,
    this.onPetsAtualizados, // NOVO
  });

  @override
  State<YourPetsInformations> createState() => _YourPetsInformationsState();
}

class _YourPetsInformationsState extends State<YourPetsInformations> {
  bool _carregando = false;
  late ContratoService _contratoService;
  late ContratoRepository _contratoRepository;
  List<dynamic> _petsAtuais = []; // NOVO: Armazena cópia local dos pets

  @override
  void initState() {
    super.initState();
    _inicializarServicos();
    _carregarPetsLocais(); // NOVO: Carrega pets locais
  }

  void _inicializarServicos() {
    _contratoService = ContratoService(dio: Dio());
    _contratoRepository = ContratoRepositoryImpl(contratoService: _contratoService);
  }

  // NOVO: Carrega pets para cópia local
  void _carregarPetsLocais() {
    _petsAtuais = List.from(widget.contrato.pets ?? []);
    print('📦 Pets carregados localmente: ${_petsAtuais.length}');
  }

  // Método auxiliar para extrair ID do pet
  int? _extrairIdPet(dynamic pet) {
    if (pet == null) return null;
    
    if (pet is Map<String, dynamic>) {
      // Tenta todas as possíveis chaves de ID
      int? id;
      
      if (pet['idPet'] != null) {
        id = pet['idPet'] is int ? pet['idPet'] : int.tryParse(pet['idPet'].toString());
      } else if (pet['id'] != null) {
        id = pet['id'] is int ? pet['id'] : int.tryParse(pet['id'].toString());
      } else if (pet['idpet'] != null) {
        id = pet['idpet'] is int ? pet['idpet'] : int.tryParse(pet['idpet'].toString());
      } else if (pet['petId'] != null) {
        id = pet['petId'] is int ? pet['petId'] : int.tryParse(pet['petId'].toString());
      }
      
      return id;
    } else if (pet is PetModel) {
      return pet.idPet;
    }
    
    return null;
  }

  // Método auxiliar para extrair nome do pet
  String _extrairNomePet(dynamic pet) {
    if (pet == null) return 'Pet';
    
    if (pet is Map<String, dynamic>) {
      return pet['nome'] ?? 
             pet['petName'] ?? 
             pet['name'] ??
             (pet['pet'] is Map<String, dynamic> ? pet['pet']['nome'] : null) ?? 
             'Pet';
    } else if (pet is PetModel) {
      return pet.nome ?? 'Pet';
    } else if (pet is String) {
      return pet;
    }
    
    return 'Pet';
  }

  // Método auxiliar para extrair espécie do pet
  String? _extrairEspeciePet(dynamic pet) {
    if (pet == null) return null;
    
    if (pet is Map<String, dynamic>) {
      return pet['especie'] ?? 
             pet['descricaoEspecie'] ?? 
             pet['especie_nome'] ??
             (pet['pet'] is Map<String, dynamic> ? pet['pet']['especie'] : null);
    } else if (pet is PetModel) {
      return pet.descricaoEspecie;
    }
    
    return null;
  }

  // NOVO: Método para forçar atualização da interface
  void _forcarAtualizacaoInterface() {
    if (mounted) {
      setState(() {
        // Força o rebuild do widget
        print('🔄 Forçando rebuild da interface');
      });
      
      // Notifica o parent sobre a atualização
      if (widget.onPetsAtualizados != null) {
        widget.onPetsAtualizados!();
      }
    }
  }

  Future<void> _removerPet(int index) async {
    if (!widget.editavel || _carregando) return;

    if (index >= _petsAtuais.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Índice do pet inválido'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final petParaRemover = _petsAtuais[index];
    final idPet = _extrairIdPet(petParaRemover);
    final nomePet = _extrairNomePet(petParaRemover);

    if (idPet == null) {
      print('❌ ID do pet não encontrado para remoção');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro: ID do pet não encontrado'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _carregando = true;
    });

    try {
      print('🗑️ Removendo pet ID: $idPet ($nomePet) do contrato ${widget.contrato.idContrato}');

      // Chama a API para remover o pet do contrato
      final resultado = await _contratoRepository.removerPetContrato(
        idContrato: widget.contrato.idContrato!,
        idPet: idPet,
      );

      print('✅ Resposta da API: $resultado');

      // Verifica se a remoção foi bem sucedida
      final sucesso = resultado['success'] == true || 
                     resultado['status'] == 'success' ||
                     resultado['status'] == 200 ||
                     resultado['message']?.toString().toLowerCase().contains('sucesso') == true;

      if (sucesso) {
        print('✅ Pet removido com sucesso na API');

        // Remove o pet da lista local
        _petsAtuais.removeAt(index);
        print('📊 Pets restantes: ${_petsAtuais.length}');

        // Cria uma cópia atualizada do contrato
        final contratoAtualizado = widget.contrato.copyWith(
          pets: _petsAtuais.isEmpty ? null : List.from(_petsAtuais),
        );

        // Atualiza a interface IMEDIATAMENTE
        _forcarAtualizacaoInterface();

        // Notifica o parent sobre a atualização
        if (widget.onContratoAtualizado != null) {
          widget.onContratoAtualizado!(
            contratoAtualizado,
            tipoAlteracao: 'pet_removido',
          );
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pet "$nomePet" removido com sucesso'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      } else {
        throw Exception('Falha ao remover pet na API: ${resultado['message'] ?? 'Erro desconhecido'}');
      }
    } catch (e) {
      print('❌ Erro ao remover pet: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao remover pet: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'Tentar novamente',
            onPressed: () => _removerPet(index),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _carregando = false;
        });
      }
    }
  }

  void _confirmarRemocaoPet(int index) {
    if (index >= _petsAtuais.length) return;

    final pet = _petsAtuais[index];
    final nomePet = _extrairNomePet(pet);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Remover Pet",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(
            "Tem certeza que deseja remover o pet \"$nomePet\" da hospedagem?",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                "Cancelar",
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _removerPet(index);
              },
              child: _carregando
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(
                      "Remover",
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }

  void _adicionarPet() {
    if (!widget.editavel || _carregando) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funcionalidade de adicionar pet em desenvolvimento'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _debugPets() {
    print('\n🔍=== DEBUG PETS CONTRATO ${widget.contrato.idContrato} ===');
    print('📊 Total de pets: ${_petsAtuais.length}');
    
    for (int i = 0; i < _petsAtuais.length; i++) {
      final pet = _petsAtuais[i];
      print('\nPet $i:');
      print('  Tipo: ${pet.runtimeType}');
      
      if (pet is Map<String, dynamic>) {
        print('  Chaves: ${pet.keys.toList()}');
      } else if (pet is PetModel) {
        print('  idPet: ${pet.idPet}');
        print('  nome: ${pet.nome}');
      }
      
      final id = _extrairIdPet(pet);
      print('  ID extraído: $id');
    }
    print('=== FIM DEBUG ===\n');
  }

  @override
  Widget build(BuildContext context) {
    final bool temPets = _petsAtuais.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
          ],
        ),
        const SizedBox(height: 16),
        if (_carregando) ...[
          const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 8),
                  Text(
                    'Removendo pet...',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ] else if (temPets) ...[
          Column(
            children: _petsAtuais.asMap().entries.map((entry) {
              final int index = entry.key;
              final dynamic pet = entry.value;

              return PetsBookingTemplate(
                key: ValueKey('pet_${_extrairIdPet(pet) ?? index}'), // NOVO: Key única para cada pet
                name: _extrairNomePet(pet),
                especie: _extrairEspeciePet(pet),
                onRemover:
                    widget.editavel ? () => _confirmarRemocaoPet(index) : null,
                mostrarBotaoRemover: widget.editavel,
              );
            }).toList(),
          ),
        ] else ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: const Text(
              'Nenhum pet incluído',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ],
    );
  }
}