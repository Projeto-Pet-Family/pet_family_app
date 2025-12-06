// pages/edit_booking/modal/add_service_modal.dart
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:pet_family_app/models/service_model.dart';
import 'package:pet_family_app/services/contrato_service.dart';
import 'package:pet_family_app/services/service_service.dart';
import 'package:pet_family_app/widgets/app_button.dart';
import 'package:pet_family_app/models/contrato_model.dart';
import 'package:http/http.dart' as http;

class AddServiceModal extends StatefulWidget {
  final int idContrato;
  final int idHospedagem;
  final List<dynamic> servicosNoContrato;
  final Function(ContratoModel) onServicoAdicionado;

  const AddServiceModal({
    super.key,
    required this.idContrato,
    required this.idHospedagem,
    required this.servicosNoContrato,
    required this.onServicoAdicionado,
  });

  @override
  State<AddServiceModal> createState() => _AddServiceModalState();
}

class _AddServiceModalState extends State<AddServiceModal> {
  late ServiceService _serviceService;
  late ContratoService _contratoService;
  List<ServiceModel> _servicosDisponiveis = [];
  final List<int> _servicosSelecionados = [];
  bool _carregando = true;
  bool _enviando = false;

  @override
  void initState() {
    super.initState();
    final dio = Dio();
    _serviceService = ServiceService(client: http.Client());
    _contratoService = ContratoService(dio: dio, client: http.Client());
    _carregarServicosDisponiveis();
  }

  Future<void> _carregarServicosDisponiveis() async {
    try {
      print('🔄 Iniciando carregamento de serviços disponíveis...');
      print('📊 ID Hospedagem: ${widget.idHospedagem}');
      print('📊 ID Contrato: ${widget.idContrato}');
      print(
          '📊 Serviços no contrato recebidos: ${widget.servicosNoContrato.length}');

      // Debug: Mostrar o que está em servicosNoContrato
      for (var i = 0; i < widget.servicosNoContrato.length; i++) {
        final item = widget.servicosNoContrato[i];
        print('  [${i}] Tipo: ${item.runtimeType}');
        if (item is ServiceModel) {
          print(
              '  [${i}] ServiceModel - ID: ${item.idServico}, Descrição: ${item.descricao}');
        } else if (item is Map) {
          print('  [${i}] Map - Conteúdo: $item');
        }
      }

      final dio = Dio();
      final response = await dio.get(
        'https://bepetfamily.onrender.com/hospedagens/${widget.idHospedagem}/servicos',
        options: Options(headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        }),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        print('📊 Total de serviços da API: ${data.length}');
        print('📊 Dados da API: $data');

        final todosServicos = data.map((json) {
          try {
            return ServiceModel.fromJson(json);
          } catch (e) {
            print('⚠️ Erro ao converter JSON: $json');
            print('⚠️ Erro: $e');
            return ServiceModel(
              idservico: json['idservico'] ?? 0,
              idhospedagem: widget.idHospedagem,
              descricao: json['descricao']?.toString() ?? 'Serviço',
              preco: (json['preco'] is String)
                  ? double.tryParse(json['preco']) ?? 0.0
                  : (json['preco'] as num?)?.toDouble() ?? 0.0,
            );
          }
        }).toList();

        print('📊 Todos os serviços convertidos:');
        for (var servico in todosServicos) {
          print(
              '  - ID: ${servico.idServico}, Descrição: ${servico.descricao}');
        }

        // Extrair IDs dos serviços já no contrato
        final servicosContratoIds = <int>[];
        for (var item in widget.servicosNoContrato) {
          if (item is ServiceModel) {
            servicosContratoIds.add(item.idServico);
            print('✅ Serviço no contrato (ServiceModel): ${item.idServico}');
          } else if (item is Map<String, dynamic>) {
            final id = item['idservico'] ?? item['idServico'];
            if (id != null) {
              servicosContratoIds.add(int.tryParse(id.toString()) ?? 0);
              print('✅ Serviço no contrato (Map): $id');
            }
          }
        }

        print('📊 IDs de serviços no contrato: $servicosContratoIds');

        // Filtrar serviços disponíveis
        final servicosDisponiveis = <ServiceModel>[];
        for (var servico in todosServicos) {
          if (!servicosContratoIds.contains(servico.idServico)) {
            servicosDisponiveis.add(servico);
            print(
                '➕ Serviço disponível para adicionar: ${servico.idServico} - ${servico.descricao}');
          } else {
            print(
                '➖ Serviço já no contrato: ${servico.idServico} - ${servico.descricao}');
          }
        }

        print(
            '📊 Total de serviços disponíveis: ${servicosDisponiveis.length}');

        setState(() {
          _servicosDisponiveis = servicosDisponiveis;
          _carregando = false;
        });
      } else {
        print('❌ Erro na API: ${response.statusCode}');
        print('❌ Response: ${response.data}');
        throw Exception('Erro ao carregar serviços: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Erro ao carregar serviços: $e');
      _mostrarErro('Erro ao carregar serviços: $e');

      setState(() {
        _carregando = false;
      });
    }
  }

