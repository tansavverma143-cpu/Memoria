import 'package:flutter/material.dart';
import 'package:memoria/constants/constants.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hintText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final bool isPassword;
  final bool isReadOnly;
  final TextInputType? keyboardType;
  final int maxLines;
  final int minLines;
  final String? Function(String?)? validator;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final bool showCounter;
  final int? maxLength;
  
  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.isPassword = false,
    this.isReadOnly = false,
    this.keyboardType,
    this.maxLines = 1,
    this.minLines = 1,
    this.validator,
    this.onTap,
    this.onChanged,
    this.showCounter = false,
    this.maxLength,
  });
  
  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              widget.label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        
        TextFormField(
          controller: widget.controller,
          obscureText: widget.isPassword && _obscureText,
          readOnly: widget.isReadOnly,
          keyboardType: widget.keyboardType,
          maxLines: widget.maxLines,
          minLines: widget.minLines,
          maxLength: widget.maxLength,
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
            ),
            prefixIcon: widget.prefixIcon != null
                ? Icon(
                    widget.prefixIcon,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  )
                : null,
            suffixIcon: _buildSuffixIcon(),
            filled: true,
            fillColor: Theme.of(context).cardColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: Theme.of(context).dividerColor,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: Theme.of(context).dividerColor,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: AppConstants.royalBlue,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 2,
              ),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 20,
              vertical: widget.maxLines > 1 ? 16 : 0,
            ),
            counterText: widget.showCounter ? null : '',
          ),
          validator: widget.validator,
          onTap: widget.onTap,
          onChanged: widget.onChanged,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
  
  Widget? _buildSuffixIcon() {
    if (widget.isPassword) {
      return IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_off : Icons.visibility,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      );
    }
    
    if (widget.suffixIcon != null) {
      return Icon(
        widget.suffixIcon,
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
      );
    }
    
    return null;
  }
}