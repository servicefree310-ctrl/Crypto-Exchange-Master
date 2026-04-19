import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/global_theme_extensions.dart';
import '../bloc/transfer_bloc.dart';
import '../bloc/transfer_event.dart';
import '../bloc/transfer_state.dart';

class RecipientInputWidget extends StatefulWidget {
  final String sourceCurrency;
  final double availableBalance;

  const RecipientInputWidget({
    super.key,
    required this.sourceCurrency,
    required this.availableBalance,
  });

  @override
  State<RecipientInputWidget> createState() => _RecipientInputWidgetState();
}

class _RecipientInputWidgetState extends State<RecipientInputWidget> {
  late TextEditingController _recipientController;
  bool _isValidating = false;
  bool? _recipientExists;

  @override
  void initState() {
    super.initState();
    _recipientController = TextEditingController();
  }

  @override
  void dispose() {
    _recipientController.dispose();
    super.dispose();
  }

  String? _pendingValidation;
  String? _validationError;

  void _onRecipientChanged(String value) {
    if (value.trim().isEmpty) {
      setState(() {
        _recipientExists = null;
        _isValidating = false;
        _validationError = null;
      });
      return;
    }

    // Basic format check before making API call
    if (value.length < 10 || !value.contains('-')) {
      setState(() {
        _recipientExists = null;
        _isValidating = false;
        _validationError = null;
      });
      return;
    }

    setState(() {
      _isValidating = true;
      _validationError = null;
    });

    // Debounce: wait 500ms before validating via API
    _pendingValidation = value;
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted && _recipientController.text == value && _pendingValidation == value) {
        // Dispatch to BLoC which calls the real validation API
        context
            .read<TransferBloc>()
            .add(RecipientChanged(recipientId: value));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TransferBloc, TransferState>(
      listener: (context, state) {
        if (state is ClientRecipientValidatedState) {
          setState(() {
            _isValidating = false;
            _recipientExists = true;
            _validationError = null;
          });
        } else if (state is SourceCurrencySelectedState &&
            state.recipientError != null) {
          setState(() {
            _isValidating = false;
            _recipientExists = false;
            _validationError = state.recipientError;
          });
        }
      },
      child: SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Enter Recipient Details',
            style: context.h5.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Enter the recipient\'s user ID to send funds',
            style: context.bodyS.copyWith(
              color: context.textSecondary,
            ),
          ),
          const SizedBox(height: 16),

          // Source Info Card - Compact version
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: context.colors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: context.colors.primary.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: context.colors.primary,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Sending: ${widget.sourceCurrency.toUpperCase()} • Available: ${widget.availableBalance.toStringAsFixed(2)}',
                    style: context.labelM.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Recipient Input
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Recipient User ID',
                style: context.labelL.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: context.isDarkMode
                      ? context.colors.surface
                      : context.colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _recipientExists == true
                        ? context.priceUpColor
                        : _recipientExists == false
                            ? context.priceDownColor
                            : context.borderColor.withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
                child: TextField(
                  controller: _recipientController,
                  onChanged: _onRecipientChanged,
                  style: context.bodyL,
                  decoration: InputDecoration(
                    hintText: 'Enter recipient\'s user ID',
                    hintStyle: context.bodyL.copyWith(
                      color: context.textTertiary,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(14),
                    suffixIcon: _isValidating
                        ? Padding(
                            padding: const EdgeInsets.all(12),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    context.colors.primary),
                              ),
                            ),
                          )
                        : _recipientExists == true
                            ? Icon(
                                Icons.check_circle,
                                color: context.priceUpColor,
                              )
                            : _recipientExists == false
                                ? Icon(
                                    Icons.error,
                                    color: context.priceDownColor,
                                  )
                                : null,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Validation Message
              if (_recipientExists == true)
                Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: context.priceUpColor,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Recipient found and verified',
                      style: context.labelS.copyWith(
                        color: context.priceUpColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                )
              else if (_recipientExists == false)
                Row(
                  children: [
                    Icon(
                      Icons.error,
                      color: context.priceDownColor,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _validationError ?? 'Recipient not found. Please check the user ID.',
                        style: context.labelS.copyWith(
                          color: context.priceDownColor,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                  ],
                ),
            ],
          ),

          const SizedBox(height: 16),

          // Info Card - Compact version
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: context.isDarkMode
                  ? context.colors.surface.withValues(alpha: 0.5)
                  : context.colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: context.borderColor.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  color: context.colors.primary,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'User transfers include 1% fee (min 0.01 ${widget.sourceCurrency.toUpperCase()}).',
                    style: context.labelS.copyWith(
                      color: context.textSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Continue Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _recipientExists == true
                  ? () {
                      // Move to amount input step
                      context
                          .read<TransferBloc>()
                          .add(const ContinueToAmountRequested());
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: context.colors.primary,
                disabledBackgroundColor:
                    context.colors.onSurface.withValues(alpha: 0.12),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                _recipientExists == true
                    ? 'Continue to Amount'
                    : 'Enter Valid Recipient',
                style: context.labelL.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          // Add extra space for keyboard
          const SizedBox(height: 100),
        ],
      ),
    ),
    );
  }
}
