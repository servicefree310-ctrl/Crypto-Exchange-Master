import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../../core/theme/global_theme_extensions.dart';
import '../../../../../core/widgets/countdown_timer.dart';
import '../../bloc/spot_deposit_bloc.dart';
import '../../bloc/spot_deposit_state.dart';
import '../../bloc/spot_deposit_event.dart';

class SpotDepositAddressWidget extends StatefulWidget {
  const SpotDepositAddressWidget({
    super.key,
    required this.currency,
    required this.network,
    required this.onContinue,
  });

  final String currency;
  final String network;
  final VoidCallback onContinue;

  @override
  State<SpotDepositAddressWidget> createState() =>
      _SpotDepositAddressWidgetState();
}

class _SpotDepositAddressWidgetState extends State<SpotDepositAddressWidget>
    with SingleTickerProviderStateMixin {
  bool _showTransactionInput = false;
  bool _isSubmitting = false;
  bool _hasNavigated = false;
  String? _submittedTransactionHash;
  final TextEditingController _transactionController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _transactionController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onSentFunds() {
    // Only show transaction input, don't trigger navigation
    setState(() {
      _showTransactionInput = true;
    });
  }

  void _submitTransaction() {
    final transactionHash = _transactionController.text.trim();

    // Validate input
    if (transactionHash.isEmpty) {
      _showErrorSnackBar('Please enter transaction hash');
      return;
    }

    // Basic validation for transaction hash format
    if (transactionHash.length < 10) {
      _showErrorSnackBar('Invalid transaction hash format');
      return;
    }

    // Prevent duplicate submissions
    if (_isSubmitting) {
      _showWarningSnackBar('Transaction is being processed...');
      return;
    }

    if (_submittedTransactionHash == transactionHash) {
      _showWarningSnackBar('This transaction has already been submitted');
      return;
    }

    // Clear any previous snackbars
    ScaffoldMessenger.of(context).clearSnackBars();

    setState(() {
      _isSubmitting = true;
      _submittedTransactionHash = transactionHash;
    });

    context.read<SpotDepositBloc>().add(
          SpotDepositCreated(
            widget.currency,
            widget.network,
            transactionHash,
          ),
        );
  }

  void _copyToClipboard(BuildContext context, String text, String message) {
    Clipboard.setData(ClipboardData(text: text));
    _showSuccessSnackBar(message);
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: context.priceUpColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.check_circle_outline_rounded,
                color: context.priceUpColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: context.bodyS.copyWith(
                  color: context.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: context.cardBackground,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: context.borderColor.withValues(alpha: 0.2),
          ),
        ),
        margin: const EdgeInsets.all(12),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: context.priceDownColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.error_outline_rounded,
                color: context.priceDownColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: context.bodyS.copyWith(
                  color: context.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: context.cardBackground,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: context.borderColor.withValues(alpha: 0.2),
          ),
        ),
        margin: const EdgeInsets.all(12),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showWarningSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: context.warningColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.warning_rounded,
                color: context.warningColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: context.bodyS.copyWith(
                  color: context.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: context.cardBackground,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: context.borderColor.withValues(alpha: 0.2),
          ),
        ),
        margin: const EdgeInsets.all(12),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SpotDepositBloc, SpotDepositState>(
      listener: (context, state) {
        // Handle loading state
        if (state is SpotDepositLoading && _isSubmitting) {
          _showWarningSnackBar('Processing your transaction...');
        }

        // Handle successful transaction submission
        else if (state is SpotDepositTransactionCreated) {
          setState(() {
            _isSubmitting = false;
          });
          _showSuccessSnackBar(
              'Transaction submitted successfully! Starting verification...');
          // Navigate to next step after a short delay
          if (!_hasNavigated) {
            _hasNavigated = true;
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted) {
                widget.onContinue();
              }
            });
          }
        }

        // Handle verification states
        else if (state is SpotDepositVerifying) {
          _showWarningSnackBar(state.message.isNotEmpty
              ? state.message
              : 'Verifying your deposit...');
        } else if (state is SpotDepositVerified) {
          setState(() {
            _isSubmitting = false;
          });
          _showSuccessSnackBar(
              'Deposit verified successfully! Funds will be credited shortly.');
          // Navigate after verification
          if (!_hasNavigated) {
            _hasNavigated = true;
            Future.delayed(const Duration(seconds: 1), () {
              if (mounted) {
                widget.onContinue();
              }
            });
          }
        }

        // Handle errors
        else if (state is SpotDepositError) {
          setState(() {
            _isSubmitting = false;
            // Reset submitted hash on error so user can try again
            _submittedTransactionHash = null;
          });
          _showErrorSnackBar(state.failure.message.isNotEmpty
              ? state.failure.message
              : 'Failed to process transaction. Please try again.');
        } else if (state is SpotDepositNetworkError) {
          setState(() {
            _isSubmitting = false;
            _submittedTransactionHash = null;
          });
          _showErrorSnackBar(state.message.isNotEmpty
              ? state.message
              : 'Network error. Please check your connection and try again.');
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.blue.withValues(alpha: 0.08),
                    Colors.blue.withValues(alpha: 0.03),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.blue.withValues(alpha: 0.15),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _showTransactionInput
                          ? Icons.tag_rounded
                          : Icons.qr_code_2_rounded,
                      color: Colors.blue,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _showTransactionInput
                              ? 'Enter Transaction Hash'
                              : 'Send ${widget.currency}',
                          style: context.bodyS.copyWith(
                            color: Colors.blue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _showTransactionInput
                              ? 'Provide transaction hash to complete deposit'
                              : 'To the address below on ${widget.network} network',
                          style: TextStyle(
                            color: context.textSecondary,
                            fontSize: 11,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Content
          Expanded(
            child: SingleChildScrollView(
              child: BlocBuilder<SpotDepositBloc, SpotDepositState>(
                builder: (context, state) {
                  if (state is SpotDepositAddressGenerated) {
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        children: [
                          // Countdown Timer
                          ScaleTransition(
                            scale: _scaleAnimation,
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: context.warningColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: context.warningColor.withValues(alpha: 0.2),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.timer_outlined,
                                    color: context.warningColor,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: CountdownTimer(
                                      initialTimeInSeconds:
                                          30 * 60, // 30 minutes
                                      onExpire: () {
                                        _showErrorSnackBar(
                                            'Deposit session expired. Please start a new deposit.');
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          if (!_showTransactionInput) ...[
                            // QR Code
                            ScaleTransition(
                              scale: _scaleAnimation,
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: context.colors.onSurface
                                          .withValues(alpha: 0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    QrImageView(
                                      data: state.address.address,
                                      version: QrVersions.auto,
                                      size: 180.0,
                                      backgroundColor: Colors.white,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Scan with wallet app',
                                      style: context.bodyS.copyWith(
                                        color: context.textTertiary,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Address Container
                            _buildAddressContainer(state),

                            // Tag/Memo (if available)
                            if (state.address.tag != null) ...[
                              const SizedBox(height: 12),
                              _buildTagContainer(state),
                            ],

                            const SizedBox(height: 16),

                            // Important Notes
                            _buildImportantNotes(),

                            const SizedBox(height: 20),

                            // Action Button
                            _buildActionButton(),
                          ] else ...[
                            // Transaction Input
                            _buildTransactionInput(),
                          ],
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressContainer(SpotDepositAddressGenerated state) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.borderColor.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Deposit Address',
                style: context.bodyM.copyWith(
                  color: context.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              IconButton(
                onPressed: () => _copyToClipboard(
                  context,
                  state.address.address,
                  'Address copied!',
                ),
                icon: Icon(
                  Icons.copy_rounded,
                  color: context.colors.primary,
                  size: 18,
                ),
                tooltip: 'Copy address',
                constraints: const BoxConstraints(
                  minWidth: 32,
                  minHeight: 32,
                ),
                padding: const EdgeInsets.all(4),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SelectableText(
            state.address.address,
            style: context.bodyS.copyWith(
              fontFamily: 'monospace',
              fontSize: 11,
              color: context.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagContainer(SpotDepositAddressGenerated state) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.warningColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.warningColor.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_rounded,
                color: context.warningColor,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'Tag/Memo Required',
                style: context.bodyS.copyWith(
                  color: context.warningColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => _copyToClipboard(
                  context,
                  state.address.tag!,
                  'Tag copied!',
                ),
                icon: Icon(
                  Icons.copy_rounded,
                  color: context.warningColor,
                  size: 16,
                ),
                tooltip: 'Copy tag',
                constraints: const BoxConstraints(
                  minWidth: 28,
                  minHeight: 28,
                ),
                padding: const EdgeInsets.all(2),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Tag: ${state.address.tag}',
            style: context.bodyS.copyWith(
              fontFamily: 'monospace',
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Must include this tag when sending',
            style: TextStyle(
              color: context.warningColor.withValues(alpha: 0.8),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImportantNotes() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.priceDownColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.priceDownColor.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.error_outline_rounded,
                color: context.priceDownColor,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'Important',
                style: context.bodyS.copyWith(
                  color: context.priceDownColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '• Send only ${widget.currency} on ${widget.network} network\n'
            '• Wrong token = permanent loss\n'
            '• Check minimum deposit amount\n'
            '• Address expires in 30 minutes',
            style: TextStyle(
              color: context.textSecondary,
              fontSize: 10,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _onSentFunds,
        style: ElevatedButton.styleFrom(
          backgroundColor: context.priceUpColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'I\'ve Sent the Funds',
              style: context.bodyS.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionInput() {
    return Column(
      children: [
        // Warning Box
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: context.priceDownColor.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: context.priceDownColor.withValues(alpha: 0.1),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.warning_rounded,
                color: context.priceDownColor,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                'Transaction Hash Required',
                style: context.bodyM.copyWith(
                  color: context.priceDownColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'You must provide the transaction hash to complete your deposit. Without it, we cannot verify your transaction.',
                style: context.bodyS.copyWith(
                  color: context.textSecondary,
                  fontSize: 11,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Transaction Input Field
        Container(
          decoration: BoxDecoration(
            color: context.cardBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: context.borderColor.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 12, right: 12, top: 12),
                child: Text(
                  'Transaction Hash',
                  style: context.bodyS.copyWith(
                    color: context.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              TextField(
                controller: _transactionController,
                enabled: !_isSubmitting,
                style: context.bodyM.copyWith(
                  fontFamily: 'monospace',
                  color: context.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: '0x1234567890abcdef...',
                  hintStyle: context.bodyS.copyWith(
                    color: context.textTertiary,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Action Buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _isSubmitting
                    ? null
                    : () {
                        setState(() {
                          _showTransactionInput = false;
                        });
                      },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: BorderSide(
                    color: context.borderColor.withValues(alpha: 0.2),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.arrow_back_ios_rounded,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Back',
                      style: context.bodyS.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitTransaction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                  disabledBackgroundColor: context.borderColor.withValues(alpha: 0.2),
                ),
                child: _isSubmitting
                    ? SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            context.textPrimary,
                          ),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Submit Transaction',
                            style: context.bodyS.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            Icons.send_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
