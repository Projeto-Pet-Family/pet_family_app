import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_family_app/widgets/app_button.dart';
import 'package:pet_family_app/widgets/app_text_field.dart';

class ModalSend extends StatefulWidget {
  const ModalSend({
    super.key,
    required this.iconTitle,
    required this.textTitle,
    required this.label,
    required this.hint,
  });

  final Icon iconTitle;
  final String textTitle;
  final String label;
  final String hint;

  @override
  State<ModalSend> createState() => _ModalState();
}

class _ModalState extends State<ModalSend> {
  final TextEditingController textFieldController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 600,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                icon: Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Icon(
              widget.iconTitle.icon,
              size: 70,
            ),
            SizedBox(height: 30),
            Text(
              widget.textTitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w200,
                fontSize: 14,
                color: Color(0xFF474343),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: AppTextField(
                controller: textFieldController,
                labelText: widget.label,
                hintText: widget.hint,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  TelefoneInputFormatter(),
                ],
              ),
            ),
            AppButton(
              onPressed: () {
                context.go('/insert-token');
              },
              label: 'Enviar',
              fontSize: 25,
            ),
          ],
        ),
      ),
    );
  }
}
