import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_firebase_realtime_app/src/config/app_colors.dart';

class CustomTextFormField extends StatefulWidget {
  final IconData? icon;
  final Color? iconColor;
  final String label;
  final bool obscureText;
  final List<TextInputFormatter>? inputFormatters;
  final String? initialValue;
  final bool readOnly;
  final String? Function(String?)? validator;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final VoidCallback? onTap;
  final bool isEditing;
  final void Function(String)? onChanged;

  const CustomTextFormField({
    super.key,
    this.icon,
    this.iconColor,
    required this.label,
    this.obscureText = false,
    this.inputFormatters,
    this.initialValue,
    this.readOnly = false,
    this.validator,
    this.controller,
    this.keyboardType,
    this.textInputAction = TextInputAction.next,
    this.onTap,
    this.isEditing = false,
    this.onChanged,
  });

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  late final ValueNotifier<bool> _isObscure;
  Color editColor = Colors.orange;

  @override
  void initState() {
    super.initState();
    _controller =
        widget.controller ??
        TextEditingController(text: widget.initialValue ?? '');

    _focusNode = FocusNode();
    _isObscure = ValueNotifier(widget.obscureText);

    _focusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    if (widget.controller == null) _controller.dispose();
    _focusNode.dispose();
    _isObscure.dispose();
    super.dispose();
  }

  /// ==== FORMATADOR PARA ACEITAR VÍRGULAS ====
  TextInputFormatter decimalCommaFormatter() {
    return TextInputFormatter.withFunction((oldValue, newValue) {
      String v = newValue.text.replaceAll(',', '.');

      // permite apenas 0-9 , .
      final reg = RegExp(r'^[0-9]*[,.]?[0-9]*$');
      if (!reg.hasMatch(newValue.text)) {
        return oldValue;
      }

      return newValue.copyWith(
        text: v.replaceAll('.', ','),
        selection: newValue.selection,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<TextInputFormatter> mergedFormatters = [
      decimalCommaFormatter(),
      ...?widget.inputFormatters,
    ];

    final bool isFocused = _focusNode.hasFocus;
    final borderColor = widget.isEditing ? editColor : Colors.grey.shade300;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ValueListenableBuilder<bool>(
        valueListenable: _isObscure,
        builder: (context, value, _) {
          return TextFormField(
            controller: _controller,
            focusNode: _focusNode,
            readOnly: widget.readOnly,
            obscureText: value,
            validator: widget.validator,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            onTap: widget.onTap,
            onChanged: widget.onChanged,
            style: TextStyle(
              fontSize: 14,
              color: isFocused ? Colors.black : Colors.black87,
              fontWeight: isFocused ? FontWeight.bold : FontWeight.normal,
            ),
            inputFormatters: mergedFormatters,
            decoration: InputDecoration(
              prefixIcon: CircleAvatar(
                backgroundColor: Colors.teal.withValues(alpha: 0.1),
                child: Icon(widget.icon, color: Colors.teal),
              ),
              suffixIcon: widget.obscureText
                  ? IconButton(
                      onPressed: () => _isObscure.value = !_isObscure.value,
                      icon: Icon(
                        value ? Icons.visibility : Icons.visibility_off,
                        color: widget.iconColor ?? AppColors.foregroundIcon,
                        size: 32,
                      ),
                    )
                  : null,
              labelText: widget.label,
              labelStyle: TextStyle(
                color: widget.isEditing ? editColor : Colors.grey.shade600,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),

              filled: true,
              fillColor: Colors.white,

              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(color: borderColor),
              ),

              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(color: borderColor, width: 2),
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
