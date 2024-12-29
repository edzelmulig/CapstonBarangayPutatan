import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:putatanapk/color_theme.dart';

class CustomTextField extends StatefulWidget {
  // PARAMETERS
  final TextEditingController controller;
  final FocusNode? currentFocusNode;
  final FocusNode? nextFocusNode;
  final TextInputType? keyBoardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?) validator;
  final bool isPassword;
  final bool isPasswordVisible;
  final String hintText;
  final int? minLines;
  final int? maxLines;
  final Icon? prefixIcon;

  // CONSTRUCTORS
  const CustomTextField({
    super.key,
    required this.controller,
    this.currentFocusNode,
    this.nextFocusNode,
    this.keyBoardType,
    this.inputFormatters,
    required this.validator,
    required this.isPassword,
    this.isPasswordVisible = true,
    required this.hintText,
    this.minLines,
    this.maxLines,
    this.prefixIcon,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _isPasswordVisible;

  @override
  void initState() {
    super.initState();
    _isPasswordVisible = !widget.isPasswordVisible;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      cursorColor: const Color(0xFF242424),
      controller: widget.controller,
      keyboardType: widget.keyBoardType,
      inputFormatters: widget.inputFormatters,
      focusNode: widget.currentFocusNode,
      validator: widget.validator,
      minLines: widget.minLines,
      maxLines: widget.maxLines,
      obscureText: widget.isPassword ? !_isPasswordVisible : _isPasswordVisible,
      decoration: InputDecoration(
        filled: true,
          fillColor: const Color(0xFFEFF0F3),
        hintText: widget.hintText,
        hintStyle: const TextStyle(
          color: Color(0xFF6c7687),
          fontWeight: FontWeight.normal,
          fontSize: 13,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(
            color: Color(0xFF242424),
            width: 1.5,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(
            color: Color(0xFFe91b4f),
            width: 2,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(
            color: Color(0xFFBDBDC7),
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(
            color: Color(0xFFe91b4f),
            width: 2.0,
          ),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: widget.prefixIcon != null
              ? MediaQuery.of(context).size.width * 0.1
              : 15,
          vertical: 15.0,
        ),
        prefixIcon: widget.prefixIcon,
        suffixIcon: widget.isPassword
            ? IconButton(
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
                icon: Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: Icon(
                    !_isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                ),
              )
            : null,
      ),
      onEditingComplete: () {
        if (widget.nextFocusNode != null) {
          FocusScope.of(context).requestFocus(widget.nextFocusNode);
        } else {
          FocusScope.of(context).nextFocus();
        }
      },
    );
  }
}
