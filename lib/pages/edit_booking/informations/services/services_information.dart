import 'package:flutter/material.dart';
import 'package:pet_family_app/models/contrato_model.dart';

class ServicesInformation extends StatelessWidget {
  final ContratoModel contrato;
  final bool editavel;
  final bool modoExclusao;
  final List<int> servicosSelecionados;
  final Function(int)? onServicoSelecionado;

  const ServicesInformation({
    super.key,
    required this.contrato,
    required this.editavel,
    required this.modoExclusao,
    this.servicosSelecionados = const [],
    this.onServicoSelecionado,
  });

  @override
  Widget build(BuildContext context) {
    final servicosGerais = contrato.servicosGerais ?? [];
    final servicosTodos = contrato.servicosGerais ?? [];
    final pets = contrato.pets ?? [];

    if (servicosTodos.isEmpty) {
      return _buildSemServicos(pets);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Contador de serviços
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total: ${servicosTodos.length} serviço(s)',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (servicosGerais.isNotEmpty)
                Chip(
                  label: Text(
                    '${servicosGerais.length} geral(s)',
                    style: const TextStyle(fontSize: 12),
                  ),
                  backgroundColor: Colors.blue[50],
                  labelStyle: TextStyle(color: Colors.blue[700]),
                ),
            ],
          ),
        ),

        // Lista de serviços
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: servicosTodos.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final servico = servicosTodos[index];
            final idServico = servico['idservico'] ?? index;
            final isSelecionado = modoExclusao && 
                servicosSelecionados.contains(idServico);
            final temPetRelacionado = servico['petNome'] != null;
            final nomePet = servico['petNome'];

            return _buildItemServico(
              servico: servico,
              isSelecionado: isSelecionado,
              temPetRelacionado: temPetRelacionado,
              nomePet: nomePet,
              idServico: idServico,
            );
          },
        ),
      ],
    );
  }

  Widget _buildSemServicos(List<dynamic> pets) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          const SizedBox(height: 12),

          if (pets.isNotEmpty) ...[
            const SizedBox(height: 20),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 2.5,
              ),
              itemCount: pets.length,
              itemBuilder: (context, index) {
                final pet = pets[index];
                return _buildPetCard(pet);
              },
            ),
            
            const SizedBox(height: 8),
            
          ],
        ],
      ),
    );
  }

  Widget _buildPetCard(Map<String, dynamic> pet) {
    final servicosDoPet = pet['servicos'] ?? [];
    final temServicos = servicosDoPet.isNotEmpty;
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: temServicos ? Color(0xff8692DE).withOpacity(0.3) : Colors.grey[200]!,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: temServicos ? Color(0xff8692DE) : Colors.grey[400],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                temServicos ? '${servicosDoPet.length}' : '0',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.pets,
                      size: 18,
                      color: temServicos ? Color(0xff8692DE) : Colors.grey[500],
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        pet['nome'] ?? 'Pet',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: temServicos ? Color(0xff8692DE) : Colors.grey[700],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 4),
                
                if (pet['especie'] != null || pet['raca'] != null)
                  Text(
                    '${pet['especie'] ?? ''} ${pet['raca'] ?? ''}'.trim(),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                
                if (pet['porte'] != null)
                  Text(
                    'Porte: ${pet['porte']}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[500],
                    ),
                  ),
                
                if (temServicos)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '${servicosDoPet.length} serviço(s)',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xff8692DE),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemServico({
    required dynamic servico,
    required bool isSelecionado,
    required bool temPetRelacionado,
    required String? nomePet,
    required int idServico,
  }) {
    final descricao = servico['descricao'] ?? 'Serviço';
    final quantidade = servico['quantidade'] ?? 1;
    final precoUnitario = servico['precoUnitario'] ?? servico['preco'] ?? 0.0;
    final precoTotal = servico['precoTotal'] ?? (precoUnitario * quantidade);
    final precoFormatado = precoTotal is num 
        ? 'R\$${precoTotal.toStringAsFixed(2).replaceAll('.', ',')}' 
        : 'R\$0,00';
    final duracao = servico['duracao'];

    return GestureDetector(
      onTap: modoExclusao
          ? () => onServicoSelecionado?.call(idServico)
          : null,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelecionado ? Colors.red[50] : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelecionado 
                ? Colors.red[200]! 
                : (temPetRelacionado ? Color(0xff8692DE).withOpacity(0.3) : Colors.grey[200]!),
            width: isSelecionado ? 2 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isSelecionado ? 0.1 : 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho do serviço
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (modoExclusao)
                  Padding(
                    padding: const EdgeInsets.only(right: 12, top: 2),
                    child: GestureDetector(
                      onTap: () => onServicoSelecionado?.call(idServico),
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: isSelecionado ? Colors.red : Colors.white,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isSelecionado ? Colors.red : Colors.grey[400]!,
                            width: 2,
                          ),
                        ),
                        child: isSelecionado
                            ? const Icon(
                                Icons.check,
                                size: 14,
                                color: Colors.white,
                              )
                            : null,
                      ),
                    ),
                  ),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nome do serviço
                      Text(
                        descricao,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isSelecionado ? Colors.red[800] : Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      const SizedBox(height: 6),
                      
                      // Badge do pet (se houver)
                      if (temPetRelacionado && nomePet != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Color(0xff8692DE).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.pets,
                                size: 12,
                                color: Color(0xff8692DE),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                nomePet,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xff8692DE),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                
                // Preço total
                Text(
                  precoFormatado,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isSelecionado ? Colors.red[700] : Color(0xff8692DE),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Detalhes do serviço
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Quantidade
                Row(
                  children: [
                    Icon(
                      Icons.format_list_numbered,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Quantidade: $quantidade',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                    if (precoUnitario > 0) ...[
                      const SizedBox(width: 8),
                      Text(
                        '(R\$${precoUnitario.toStringAsFixed(2).replaceAll('.', ',')} un.)',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
                
                // Duração (se houver)
                if (duracao != null)
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$duracao min',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
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
}