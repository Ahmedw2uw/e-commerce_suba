import 'package:e_commerce/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class TextField extends StatefulWidget {
  final String title;
  final String hintText;
  final TextEditingController? controller;
  final bool obscureText;
  final bool showPasswordToggle;
  final String? Function(String?)? validator;
  final Color titleColor;
  final Color fillColor;
  final Color borderColor;
  final double titleFontSize;
  final IconData? suffixIcon;
  final VoidCallback? onIconPressed;
  final TextInputType? keyboardType;
  final bool readOnly;
  final bool showObscureTextToggle;

  const TextField({
    super.key,
    required this.title,
    required this.hintText,
    this.controller,
    this.obscureText = false,
    this.readOnly = false,
    this.validator,
    this.titleColor = AppColors.blue,
    this.fillColor = Colors.white,
    this.borderColor = AppColors.grey,
    this.titleFontSize = 18,
    this.suffixIcon = Icons.edit,
    this.onIconPressed,
    this.keyboardType,
    this.showPasswordToggle = false,
    this.showObscureTextToggle = false,
  });

  @override
  State<TextField> createState() => _TextFieldState();
}

class _TextFieldState extends State<TextField> {
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  void didUpdateWidget(covariant TextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.obscureText != widget.obscureText) {
      setState(() {
        _obscureText = widget.obscureText;
      });
    }
  }

  void _toggleObscureText() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          style: TextStyle(
            color: widget.titleColor,
            fontSize: widget.titleFontSize,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: widget.controller,
          validator: widget.validator,
          obscureText: widget.showObscureTextToggle ? _obscureText : widget.obscureText,
          readOnly: widget.readOnly,
          keyboardType: widget.keyboardType,
          decoration: InputDecoration(
            hintText: widget.hintText,
            filled: true,
            fillColor: widget.readOnly ? Colors.grey[100] : widget.fillColor,
            suffixIcon: _buildSuffixIcon(),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: widget.borderColor, width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: widget.borderColor, width: 2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: widget.borderColor, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          style: TextStyle(color: widget.readOnly ? Colors.grey[600] : Colors.black87),
        ),
      ],
    );
  }

  Widget? _buildSuffixIcon() {
    if (widget.showObscureTextToggle && widget.obscureText) {
      return IconButton(
        onPressed: _toggleObscureText,
        icon: Icon(
          _obscureText ? Icons.visibility_off : Icons.visibility,
          color: widget.borderColor,
        ),
        tooltip: _obscureText ? 'Show password' : 'Hide password',
      );
    }

    if (widget.showPasswordToggle && !widget.readOnly) {
      return IconButton(
        onPressed: widget.onIconPressed,
        icon: Icon(widget.suffixIcon, color: widget.borderColor),
      );
    }

    if (widget.readOnly && widget.suffixIcon != null) {
      return Icon(
        widget.suffixIcon,
        color: widget.borderColor.withOpacity(0.5),
      );
    }
    if (widget.suffixIcon != null && !widget.showObscureTextToggle) {
      return IconButton(
        onPressed: widget.onIconPressed,
        icon: Icon(widget.suffixIcon, color: widget.borderColor),
      );
    }

    return null;
  }
}