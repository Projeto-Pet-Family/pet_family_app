import 'package:flutter/material.dart';

class PetEditTemplate extends StatelessWidget {
  const PetEditTemplate({
    super.key,
    required this.name,
    required this.especie,
    required this.raca,
    required this.onTap,
    this.idade,
    this.sexo,
    this.porte,
  });

  final String name;
  final String especie;
  final String raca;
  final String? idade;
  final String? sexo;
  final String? porte;
  final VoidCallback onTap;

  // Ícones para diferentes espécies
  IconData _getPetIcon(String especie) {
    if (especie.isEmpty) return Icons.pets; // Ícone padrão
    
    switch (especie.toLowerCase()) {
      case 'cachorro':
        return Icons.pets;
      case 'gato':
        return Icons.catching_pokemon;
      case 'pássaro':
      case 'passaro':
        return Icons.flag;
      case 'peixe':
        return Icons.water_drop;
      case 'roedor':
        return Icons.mouse;
      case 'coelho':
        return Icons.forest;
      default:
        return Icons.pets;
    }
  }

  // Cores baseadas no sexo do pet
  Color _getSexColor(String? sexo) {
    if (sexo == null) return Colors.grey[100]!;
    
    switch (sexo.toLowerCase()) {
      case 'macho':
        return Colors.blue[50]!;
      case 'fêmea':
      case 'femea':
        return Colors.pink[50]!;
      default:
        return Colors.grey[100]!;
    }
  }

  Color _getSexTextColor(String? sexo) {
    if (sexo == null) return Colors.grey[800]!;
    
    switch (sexo.toLowerCase()) {
      case 'macho':
        return Colors.blue[800]!;
      case 'fêmea':
      case 'femea':
        return Colors.pink[800]!;
      default:
        return Colors.grey[800]!;
    }
  }

  String _getSexSymbol(String? sexo) {
    if (sexo == null) return '?';
    
    switch (sexo.toLowerCase()) {
      case 'macho':
        return '♂';
      case 'fêmea':
      case 'femea':
        return '♀';
      default:
        return '?';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(width: 1, color: const Color(0xFFEEEEEE)),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Ícone do pet com cor baseada no sexo
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: _getSexColor(sexo),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _getSexTextColor(sexo).withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Icon(
                  _getPetIcon(especie),
                  size: 30,
                  color: _getSexTextColor(sexo),
                ),
              ),
              const SizedBox(width: 16),
              
              // Informações do pet
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nome e sexo
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (sexo != null && sexo!.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getSexColor(sexo),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _getSexTextColor(sexo).withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              _getSexSymbol(sexo),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: _getSexTextColor(sexo),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    
                    // Espécie e Raça
                    if (especie.isNotEmpty || raca.isNotEmpty)
                      Text(
                        _formatarEspecieRaca(especie, raca),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.black54,
                        ),
                      ),
                    
                    // Idade e Porte
                    if ((idade != null && idade!.isNotEmpty) || 
                        (porte != null && porte!.isNotEmpty))
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Row(
                          children: [
                            if (idade != null && idade!.isNotEmpty)
                              Row(
                                children: [
                                  Icon(
                                    Icons.cake,
                                    size: 14,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '$idade anos',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            if (idade != null && idade!.isNotEmpty && 
                                porte != null && porte!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: Container(
                                  width: 4,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[400],
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            if (porte != null && porte!.isNotEmpty)
                              Text(
                                'Porte $porte',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              
              // Ícone de seta
              Icon(
                Icons.arrow_forward_ios,
                size: 18,
                color: Colors.grey[500],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatarEspecieRaca(String especie, String raca) {
    if (especie.isNotEmpty && raca.isNotEmpty) {
      return '$especie • $raca';
    } else if (especie.isNotEmpty) {
      return especie;
    } else if (raca.isNotEmpty) {
      return raca;
    }
    return ''; // Retorna vazio se ambos forem vazios
  }
}