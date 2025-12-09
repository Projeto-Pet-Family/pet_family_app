// pages/booking/template/add/add_service_modal.dart
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:pet_family_app/models/contrato_model.dart';
import 'package:pet_family_app/models/service_model.dart';
import 'package:pet_family_app/pages/booking/template/add/add_pet_modal.dart';
import 'package:pet_family_app/services/contrato_service.dart';
import 'package:pet_family_app/widgets/app_button.dart';

class AddServiceModal extends StatefulWidget {
  final int idContrato;
  final int idHospedagem;
  final List<ServiceModel> servicosNoContrato;
  final List<dynamic> petsNoContrato;
  final Function(ContratoModel) onServicoAdicionado;
  final int? idUsuario;

  const AddServiceModal({
    super.key,
    required this.idContrato,
    required this.idHospedagem,
    required this.servicosNoContrato,
    required this.petsNoContrato,
    required this.onServicoAdicionado,
    this.idUsuario,
  });

  @override
  State<AddServiceModal> createState() => _AddServiceModalState();
}

class _AddServiceModalState extends State<AddServiceModal> {
  late ContratoService _contratoService;
  List<ServiceModel> _servicosHospedagem = [];
  List<ServiceModel> _servicosSelecionados = [];
  bool _carregando = true;
  bool _enviando = false;
  late int _idUsuario;

  @override
  void initState() {
    super.initState();
    final dio = Dio();
    _contratoService = ContratoService(dio);
    _idUsuario = widget.idUsuario ?? 0;
    _carregarServicosDaHospedagem();
  }

