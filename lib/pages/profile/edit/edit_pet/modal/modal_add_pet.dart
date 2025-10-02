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

  // Controllers para os dropdowns
  Especie? _selectedEspecie;
  Raca? _selectedRaca;
  Porte? _selectedPorte;
  String _selectedSexo = 'M';

  // Future para controlar o carregamento dos dados
  late Future<List<dynamic>> _dadosFuture;
  bool _isMounted = true;

  @override
  void initState() {
    super.initState();
    _dadosFuture = _carregarDados();
  }

  Future<List<dynamic>> _carregarDados() async {
    if (!_isMounted) return [];

    try {
      final especieProvider = Provider.of<EspecieProvider>(context, listen: false);
      final racaProvider = Provider.of<RacaProvider>(context, listen: false);
      final porteProvider = Provider.of<PorteProvider>(context, listen: false);

      // Carrega apenas se ainda não foram carregados
      if (!especieProvider.hasLoaded) {
        await especieProvider.loadEspecies();
      }
      if (!racaProvider.hasLoaded) {
        await racaProvider.loadRacas();
      }
      if (!porteProvider.hasLoaded) {
        await porteProvider.loadPortes();
      }

      if (!_isMounted) return [];
      
      return [true]; // Retorna sucesso
    } catch (e) {
      if (!_isMounted) return [];
      return [false, e.toString()]; // Retorna erro
    }
  }

  @override
  void dispose() {
    _isMounted = false;
    _nomeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: _dadosFuture,
      builder: (context, snapshot) {
        // Mostra loading enquanto carrega
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoading();
        }

        // Mostra erro se ocorreu
        if (snapshot.hasError || (snapshot.data != null && snapshot.data!.length > 1)) {
          return _buildError(snapshot.error?.toString() ?? snapshot.data?[1] ?? 'Erro desconhecido');
        }

        // Conteúdo principal quando os dados estão carregados
        return _buildContent();
      },
    );
  }

  Widget _buildLoading() {
    return Container(
      padding: const EdgeInsets.all(16),
      height: 300,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
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
      padding: const EdgeInsets.all(16),
      height: 300,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
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
                  _dadosFuture = _carregarDados();
                });
              },
              child: const Text('Tentar Novamente'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
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
            Form(
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

                  // Dropdown para Raça (agora normal, sem filtragem)
                  Consumer<RacaProvider>(
                    builder: (context, racaProvider, child) {
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
            ),
            const SizedBox(height: 20),
          ],
        ),
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

      // Fecha o modal e retorna os dados do pet
      Navigator.of(context).pop();
      widget.onPetAdded?.call(novoPet);
    }
  }
}