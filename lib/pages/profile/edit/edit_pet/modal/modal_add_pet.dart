import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pet_family_app/models/pet/especie_model.dart';
import 'package:pet_family_app/models/pet/raca_model.dart';
import 'package:pet_family_app/models/pet/porte_model.dart';
import 'package:pet_family_app/providers/pet/especie_provider.dart';
import 'package:pet_family_app/providers/pet/raca_provider.dart';
import 'package:pet_family_app/providers/pet/porte_provider.dart';
import 'package:pet_family_app/widgets/app_button.dart';
import 'package:pet_family_app/widgets/app_text_field.dart';
import 'package:pet_family_app/widgets/app_drop_down.dart';

class ModalAddPet extends StatefulWidget {
  final int idUsuario;
  final Function(Map<String, dynamic>)? onPetAdded;

  const ModalAddPet({super.key, required this.idUsuario, this.onPetAdded});

  @override
  State<ModalAddPet> createState() => _ModalAddPetState();
}

class _ModalAddPetState extends State<ModalAddPet> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomeController = TextEditingController();

  Especie? _selectedEspecie;
  Raca? _selectedRaca;
  Porte? _selectedPorte;
  String _selectedSexo = 'M';

  bool _isLoading = true;
  String? _errorMessage;
  bool _dadosCarregados = false;

  @override
  void initState() {
    super.initState();
    print('ModalAddPet: initState chamado');
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    print('ModalAddPet: _carregarDados iniciado');
    
    try {
      final especieProvider = Provider.of<EspecieProvider>(context, listen: false);
      final racaProvider = Provider.of<RacaProvider>(context, listen: false);
      final porteProvider = Provider.of<PorteProvider>(context, listen: false);

      print('ModalAddPet: Providers obtidos');

      // Verifica se já estão carregados para evitar chamadas desnecessárias
      bool precisaCarregar = false;

      if (!especieProvider.hasLoaded && !especieProvider.isLoading) {
        print('ModalAddPet: Carregando espécies...');
        precisaCarregar = true;
        await especieProvider.loadEspecies();
        print('ModalAddPet: Espécies carregadas - ${especieProvider.especies.length} itens');
      }

      if (!racaProvider.hasLoaded && !racaProvider.isLoading) {
        print('ModalAddPet: Carregando raças...');
        precisaCarregar = true;
        await racaProvider.loadRacas();
        print('ModalAddPet: Raças carregadas - ${racaProvider.racas.length} itens');
      }

      if (!porteProvider.hasLoaded && !porteProvider.isLoading) {
        print('ModalAddPet: Carregando portes...');
        precisaCarregar = true;
        await porteProvider.loadPortes();
        print('ModalAddPet: Portes carregados - ${porteProvider.portes.length} itens');
      }

      if (mounted) {
        print('ModalAddPet: Dados carregados com sucesso, atualizando estado...');
        setState(() {
          _isLoading = false;
          _dadosCarregados = true;
        });
      }

    } catch (e) {
      print('ModalAddPet: Erro ao carregar dados: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  void dispose() {
    print('ModalAddPet: dispose chamado');
    _nomeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('ModalAddPet: build chamado - isLoading: $_isLoading, error: $_errorMessage');
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Adicionar Pet',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),

            if (_isLoading) _buildLoading(),
            if (_errorMessage != null) _buildError(_errorMessage!),
            if (!_isLoading && _errorMessage == null) _buildContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildLoading() {
    print('ModalAddPet: Mostrando loading...');
    return Container(
      height: 200,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Carregando dados...',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(String error) {
    return Container(
      height: 200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            const Text(
              'Erro ao carregar dados',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                error.length > 100 ? '${error.substring(0, 100)}...' : error,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _errorMessage = null;
                });
                _carregarDados();
              },
              child: const Text('Tentar Novamente'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    print('ModalAddPet: Mostrando conteúdo...');
    return Form(
      key: _formKey,
      child: Column(
        children: [
          AppTextField(
            controller: _nomeController,
            labelText: 'Nome do Pet',
            hintText: 'Digite o nome do seu pet',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, digite o nome do pet';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Dropdown para Espécie
          Consumer<EspecieProvider>(
            builder: (context, especieProvider, child) {
              print('ModalAddPet: Consumer Espécie - isLoading: ${especieProvider.isLoading}, count: ${especieProvider.especies.length}');
              
              if (especieProvider.isLoading && especieProvider.especies.isEmpty) {
                return _buildDropdownLoading('Espécie');
              }
              
              return AppDropDown<Especie>(
                value: _selectedEspecie,
                items: especieProvider.especies,
                label: 'Espécie',
                hint: 'Selecione uma espécie',
                isRequired: true,
                errorMessage: 'Selecione uma espécie',
                onChanged: (Especie? newEspecie) {
                  setState(() {
                    _selectedEspecie = newEspecie;
                  });
                },
                itemText: (especie) => especie.descricao,
              );
            },
          ),

          const SizedBox(height: 16),

          // Dropdown para Raça
          Consumer<RacaProvider>(
            builder: (context, racaProvider, child) {
              print('ModalAddPet: Consumer Raça - isLoading: ${racaProvider.isLoading}, count: ${racaProvider.racas.length}');
              
              if (racaProvider.isLoading && racaProvider.racas.isEmpty) {
                return _buildDropdownLoading('Raça');
              }

              return AppDropDown<Raca>(
                value: _selectedRaca,
                items: racaProvider.racas,
                label: 'Raça',
                hint: 'Selecione uma raça',
                isRequired: true,
                errorMessage: 'Selecione uma raça',
                onChanged: (Raca? newRaca) {
                  setState(() {
                    _selectedRaca = newRaca;
                  });
                },
                itemText: (raca) => raca.descricao,
              );
            },
          ),

          const SizedBox(height: 16),

          // Dropdown para Sexo
          AppDropDown<String>(
            value: _selectedSexo,
            items: const ['M', 'F'],
            label: 'Sexo',
            hint: 'Selecione o sexo',
            isRequired: true,
            errorMessage: 'Selecione o sexo',
            onChanged: (String? newSexo) {
              setState(() {
                _selectedSexo = newSexo!;
              });
            },
            itemText: (sexo) => sexo == 'M' ? 'Macho' : 'Fêmea',
          ),

          const SizedBox(height: 16),

          // Dropdown para Porte
          Consumer<PorteProvider>(
            builder: (context, porteProvider, child) {
              print('ModalAddPet: Consumer Porte - isLoading: ${porteProvider.isLoading}, count: ${porteProvider.portes.length}');
              
              if (porteProvider.isLoading && porteProvider.portes.isEmpty) {
                return _buildDropdownLoading('Porte');
              }

              return AppDropDown<Porte>(
                value: _selectedPorte,
                items: porteProvider.portes,
                label: 'Porte',
                hint: 'Selecione um porte',
                isRequired: true,
                errorMessage: 'Selecione um porte',
                onChanged: (Porte? newPorte) {
                  setState(() {
                    _selectedPorte = newPorte;
                  });
                },
                itemText: (porte) => porte.descricao,
              );
            },
          ),

          const SizedBox(height: 20),

          // Botão para adicionar
          AppButton(
            onPressed: _adicionarPet,
            label: 'Adicionar Pet',
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownLoading(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w300,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFCCCCCC)),
            borderRadius: BorderRadius.circular(50),
          ),
          child: Row(
            children: [
              const SizedBox(width: 8),
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 12),
              Text(
                'Carregando $label...',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _adicionarPet() {
    if (_formKey.currentState!.validate()) {
      if (_selectedEspecie == null ||
          _selectedRaca == null ||
          _selectedPorte == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor, preencha todos os campos obrigatórios'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final novoPet = {
        'nome': _nomeController.text.trim(),
        'sexo': _selectedSexo,
        'idusuario': widget.idUsuario,
        'idespecie': _selectedEspecie!.idEspecie,
        'idraca': _selectedRaca!.idRaca,
        'idporte': _selectedPorte!.idPorte,
      };

      Navigator.of(context).pop();
      widget.onPetAdded?.call(novoPet);
    }
  }
}