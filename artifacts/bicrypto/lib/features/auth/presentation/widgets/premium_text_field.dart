import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/global_theme_extensions.dart';

class PremiumTextField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final String? hintText;
  final bool obscureText;
  final TextInputType keyboardType;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final bool enabled;
  final int maxLines;
  final VoidCallback? onTap;
  final bool readOnly;
  final FocusNode? focusNode;
  final Function(String)? onChanged;
  final bool showFloatingLabel;
  final Color? fillColor;
  final bool isDense;
  final List<TextInputFormatter>? inputFormatters;

  const PremiumTextField({
    super.key,
    required this.controller,
    required this.labelText,
    this.hintText,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.enabled = true,
    this.maxLines = 1,
    this.onTap,
    this.readOnly = false,
    this.focusNode,
    this.onChanged,
    this.showFloatingLabel = false,
    this.fillColor,
    this.isDense = false,
    this.inputFormatters,
  });

  @override
  State<PremiumTextField> createState() => _PremiumTextFieldState();
}

class _PremiumTextFieldState extends State<PremiumTextField> {
  bool _isFocused = false;
  bool _hasError = false;
  String? _currentError;

  @override
  void initState() {
    super.initState();
    widget.focusNode?.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    widget.focusNode?.removeListener(_onFocusChange);
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = widget.focusNode?.hasFocus ?? false;
    });

    if (_isFocused) {
      HapticFeedback.lightImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main text field container
        TextFormField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          obscureText: widget.obscureText,
          keyboardType: widget.keyboardType,
          enabled: widget.enabled,
          maxLines: widget.maxLines,
          onTap: widget.onTap,
          readOnly: widget.readOnly,
          inputFormatters: widget.inputFormatters,
          onChanged: (value) {
            widget.onChanged?.call(value);
            // Clear error when user starts typing
            if (_hasError && value.isNotEmpty) {
              setState(() {
                _hasError = false;
                _currentError = null;
              });
            }
          },
          validator: (value) {
            final error = widget.validator?.call(value);
            setState(() {
              _hasError = error != null;
              _currentError = error;
            });
            return null; // Always return null to prevent default error display
          },
          style: TextStyle(
            color: context.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.2,
          ),
          decoration: InputDecoration(
            hintText: widget.hintText ?? widget.labelText,
            hintStyle: TextStyle(
              color: context.textSecondary.withValues(alpha: 0.6),
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: widget.prefixIcon != null
                ? Icon(
                    widget.prefixIcon,
                    color: _isFocused
                        ? context.colors.primary
                        : context.textSecondary,
                    size: 20,
                  )
                : null,
            suffixIcon: widget.suffixIcon,
            filled: true,
            // Fixed: Use proper input background color from theme
            fillColor: widget.fillColor ?? context.inputBackground,
            contentPadding: EdgeInsets.symmetric(
              horizontal: widget.prefixIcon != null ? 16 : 18,
              vertical: widget.isDense ? 10 : 14, // More compact padding
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10), // Sharper, more modern radius
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: _hasError
                    ? context.colors.error.withValues(alpha: 0.3)
                    : context.borderColor,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color:
                    _hasError ? context.colors.error : context.colors.primary,
                width: 1.5, // Slightly thinner for modern look
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: context.colors.error,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: context.colors.error,
                width: 1.5,
              ),
            ),
            errorStyle: const TextStyle(height: 0), // Hide default error
          ),
        ),
        // Fixed height error container to prevent layout shifts
        SizedBox(
          height: 16, // More compact error area
          child: _currentError != null
              ? Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: context.colors.error,
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          _currentError!,
                          style: TextStyle(
                            color: context.colors.error,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                )
              : null,
        ),
      ],
    );
  }
}
