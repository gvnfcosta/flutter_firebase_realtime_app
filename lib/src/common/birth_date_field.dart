import 'package:flutter/material.dart';
import 'package:flutter_firebase_realtime_app/src/config/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class BirthDateField extends StatefulWidget {
  final TextEditingController controller;
  const BirthDateField({super.key, required this.controller});

  @override
  State<BirthDateField> createState() => _BirthDateFieldState();
}

class _BirthDateFieldState extends State<BirthDateField> {
  final _dateFormat = DateFormat('dd/MM/yyyy');
  final _dateMask = MaskTextInputFormatter(
    mask: '##/##/####',
    filter: {'#': RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  int _calculateAge(String birthDateString) {
    try {
      final birthDate = _dateFormat.parseStrict(birthDateString);
      final now = DateTime.now();
      int age = now.year - birthDate.year;
      if (now.month < birthDate.month ||
          (now.month == birthDate.month && now.day < birthDate.day)) {
        age--;
      }
      return age;
    } catch (e) {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 350,
          child: TextFormField(
            controller: widget.controller,
            keyboardType: TextInputType.number,
            inputFormatters: [_dateMask],
            decoration: InputDecoration(
              labelText: 'Data de Nascimento',
              border: const OutlineInputBorder(),
              suffixIcon: Icon(
                Icons.date_range,
                color: AppColors.foregroundIcon,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Informe a data de nascimento';
              }
              try {
                final parsedDate = _dateFormat.parseStrict(value);
                if (parsedDate.year < 1900 ||
                    parsedDate.isAfter(DateTime.now())) {
                  return 'Data inválida';
                }
                return null;
              } catch (e) {
                return 'Data inválida (use dd/mm/aaaa)';
              }
            },
            onChanged: (value) {
              if (value.length == 10) {
                try {
                  _dateFormat.parseStrict(value);
                  setState(() {}); // atualiza idade
                } catch (_) {}
              } else {
                setState(() {}); // limpa idade se apagar
              }
            },
          ),
        ),
        const SizedBox(width: 8),
        Text(
          widget.controller.text.length == 10
              ? '${_calculateAge(widget.controller.text)} anos'
              : '',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.blueGrey,
          ),
        ),
      ],
    );
  }
}
