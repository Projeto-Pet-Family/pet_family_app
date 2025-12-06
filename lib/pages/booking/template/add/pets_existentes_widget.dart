// widgets/pets_existentes_widget.dart

import 'package:flutter/material.dart';
import 'package:pet_family_app/models/pets_existentes_model.dart';
import 'package:pet_family_app/services/contrato_service.dart';

class PetsExistentesWidget extends StatefulWidget {
  final int idContrato;
  final ContratoService contratoService;

  const PetsExistentesWidget({
    super.key,
    required this.idContrato,
    required this.contratoService,
  });

  @override
  State<PetsExistentesWidget> createState() => _PetsExistentesWidgetState();
}

class _PetsExistentesWidgetState extends State<PetsExistentesWidget> {
  late Future<Map<String, dynamic>> _petsFuture;
  bool _carregando = true;
  PetExistenteModel? _dadosPets;

  @override
  void initState() {
    super.initState();
    _carregarPetsExistentes();
  }

  Future<void> _carregarPetsExistentes() async {
    setState(() {
      _carregando = true;
    });

    try {
      final dados = await widget.contratoService
          .lerPetsExistentesContrato(widget.idContrato);
      final model = PetExistenteModel.fromJson(dados);

      setState(() {
        _dadosPets = model;
        _carregando = false;
      });
    } catch (e) {
      print('❌ Erro ao carregar pets existentes: $e');
      setState(() {
        _carregando = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar pets: $e'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Widget _buildCardInfo(String titulo, String valor, IconData icone) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(icone, size: 20, color: Color(0xff8692DE)),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  valor,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPetItem(PetInfo pet) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: pet.estaNoContrato ? Colors.green : Colors.orange,
          width: 1,
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
              color: pet.estaNoContrato
                  ? Colors.green.withOpacity(0.2)
                  : Colors.orange.withOpacity(0.2),
            ),
            child: Icon(
              Icons.pets,
              color: pet.estaNoContrato ? Colors.green : Colors.orange,
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
                  pet.nome,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  pet.sexo,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          // Status
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: pet.estaNoContrato
                  ? Colors.green.withOpacity(0.1)
                  : Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: pet.estaNoContrato ? Colors.green : Colors.orange,
                width: 1,
              ),
            ),
            child: Text(
              pet.statusNoContrato,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: pet.estaNoContrato ? Colors.green : Colors.orange,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEstatisticas() {
    if (_dadosPets == null) return SizedBox.shrink();

    final totalPets = _dadosPets!.pets.length;
    final noContrato = _dadosPets!.pets.where((p) => p.estaNoContrato).length;
    final foraContrato = totalPets - noContrato;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              Text(
                'Total',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                '$totalPets',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          Column(
            children: [
              Text(
                'No Contrato',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                '$noContrato',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          Column(
            children: [
              Text(
                'Fora',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                '$foraContrato',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_carregando) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: Color(0xff8692DE),
              ),
              SizedBox(height: 16),
              Text(
                'Carregando pets do contrato...',
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_dadosPets == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 60,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              'Erro ao carregar dados',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: _carregarPetsExistentes,
              child: Text('Tentar novamente'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xff8692DE),
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Informações do contrato
          Text(
            'Contrato #${_dadosPets!.idContrato}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xff8692DE),
            ),
          ),
          SizedBox(height: 20),

          // Informações da hospedagem
          Text(
            'Hospedagem',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _dadosPets!.hospedagem.nome,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  _dadosPets!.hospedagem.endereco,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Tel: ${_dadosPets!.hospedagem.telefone}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),

          // Informações do tutor
          Text(
            'Tutor',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _dadosPets!.usuario.nome,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  _dadosPets!.usuario.email,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),

          // Estatísticas
          Text(
            'Resumo',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8),
          _buildEstatisticas(),
          SizedBox(height: 20),

          // Lista de pets
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pets do Tutor',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              Text(
                'Total: ${_dadosPets!.pets.length}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),

          if (_dadosPets!.pets.isEmpty)
            Container(
              padding: EdgeInsets.all(40),
              child: Column(
                children: [
                  Icon(
                    Icons.pets_outlined,
                    size: 60,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Nenhum pet encontrado',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
          else
            ..._dadosPets!.pets.map(_buildPetItem).toList(),

          SizedBox(height: 20),

          // Botão de recarregar
          Center(
            child: ElevatedButton.icon(
              onPressed: _carregarPetsExistentes,
              icon: Icon(Icons.refresh, size: 20),
              label: Text('Atualizar lista'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Color(0xff8692DE),
                side: BorderSide(color: Color(0xff8692DE)),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}