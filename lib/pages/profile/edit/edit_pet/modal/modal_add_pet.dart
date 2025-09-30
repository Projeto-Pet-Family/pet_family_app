import 'package:flutter/material.dart';
import 'package:pet_family_app/widgets/app_button.dart';
import 'package:pet_family_app/widgets/app_text_field.dart';

class ModalAddPet extends StatefulWidget {
  final Function(Map<String, dynamic>)? onPetAdded;

  const ModalAddPet({super.key, this.onPetAdded});

  @override
  State<ModalAddPet> createState() => _ModalAddPetState();
}

class _ModalAddPetState extends State<ModalAddPet> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _especieController = TextEditingController();
  final TextEditingController _racaController = TextEditingController();
  final TextEditingController _idadeController = TextEditingController();
  final TextEditingController _pesoController = TextEditingController();

  String _selectedSexo = 'Macho';
  String _selectedPorte = 'Pequeno';

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
                AppTextField(
                  controller: _especieController,
                  labelText: 'Espécie',
                  hintText: 'Ex: Cachorro, Gato, etc.',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, digite a espécie';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _racaController,
                  labelText: 'Raça',
                  hintText: 'Digite a raça do pet',
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Sexo',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: _selectedSexo,
                            items: ['Macho', 'Fêmea']
                                .map((sexo) => DropdownMenuItem(
                                      value: sexo,
                                      child: Text(sexo),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedSexo = value!;
                              });
                            },
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Porte',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: _selectedPorte,
                            items: ['Pequeno', 'Médio', 'Grande']
                                .map((porte) => DropdownMenuItem(
                                      value: porte,
                                      child: Text(porte),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedPorte = value!;
                              });
                            },
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        controller: _idadeController,
                        labelText: 'Idade (anos)',
                        hintText: '0',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: AppTextField(
                        controller: _pesoController,
                        labelText: 'Peso (kg)',
                        hintText: '0.0',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
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
                        onPressed: _adicionarPet,
                        label: 'Salvar',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _adicionarPet() {
    if (_formKey.currentState!.validate()) {
      final novoPet = {
        'nome': _nomeController.text.trim(),
        'especie': _especieController.text.trim(),
        'raca': _racaController.text.trim(),
        'sexo': _selectedSexo,
        'porte': _selectedPorte,
        'idade': _idadeController.text.trim(),
        'peso': _pesoController.text.trim(),
      };

      // Fecha o modal e retorna os dados do pet
      Navigator.of(context).pop();
      widget.onPetAdded?.call(novoPet);
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _especieController.dispose();
    _racaController.dispose();
    _idadeController.dispose();
    _pesoController.dispose();
    super.dispose();
  }
}