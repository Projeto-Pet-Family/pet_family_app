import 'package:flutter/material.dart';
import 'package:pet_family_app/models/pet/especie_model.dart';
import 'package:pet_family_app/models/pet/pet_model.dart';
import 'package:pet_family_app/models/pet/porte_model.dart';
import 'package:pet_family_app/models/pet/raca_model.dart';
import 'package:pet_family_app/providers/pet/especie_provider.dart';
import 'package:pet_family_app/providers/pet/porte_provider.dart';
import 'package:pet_family_app/providers/pet/raca_provider.dart';
import 'package:provider/provider.dart';
import 'package:pet_family_app/widgets/app_button.dart';
import 'package:pet_family_app/widgets/app_text_field.dart';
import 'package:pet_family_app/widgets/app_drop_down.dart';

class ModalEditPet extends StatefulWidget {
  final PetModel petData;
  final Function(PetModel)? onPetEdited;
  final Function()? onPetDeleted;

  const ModalEditPet({
    super.key,
    required this.petData,
    this.onPetEdited,
    this.onPetDeleted,
  });

  @override
  State<ModalEditPet> createState() => _ModalEditPetState();
}

class _ModalEditPetState extends State<ModalEditPet> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomeController = TextEditingController();

  EspecieModel? _selectedEspecie;
  RacaModel? _selectedRaca;
  PorteModel? _selectedPorte;
  String _selectedSexo = 'M';

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _carregarDados();
    });
  }

  Future<void> _carregarDados() async {
    try {
      final especieProvider =
          Provider.of<EspecieProvider>(context, listen: false);
      final racaProvider = Provider.of<RacaProvider>(context, listen: false);
      final porteProvider = Provider.of<PorteProvider>(context, listen: false);

      // Carrega os dados usando os novos métodos do provider
      await especieProvider.listarEspecies();
      await racaProvider.listarRacas();
      await porteProvider.listarPortes();

      if (mounted) {
        // Preenche os dados atuais do pet
        _preencherDadosAtuais(especieProvider, racaProvider, porteProvider);
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  void _preencherDadosAtuais(
    EspecieProvider especieProvider,
    RacaProvider racaProvider,
    PorteProvider porteProvider,
  ) {
    // Preenche o nome com fallback
    _nomeController.text = widget.petData.nome ?? 'Pet sem nome';

    // DEBUG: Verificar quais dados estão chegando
    print('🐶 Dados do pet recebidos:');
    print('   - ID: ${widget.petData.idPet}');
    print('   - Nome: ${widget.petData.nome}');
    print('   - Sexo: ${widget.petData.sexo}');
    print('   - Espécie ID: ${widget.petData.idEspecie}');
    print('   - Raça ID: ${widget.petData.idRaca}');
    print('   - Porte ID: ${widget.petData.idPorte}');

    // Preenche a espécie com fallback
    _selectedEspecie = _findEspecie(especieProvider, widget.petData.idEspecie);

    // Preenche a raça com fallback
    _selectedRaca = _findRaca(racaProvider, widget.petData.idRaca);

    // Preenche o porte com fallback (pode ser null)
    _selectedPorte = _findPorte(porteProvider, widget.petData.idPorte);

    // Preenche o sexo com fallback para 'M'
    _selectedSexo = _getSexoWithFallback(widget.petData.sexo);

    print('✅ Configuração final:');
    print('   - Nome: ${_nomeController.text}');
    print('   - Espécie: ${_selectedEspecie?.descricao}');
    print('   - Raça: ${_selectedRaca?.descricao}');
    print('   - Porte: ${_selectedPorte?.descricao}');
    print('   - Sexo: $_selectedSexo');
  }

  EspecieModel? _findEspecie(EspecieProvider provider, int? idEspecie) {
    if (idEspecie != null) {
      try {
        return provider.especies.firstWhere(
          (especie) => especie.idEspecie == idEspecie,
        );
      } catch (e) {
        print('❌ Espécie $idEspecie não encontrada');
      }
    }
    return provider.especies.isNotEmpty ? provider.especies.first : null;
  }

  RacaModel? _findRaca(RacaProvider provider, int? idRaca) {
    if (idRaca != null) {
      try {
        return provider.racas.firstWhere(
          (raca) => raca.idRaca == idRaca,
        );
      } catch (e) {
        print('❌ Raça $idRaca não encontrada');
      }
    }
    return provider.racas.isNotEmpty ? provider.racas.first : null;
  }

  PorteModel? _findPorte(PorteProvider provider, int? idPorte) {
    if (idPorte != null) {
      try {
        return provider.portes.firstWhere(
          (porte) => porte.idPorte == idPorte,
        );
      } catch (e) {
        print('❌ Porte $idPorte não encontrado');
      }
    }
    // Porte pode ser null, então retornamos null se não encontrar
    return provider.portes.isNotEmpty ? provider.portes.first : null;
  }

  String _getSexoWithFallback(String? sexo) {
    if (sexo == null || sexo.isEmpty) return 'M';

    final upperSexo = sexo.toUpperCase();
    return (upperSexo == 'F' || upperSexo == 'FÊMEA') ? 'F' : 'M';
  }

  @override
  void dispose() {
    _nomeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              'Editar Pet',
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
              if (especieProvider.loading && especieProvider.especies.isEmpty) {
                return _buildDropdownLoading('Espécie');
              }

              return AppDropDown<EspecieModel>(
                value: _selectedEspecie,
                items: especieProvider.especies,
                label: 'Espécie',
                hint: 'Selecione uma espécie',
                isRequired: true,
                errorMessage: 'Selecione uma espécie',
                onChanged: (EspecieModel? newEspecie) {
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
              if (racaProvider.loading && racaProvider.racas.isEmpty) {
                return _buildDropdownLoading('Raça');
              }

              return AppDropDown<RacaModel>(
                value: _selectedRaca,
                items: racaProvider.racas,
                label: 'Raça',
                hint: 'Selecione uma raça',
                isRequired: true,
                errorMessage: 'Selecione uma raça',
                onChanged: (RacaModel? newRaca) {
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
              if (porteProvider.loading && porteProvider.portes.isEmpty) {
                return _buildDropdownLoading('Porte');
              }

              return AppDropDown<PorteModel>(
                value: _selectedPorte,
                items: porteProvider.portes,
                label: 'Porte',
                hint: 'Selecione um porte',
                isRequired: true,
                errorMessage: 'Selecione um porte',
                onChanged: (PorteModel? newPorte) {
                  setState(() {
                    _selectedPorte = newPorte;
                  });
                },
                itemText: (porte) => porte.descricao,
              );
            },
          ),

          const SizedBox(height: 24),

          // Botão de excluir
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 12),
            child: OutlinedButton(
              onPressed: _confirmarExclusao,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: Colors.red),
              ),
              child: const Text(
                'Excluir Pet',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                ),
              ),
            ),
          ),

          // Botões de salvar e cancelar
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Colors.grey),
                  ),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AppButton(
                  onPressed: _salvarEdicoes,
                  label: 'Salvar',
                ),
              ),
            ],
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

  void _salvarEdicoes() {
    if (_formKey.currentState!.validate()) {
      if (_selectedEspecie == null || _selectedRaca == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor, preencha espécie e raça'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final petEditado = PetModel(
        idPet: widget.petData.idPet,
        nome: _nomeController.text.trim(),
        sexo: _selectedSexo,
        idEspecie: _selectedEspecie!.idEspecie,
        idRaca: _selectedRaca!.idRaca,
        idPorte: _selectedPorte?.idPorte,
        idUsuario: widget.petData.idUsuario,
        nascimento: widget.petData.nascimento,
        observacoes: widget.petData.observacoes,
      );

      print('💾 Salvando alterações do pet:');
      print('   - Nome: ${petEditado.nome}');
      print('   - Sexo: ${petEditado.sexo}');
      print('   - Espécie ID: ${petEditado.idEspecie}');
      print('   - Raça ID: ${petEditado.idRaca}');
      print('   - Porte ID: ${petEditado.idPorte}');

      Navigator.of(context).pop();
      widget.onPetEdited?.call(petEditado);
    }
  }

  void _confirmarExclusao() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Pet'),
        content: Text(
          'Tem certeza que deseja excluir ${_nomeController.text}? Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Fecha o dialog
              Navigator.of(context).pop(); // Fecha o modal
              widget.onPetDeleted?.call();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}
