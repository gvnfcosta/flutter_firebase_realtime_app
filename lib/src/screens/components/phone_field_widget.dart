import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import '../../common/custom_text_form_field.dart';

class PhoneFieldWidget extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  const PhoneFieldWidget({super.key, required this.controller, this.onChanged});

  @override
  Widget build(BuildContext context) {
    final phoneFormatter = MaskTextInputFormatter(
      mask: '(##) #####-####',
      filter: {'#': RegExp(r'[0-9]')},
      type: MaskAutoCompletionType.lazy,
    );

    return CustomTextFormField(
      label: 'Telefone',
      controller: controller,
      isEditing: true,
      icon: Icons.phone,
      keyboardType: TextInputType.phone,
      inputFormatters: [phoneFormatter],

      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Campo obrigatório';
        }
        // Remove caracteres da máscara para contar dígitos
        final digitsOnly = value.replaceAll(RegExp(r'[^0-9]'), '');
        if (digitsOnly.length != 11) {
          return 'Telefone inválido (use (xx) xxxxx-xxxx)';
        }
        return null;
      },
      onChanged: onChanged,
    );
  }
}