  Future<void> _adicionarServicos() async {
    if (_servicosSelecionados.isEmpty) {
      _mostrarMensagem('Selecione pelo menos um serviço');
      return;
    }

    setState(() => _enviando = true);

    try {
      // Converter para o formato esperado pela API
      final servicosFormatados = _servicosSelecionados
          .map((id) => {
                'idservico': id,
              })
          .toList();

      final contratoAtualizado =
          await _contratoService.adicionarServicoContrato(
        idContrato: widget.idContrato,
        servicosIds: _servicosSelecionados,
      );

      widget.onServicoAdicionado(contratoAtualizado);
      Navigator.of(context).pop();
      _mostrarMensagemSucesso('Serviço(s) adicionado(s) com sucesso!');
    } catch (e) {
      _mostrarErro('Erro: $e');
    } finally {
      setState(() => _enviando = false);
    }
  }

  void _mostrarMensagem(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _mostrarMensagemSucesso(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _mostrarErro(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: Colors.red,
      ),
    );
  }

  Widget _buildItemServico(ServiceModel servico) {
    final selecionado = _servicosSelecionados.contains(servico.idservico);
    final precoFormatado = servico.preco.toStringAsFixed(2);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: selecionado
            ? const BorderSide(color: Color(0xff8692DE), width: 2)
            : BorderSide(color: Colors.grey[300]!),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xff8692DE).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.room_service,
            color: Color(0xff8692DE),
            size: 30,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                servico.descricao,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
            Checkbox(
              value: selecionado,
              onChanged: (value) {
                setState(() {
                  if (value == true) {
                    _servicosSelecionados.add(servico.idServico!);
                  } else {
                    _servicosSelecionados.remove(servico.idServico);
                  }
                });
              },
              activeColor: const Color(0xff8692DE),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            'R\$$precoFormatado',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xff8692DE),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildListaServicos() {
    if (_carregando) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.only(top: 100),
          child: CircularProgressIndicator(
            color: Color(0xff8692DE),
          ),
        ),
      );
    }

    if (_servicosDisponiveis.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 100),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle,
                size: 80,
                color: Colors.green[400],
              ),
              const SizedBox(height: 20),
              const Text(
                'Todos os serviços já foram adicionados!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                'Não há serviços disponíveis para adicionar.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 20),
      itemCount: _servicosDisponiveis.length,
      itemBuilder: (context, index) =>
          _buildItemServico(_servicosDisponiveis[index]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: const EdgeInsets.only(top: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[100],
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 24,
                      color: Colors.black54,
                    ),
                  ),
                ),
                const Text(
                  'Adicionar Serviços',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff8692DE),
                  ),
                ),
                const SizedBox(width: 40),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Contador
          if (_servicosSelecionados.isNotEmpty)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xff8692DE).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 16,
                    color: const Color(0xff8692DE),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${_servicosSelecionados.length} serviço(s) selecionado(s)',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xff8692DE),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 16),

          // Lista de serviços
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildListaServicos(),
            ),
          ),

          // Botões
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                AppButton(
                  onPressed: _enviando || _servicosSelecionados.isEmpty
                      ? null
                      : _adicionarServicos,
                  label: _enviando ? 'Adicionando...' : 'Adicionar Serviços',
                  fontSize: 16,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  buttonColor: const Color(0xff8692DE),
                  textButtonColor: Colors.white,
                  borderRadius: BorderRadius.circular(50),
                ),
                const SizedBox(height: 12),
                AppButton(
                  onPressed: _enviando ? null : () => Navigator.pop(context),
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
    );
  }
}
