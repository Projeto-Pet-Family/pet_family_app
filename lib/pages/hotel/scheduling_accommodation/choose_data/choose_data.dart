import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_family_app/pages/hotel/scheduling_accommodation/choose_data/data_template.dart';
import 'package:pet_family_app/widgets/app_bar_return.dart';
import 'package:pet_family_app/widgets/app_button.dart';

class ChooseData extends StatefulWidget {
  const ChooseData({super.key});

  @override
  State<ChooseData> createState() => _ChooseDataState();
}

class _ChooseDataState extends State<ChooseData> {
  DateTime? _startDate;
  DateTime? _endDate;
  DateTime? _minEndDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            AppBarReturn(),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 60),
                  const Align(
                    alignment: Alignment.center,
                    child: Text(
                      'Escolha as datas:',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w200,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text('Início:'),
                  DataTemplate(
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                    onDateSelected: (date) {
                      setState(() {
                        _startDate = date;
                        _minEndDate = date.add(const Duration(days: 1));
                      });
                    },
                    hintText: 'Data de início',
                  ),
                  const SizedBox(height: 50),
                  const Text('Fim:'),
                  DataTemplate(
                    firstDate: _minEndDate,
                    initialDate: _minEndDate,
                    onDateSelected: (date) {
                      setState(() {
                        _endDate = date;
                      });
                    },
                  ),
                  const SizedBox(height: 40),
                  if (_startDate != null && _endDate != null)
                    AppButton(
                      onPressed: () {
                        context.go('/choose-service');
                      },
                      label: 'Próximo',
                      fontSize: 20,
                    )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
