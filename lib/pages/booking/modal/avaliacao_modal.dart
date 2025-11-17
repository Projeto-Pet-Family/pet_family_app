import 'package:flutter/material.dart';
import 'package:pet_family_app/models/avaliacao_model.dart';
import 'package:pet_family_app/models/contrato_model.dart';
import 'package:pet_family_app/services/avaliacao_service.dart';
import 'package:pet_family_app/widgets/app_button.dart';

class AvaliacaoModal extends StatefulWidget {
  final ContratoModel contrato;
  final VoidCallback? onAvaliacaoCriada;
  final AvaliacaoModel? avaliacaoExistente;

  const AvaliacaoModal({
    super.key,
    required this.contrato,
    this.onAvaliacaoCriada,
    this.avaliacaoExistente,
  });

  static void show({
    required BuildContext context,
    required ContratoModel contrato,
    VoidCallback? onAvaliacaoCriada,
    AvaliacaoModel? avaliacaoExistente,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AvaliacaoModal(
        contrato: contrato,
        onAvaliacaoCriada: onAvaliacaoCriada,
        avaliacaoExistente: avaliacaoExistente,
      ),
    );
  }

  @override
  State<AvaliacaoModal> createState() => _AvaliacaoModalState();
}

class _AvaliacaoModalState extends State<AvaliacaoModal> {
  final _formKey = GlobalKey<FormState>();
  final _comentarioController = TextEditingController();
  int _estrelasSelecionadas = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.avaliacaoExistente != null) {
      _estrelasSelecionadas = widget.avaliacaoExistente!.estrelas;
      _comentarioController.text = widget.avaliacaoExistente!.comentario ?? '';
    }
  }

  @override
  void dispose() {
    _comentarioController.dispose();
    super.dispose();
  }

  String _formatarData(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<void> _enviarAvaliacao(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;
    if (_estrelasSelecionadas == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecione uma avaliação com estrelas'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final avaliacao = AvaliacaoModel(
        idContrato: widget.contrato.idContrato!,
        idHospedagem: widget.contrato.idHospedagem!,
        idUsuario: widget.contrato.idUsuario!,
        comentario: _comentarioController.text.trim(),
        estrelas: _estrelasSelecionadas,
        dataAvaliacao: DateTime.now(),
      );

      if (widget.avaliacaoExistente != null) {
        await AvaliacaoService.atualizarAvaliacao(
          widget.avaliacaoExistente!.idAvaliacao!,
          avaliacao.copyWith(
              idAvaliacao: widget.avaliacaoExistente!.idAvaliacao),
        );
      } else {
        await AvaliacaoService.criarAvaliacao(avaliacao);
      }

      if (widget.onAvaliacaoCriada != null) {
        widget.onAvaliacaoCriada!();
      }

      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.avaliacaoExistente != null
              ? 'Avaliação atualizada com sucesso!'
              : 'Avaliação enviada com sucesso!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    } on AvaliacaoException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao enviar avaliação: ${e.message}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro inesperado: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildEstrelas() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          'Como foi sua experiência?',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            final estrela = index + 1;
            return GestureDetector(
              onTap: () => setState(() => _estrelasSelecionadas = estrela),
              child: Icon(
                estrela <= _estrelasSelecionadas
                    ? Icons.star
                    : Icons.star_border,
                size: 40,
                color: estrela <= _estrelasSelecionadas
                    ? Colors.amber
                    : Colors.grey,
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        Text(
          _estrelasSelecionadas == 0
              ? 'Selecione uma nota'
              : '${_estrelasSelecionadas} estrela${_estrelasSelecionadas > 1 ? 's' : ''}',
          style: TextStyle(
            fontSize: 16,
            color: _estrelasSelecionadas == 0 ? Colors.grey : Colors.amber,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Form(
        key: _formKey,
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
            const SizedBox(height: 20),
            Text(
              widget.avaliacaoExistente != null
                  ? 'Editar Avaliação'
                  : 'Avaliar Hospedagem',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.contrato.hospedagemNome ?? 'Hospedagem',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            Text(
              '${_formatarData(widget.contrato.dataInicio)} - ${_formatarData(widget.contrato.dataFim ?? widget.contrato.dataInicio)}',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            _buildEstrelas(),
            const SizedBox(height: 24),
            TextFormField(
              controller: _comentarioController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Comentário (opcional)',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
                hintText: 'Conte como foi sua experiência com a hospedagem...',
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Seu comentário ajudará outros usuários a escolherem a melhor hospedagem.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            AppButton(
              label: widget.avaliacaoExistente != null
                  ? 'Atualizar Avaliação'
                  : 'Enviar Avaliação',
              onPressed: _isLoading ? null : () => _enviarAvaliacao(context),
              buttonColor: const Color(0xff8692DE),
              textButtonColor: Colors.white,
            ),
            const SizedBox(height: 12),
            AppButton(
              label: 'Cancelar',
              onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
              buttonColor: Colors.grey[300]!,
              textButtonColor: Colors.black87,
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