  Future<void> _carregarServicosDaHospedagem() async {
    try {
      final dio = Dio();

      // CORREÇÃO: Buscar serviços da hospedagem, não do contrato
      final response = await dio.get(
        'https://bepetfamily.onrender.com/hospedagens/${widget.idHospedagem}/servicos',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      print(
          '📡 URL chamada: https://bepetfamily.onrender.com/hospedagens/${widget.idHospedagem}/servicos');
      print('📊 Status code: ${response.statusCode}');
      print('📦 Resposta: ${response.data}');

      if (response.statusCode == 200) {
        List<dynamic> data = response.data is List ? response.data : [];

        final servicosHospedagem = data.map<ServiceModel>((json) {
          return ServiceModel(
            idservico: json['idservico'] ?? json['idServico'] ?? 0,
            idhospedagem: json['idhospedagem'] ??
                json['idHospedagem'] ??
                widget.idHospedagem,
            descricao: json['descricao'] ?? json['nome'] ?? 'Serviço',
            preco: json['preco'] is num
                ? json['preco'].toDouble()
                : (json['valor'] is num ? json['valor'].toDouble() : 0.0),
          );
        }).toList();

        setState(() {
          _servicosHospedagem = servicosHospedagem;
          _carregando = false;
        });

        print('✅ Serviços carregados: ${_servicosHospedagem.length}');
      } else {
        print('❌ Erro na resposta: ${response.statusCode}');
        setState(() => _carregando = false);
      }
    } catch (e) {
      print('❌ Erro ao carregar serviços da hospedagem: $e');
      setState(() => _carregando = false);
    }
  }

  bool _isPetInContrato(Map<String, dynamic> pet) {
    // Verificar se o pet tem algum indicador de estar no contrato
    return pet.containsKey('idcontrato') ||
        pet.containsKey('idContrato') ||
        (pet.containsKey('status') && pet['status'] == 'ativo') ||
        (pet.containsKey('servicos') && pet['servicos'] is List);
  }

  // Método para adicionar serviço a pets específicos
  void _adicionarServicoAoPet(ServiceModel servico) {
    print('🎯 Adicionando serviço ${servico.descricao} aos pets');

    // Filtrar pets que estão NO CONTRATO e NÃO têm este serviço
    final List<Map<String, dynamic>> petsNoContratoSemEsteServico = [];

    for (var pet in widget.petsNoContrato) {
      if (pet is Map) {
        // Verificar se o pet está realmente no contrato
        final dynamic idPet = pet['idpet'] ?? pet['idPet'] ?? pet['id'];

        // Verificar se o pet tem este serviço
        bool temEsteServico = false;
        final servicos = pet['servicos'];

        if (servicos is List) {
          temEsteServico = servicos.any((servicoItem) {
            final servicoId = servicoItem is Map
                ? servicoItem['idservico'] ??
                    servicoItem['idServico'] ??
                    servicoItem
                : servicoItem;
            return servicoId == servico.idservico;
          });
        }

        // Só adiciona se o pet ESTÁ no contrato e NÃO tem o serviço
        if (!temEsteServico) {
          petsNoContratoSemEsteServico.add(Map<String, dynamic>.from(pet));
        }
      }
    }

    print(
        '📊 Pets no contrato SEM este serviço: ${petsNoContratoSemEsteServico.length}');

    if (petsNoContratoSemEsteServico.isEmpty) {
      _mostrarMensagem('Todos os pets do contrato já têm este serviço!');
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddPetModal(
        idContrato: widget.idContrato,
        idUsuario: _idUsuario,
        petsNoContrato:
            petsNoContratoSemEsteServico, // Passar apenas pets sem o serviço
        onPetAdicionado: (contratoAtualizado) {
          widget.onServicoAdicionado(contratoAtualizado);
          Navigator.pop(context);

          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted) {
              Navigator.pop(context);
            }
          });
        },
        idServicoSelecionado: servico.idservico,
        petsComServico: [], // Lista vazia, pois só mostramos pets sem o serviço
      ),
    );
  }

  // Método para adicionar serviços gerais
  Future<void> _adicionarServicosGerais() async {
    if (_servicosSelecionados.isEmpty) {
      _mostrarMensagem('Selecione pelo menos um serviço');
      return;
    }

    setState(() => _enviando = true);

    try {
      print('➕ Adicionando serviços gerais: $_servicosSelecionados');

      // Formatar dados para a API
      final servicosPorPet = [
        {
          'idPet': null, // null indica serviço geral
          'servicos': _servicosSelecionados.map((s) => s.idservico).toList(),
        }
      ];

      print('📦 Enviando: $servicosPorPet');

      // Chamar API para adicionar serviços
      await _contratoService.adicionarServicoContrato(
        idContrato: widget.idContrato,
        servicosPorPet: servicosPorPet,
      );

      // Buscar contrato atualizado
      final contratoAtualizado =
          await _contratoService.buscarContratoPorId(widget.idContrato);

      // Atualizar UI
      widget.onServicoAdicionado(contratoAtualizado);

      // Fechar modal
      if (mounted) {
        Navigator.pop(context);
        _mostrarMensagemSucesso('Serviço(s) adicionado(s) com sucesso!');
      }
    } catch (e) {
      print('❌ Erro ao adicionar serviços: $e');
      _mostrarErro('Erro ao adicionar serviços: $e');
    } finally {
      if (mounted) {
        setState(() => _enviando = false);
      }
    }
  }

  Widget _buildItemServico(ServiceModel servico) {
    final selecionado =
        _servicosSelecionados.any((s) => s.idservico == servico.idservico);

    // Verificar se o serviço já está no contrato como serviço geral
    final jaAdicionadoNoContrato =
        widget.servicosNoContrato.any((s) => s.idservico == servico.idservico);

    // Contar quantos pets no contrato têm este serviço
    int petsComEsteServico = 0;
    final List<Map<String, dynamic>> petsNoContratoSemServico = [];

    if (widget.petsNoContrato.isNotEmpty) {
      for (var pet in widget.petsNoContrato) {
        if (pet is Map) {
          bool temEsteServico = false;
          final servicos = pet['servicos'];

          if (servicos is List) {
            temEsteServico = servicos.any((servicoItem) {
              final servicoId = servicoItem is Map
                  ? servicoItem['idservico'] ??
                      servicoItem['idServico'] ??
                      servicoItem
                  : servicoItem;
              return servicoId == servico.idservico;
            });
          }

          if (temEsteServico) {
            petsComEsteServico++;
          } else {
            petsNoContratoSemServico.add(Map<String, dynamic>.from(pet));
          }
        }
      }
    }

    final algumPetTemEsteServico = petsComEsteServico > 0;
    final temPetsSemServico = petsNoContratoSemServico.isNotEmpty;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: selecionado ? const Color(0xff8692DE) : Colors.grey[300]!,
          width: selecionado ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    servico.descricao ?? 'Serviço',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  'R\$ ${servico.preco?.toStringAsFixed(2) ?? "0.00"}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Badges para status do serviço
                Row(
                  children: [
                    if (jaAdicionadoNoContrato)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.assignment,
                              size: 12,
                              color: Colors.blue[700],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Serviço geral',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: Colors.blue[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (petsComEsteServico > 0)
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.pets,
                                size: 12,
                                color: Colors.green,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Em $petsComEsteServico pet(s)',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.green[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),

                // Botões de ação
                Row(
                  children: [
                    // Botão para adicionar a pets específicos
                    if (temPetsSemServico)
                      InkWell(
                        onTap: () => _adicionarServicoAoPet(servico),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xff8692DE),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.pets,
                                size: 14,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Adicionar a Pet',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListaServicos() {
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
              'Carregando serviços...',
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    if (_servicosHospedagem.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cleaning_services_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              'Nenhum serviço disponível!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'Não há serviços cadastrados para esta hospedagem.',
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
      itemCount: _servicosHospedagem.length,
      itemBuilder: (context, index) =>
          _buildItemServico(_servicosHospedagem[index]),
    );
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
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    // Header
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

                    // Título
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Serviços da Hospedagem',
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

                    // Contador de selecionados
                    if (_servicosSelecionados.isNotEmpty)
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
                                '${_servicosSelecionados.length} serviço(s) selecionado(s)',
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

                    // Lista de serviços
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _buildListaServicos(),
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
