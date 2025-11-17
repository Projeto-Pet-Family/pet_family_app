import 'package:flutter/material.dart';
import 'package:pet_family_app/models/contrato_model.dart';
import 'package:pet_family_app/models/denuncia_model.dart';
import 'package:pet_family_app/services/denuncia_service.dart';
import 'package:pet_family_app/widgets/app_button.dart';

class DenunciaModal extends StatefulWidget {
  final ContratoModel contrato;
  final VoidCallback? onDenunciaCriada;
  final DenunciaModel? denunciaExistente;

  const DenunciaModal({
    super.key,
    required this.contrato,
    this.onDenunciaCriada,
    this.denunciaExistente,
  });

  static void show({
    required BuildContext context,
    required ContratoModel contrato,
    VoidCallback? onDenunciaCriada,
    DenunciaModel? denunciaExistente,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DenunciaModal(
        contrato: contrato,
        onDenunciaCriada: onDenunciaCriada,
        denunciaExistente: denunciaExistente,
      ),
    );
  }

  @override
  State<DenunciaModal> createState() => _DenunciaModalState();
}

class _DenunciaModalState extends State<DenunciaModal> {
  final _formKey = GlobalKey<FormState>();
  final _comentarioController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.denunciaExistente != null) {
      _comentarioController.text = widget.denunciaExistente!.comentario;
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

  Future<void> _enviarDenuncia(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final denuncia = DenunciaModel(
        idContrato: widget.contrato.idContrato!,
        idHospedagem: widget.contrato.idHospedagem!,
        idUsuario: widget.contrato.idUsuario!,
        comentario: _comentarioController.text.trim(),
        dataDenuncia: DateTime.now(),
      );

      if (widget.denunciaExistente != null) {
        await DenunciaService.atualizarDenuncia(
          widget.denunciaExistente!.idDenuncia!,
          denuncia.copyWith(idDenuncia: widget.denunciaExistente!.idDenuncia),
        );
      } else {
        await DenunciaService.criarDenuncia(denuncia);
      }

      if (widget.onDenunciaCriada != null) {
        widget.onDenunciaCriada!();
      }

      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.denunciaExistente != null
              ? 'Denúncia atualizada com sucesso!'
              : 'Denúncia enviada com sucesso!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    } on DenunciaException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao enviar denúncia: ${e.message}'),
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
            Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange[700],
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  widget.denunciaExistente != null
                      ? 'Editar Denúncia'
                      : 'Fazer Denúncia',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
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
            const Text(
              'Descreva o problema encontrado:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _comentarioController,
              maxLines: 5,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Por favor, descreva o problema';
                }
                if (value.trim().length < 10) {
                  return 'A descrição deve ter pelo menos 10 caracteres';
                }
                return null;
              },
              decoration: const InputDecoration(
                hintText:
                    'Descreva detalhadamente o problema que você encontrou durante sua hospedagem...',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Mínimo 10 caracteres. Sua denúncia será analisada pela nossa equipe.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            AppButton(
              label: widget.denunciaExistente != null
                  ? 'Atualizar Denúncia'
                  : 'Enviar Denúncia',
              onPressed: _isLoading ? null : () => _enviarDenuncia(context),
              buttonColor: Colors.red,
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
