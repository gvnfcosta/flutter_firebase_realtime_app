import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_firebase_realtime_app/src/config/app_colors.dart';

class CustomTextFormField extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String label;
  final String nome;
  final bool obscureText;
  final List<TextInputFormatter>? inputFormatters;
  final String? initialValue;
  final bool readOnly;
  final String? Function(String?)? validator;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final VoidCallback? onTap;
  final void Function(String)? onChanged;

  const CustomTextFormField({
    super.key,
    this.icon = Icons.person,
    this.iconColor,
    required this.label,
    this.nome = '',
    this.obscureText = false,
    this.inputFormatters,
    this.initialValue,
    this.readOnly = false,
    this.validator,
    this.controller,
    this.keyboardType,
    this.onTap,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isObscure = ValueNotifier<bool>(obscureText);
    final focusNode = FocusNode();

    // Initialize controller with initialValue if provided and no controller is set
    final effectiveController =
        controller ?? TextEditingController(text: initialValue);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ValueListenableBuilder<bool>(
        valueListenable: isObscure,
        builder: (context, value, _) {
          debugPrint(
            'CustomTextField: effectiveController.text = ${effectiveController.text}',
          );
          return TextFormField(
            controller: effectiveController,
            focusNode: focusNode,
            readOnly: readOnly,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
            inputFormatters: inputFormatters,
            obscureText: value,
            validator: validator,
            keyboardType: keyboardType,
            onTap: onTap,
            onChanged: onChanged,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, size: 22, color: AppColors.foregroundIcon),
              suffixIcon: obscureText
                  ? IconButton(
                      onPressed: () {
                        isObscure.value = !isObscure.value;
                      },
                      icon: Icon(
                        value ? Icons.visibility : Icons.visibility_off,
                        color: iconColor ?? AppColors.foregroundIcon,
                        size: 32,
                      ),
                    )
                  : null,
              labelText: label,
              labelStyle: TextStyle(
                color: focusNode.hasFocus ? AppColors.primary : Colors.grey,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              filled: true,
              fillColor: Colors.white,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(color: Colors.grey.shade400, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: const BorderSide(color: Colors.red, width: 2),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: const BorderSide(color: Colors.red, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 18.0,
                horizontal: 16.0,
              ),
            ),
          );
        },
      ),
    );
  }
}
