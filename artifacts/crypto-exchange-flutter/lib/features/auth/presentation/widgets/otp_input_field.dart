import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/global_theme_extensions.dart';

/// A widget that displays a 6-digit OTP input field
/// with auto-focus, auto-submit, and paste support
class OtpInputField extends StatefulWidget {
  final Function(String) onCompleted;
  final Function(String)? onChanged;
  final bool enabled;
  final String? errorText;

  const OtpInputField({
    super.key,
    required this.onCompleted,
    this.onChanged,
    this.enabled = true,
    this.errorText,
  });

  @override
  State<OtpInputField> createState() => _OtpInputFieldState();
}

class _OtpInputFieldState extends State<OtpInputField> {
  final List<TextEditingController> _controllers =
      List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes =
      List.generate(6, (index) => FocusNode());

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onChanged(int index, String value) {
    if (value.length > 1) {
      // Handle paste
      _handlePaste(value, index);
      return;
    }

    if (value.isNotEmpty) {
      // Move to next field
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        // Last field, check if complete
        _focusNodes[index].unfocus();
        _checkCompletion();
      }
    }

    // Notify parent of change
    if (widget.onChanged != null) {
      widget.onChanged!(_getOtpValue());
    }
  }

  void _onKeyEvent(int index, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace) {
      if (_controllers[index].text.isEmpty && index > 0) {
        // Move to previous field on backspace if current is empty
        _controllers[index - 1].clear();
        _focusNodes[index - 1].requestFocus();
      }
    }
  }

  void _handlePaste(String pastedText, int startIndex) {
    // Remove any non-digit characters
    final digits = pastedText.replaceAll(RegExp(r'\D'), '');

    // Fill the fields starting from the current index
    for (int i = 0; i < digits.length && (startIndex + i) < 6; i++) {
      _controllers[startIndex + i].text = digits[i];
    }

    // Focus the last filled field or the 6th field
    final lastIndex = (startIndex + digits.length - 1).clamp(0, 5);
    _focusNodes[lastIndex].requestFocus();

    // Check if OTP is complete after paste
    _checkCompletion();

    // Notify parent of change
    if (widget.onChanged != null) {
      widget.onChanged!(_getOtpValue());
    }
  }

  String _getOtpValue() {
    return _controllers.map((c) => c.text).join();
  }

  void _checkCompletion() {
    final otp = _getOtpValue();
    if (otp.length == 6) {
      widget.onCompleted(otp);
    }
  }

  void clear() {
    for (var controller in _controllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(
            6,
            (index) => _buildOtpBox(context, index),
          ),
        ),
        if (widget.errorText != null) ...[
          const SizedBox(height: 8),
          Text(
            widget.errorText!,
            style: TextStyle(
              color: context.colors.error,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildOtpBox(BuildContext context, int index) {
    return SizedBox(
      width: 48,
      height: 56,
      child: KeyboardListener(
        focusNode: FocusNode(),
        onKeyEvent: (event) => _onKeyEvent(index, event),
        child: TextField(
          controller: _controllers[index],
          focusNode: _focusNodes[index],
          enabled: widget.enabled,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 1,
          style: context.textTheme.headlineSmall?.copyWith(
            color: context.textPrimary,
            fontWeight: FontWeight.bold,
          ),
          decoration: InputDecoration(
            counterText: '',
            filled: true,
            fillColor: context.cardBackground,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: context.borderColor,
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: context.colors.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: context.colors.error,
                width: 1.5,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: context.colors.error,
                width: 2,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: context.borderColor.withValues(alpha: 0.5),
                width: 1.5,
              ),
            ),
            contentPadding: EdgeInsets.zero,
          ),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(1),
          ],
          onChanged: (value) => _onChanged(index, value),
        ),
      ),
    );
  }
}
