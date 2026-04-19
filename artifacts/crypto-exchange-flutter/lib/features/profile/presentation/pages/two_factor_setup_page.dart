import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/global_theme_extensions.dart';
import '../../../../injection/injection.dart';
import '../bloc/two_factor_setup_bloc.dart';

class TwoFactorSetupPage extends StatelessWidget {
  const TwoFactorSetupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<TwoFactorSetupBloc>(),
      child: const TwoFactorSetupView(),
    );
  }
}

class TwoFactorSetupView extends StatefulWidget {
  const TwoFactorSetupView({super.key});

  @override
  State<TwoFactorSetupView> createState() => _TwoFactorSetupViewState();
}

class _TwoFactorSetupViewState extends State<TwoFactorSetupView> {
  final PageController _pageController = PageController();
  final TextEditingController _phoneController = TextEditingController();
  final List<TextEditingController> _codeControllers =
      List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _codeFocusNodes =
      List.generate(6, (index) => FocusNode());

  String? _selectedMethod;
  String? _currentSecret;
  String? _currentQrCode;
  final bool _secretCopied = false;

  @override
  void dispose() {
    _pageController.dispose();
    _phoneController.dispose();
    for (var controller in _codeControllers) {
      controller.dispose();
    }
    for (var node in _codeFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '2FA Setup',
          style: context.h5,
        ),
      ),
      body: BlocConsumer<TwoFactorSetupBloc, TwoFactorSetupState>(
        listener: (context, state) {
          if (state is TwoFactorMethodSelectedState) {
            _selectedMethod = state.method;
            _pageController.nextPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          } else if (state is TwoFactorSecretGenerated) {
            _currentSecret = state.secret;
            _currentQrCode = state.qrCode;
            _pageController.nextPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          } else if (state is TwoFactorCodeVerified) {
            _pageController.nextPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          } else if (state is TwoFactorSetupCompleted) {
            _pageController.nextPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          } else if (state is TwoFactorSetupError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: context.priceDownColor,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        state.message,
                        style:
                            context.bodyM.copyWith(color: context.textPrimary),
                      ),
                    ),
                  ],
                ),
                backgroundColor: context.colors.surface,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: context.borderColor),
                ),
                elevation: 4,
                margin: const EdgeInsets.all(16),
                duration: const Duration(seconds: 4),
              ),
            );
          }
        },
        builder: (context, state) {
          return PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildMethodSelection(context, state),
              _buildSetupStep(context, state),
              _buildVerificationStep(context, state),
              _buildSuccessStep(context, state),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMethodSelection(
      BuildContext context, TwoFactorSetupState state) {
    return SingleChildScrollView(
      padding: context.horizontalPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          _buildStepIndicator(context, 1, 4),
          const SizedBox(height: 32),
          Text(
            'Choose Your Method',
            style: context.h3,
          ),
          const SizedBox(height: 8),
          Text(
            'Select how you want to receive your verification codes',
            style: context.bodyL.copyWith(color: context.textSecondary),
          ),
          const SizedBox(height: 32),
          _buildMethodCard(
            context: context,
            icon: Icons.smartphone,
            title: 'Authenticator App',
            subtitle: 'Use Google Authenticator, Authy, or similar app',
            isSelected: _selectedMethod == 'APP',
            onTap: () => setState(() => _selectedMethod = 'APP'),
          ),
          const SizedBox(height: 16),
          _buildMethodCard(
            context: context,
            icon: Icons.sms,
            title: 'SMS Messages',
            subtitle: 'Receive codes via text message',
            isSelected: _selectedMethod == 'SMS',
            onTap: () => setState(() => _selectedMethod = 'SMS'),
          ),
          const SizedBox(height: 16),
          _buildMethodCard(
            context: context,
            icon: Icons.email,
            title: 'Email',
            subtitle: 'Receive codes via email',
            isSelected: _selectedMethod == 'EMAIL',
            onTap: () => setState(() => _selectedMethod = 'EMAIL'),
          ),
          const SizedBox(height: 32),
          if (_selectedMethod == 'SMS') ...[
            Text(
              'Phone Number',
              style: context.labelL,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              style: context.bodyL,
              decoration: InputDecoration(
                hintText: '+1234567890',
                hintStyle: context.bodyL.copyWith(color: context.textTertiary),
                filled: true,
                fillColor: context.inputBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selectedMethod != null
                  ? () => _generateSecret(context)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: context.colors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: state is TwoFactorSecretGenerating
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      'Continue',
                      style: context.labelL.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSetupStep(BuildContext context, TwoFactorSetupState state) {
    return SingleChildScrollView(
      padding: context.horizontalPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          _buildStepIndicator(context, 2, 4),
          const SizedBox(height: 32),
          Text(
            'Setup ${_getMethodDisplayName(_selectedMethod ?? 'APP')}',
            style: context.h3,
          ),
          const SizedBox(height: 8),
          Text(
            _getSetupInstructions(_selectedMethod ?? 'APP'),
            style: context.bodyL.copyWith(color: context.textSecondary),
          ),
          const SizedBox(height: 32),
          if (_selectedMethod == 'APP' && _currentQrCode != null) ...[
            _buildQrCodeSection(context),
            const SizedBox(height: 24),
            _buildSecretSection(context),
          ] else if (_selectedMethod == 'SMS' ||
              _selectedMethod == 'EMAIL') ...[
            _buildCodeSentSection(context),
          ],
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _moveToVerification(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.colors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'I\'ve Set It Up',
                style: context.labelL.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationStep(
      BuildContext context, TwoFactorSetupState state) {
    return SingleChildScrollView(
      padding: context.horizontalPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          _buildStepIndicator(context, 3, 4),
          const SizedBox(height: 32),
          Text(
            'Verify Your Setup',
            style: context.h3,
          ),
          const SizedBox(height: 8),
          Text(
            'Enter the 6-digit code from your ${_getMethodDisplayName(_selectedMethod ?? 'APP').toLowerCase()}',
            style: context.bodyL.copyWith(color: context.textSecondary),
          ),
          const SizedBox(height: 32),
          _buildCodeInputFields(context),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: state is TwoFactorCodeVerifying
                  ? null
                  : () => _verifyCode(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.colors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: state is TwoFactorCodeVerifying
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      'Verify & Enable',
                      style: context.labelL.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessStep(BuildContext context, TwoFactorSetupState state) {
    List<String> recoveryCodes = [];
    if (state is TwoFactorSetupCompleted) {
      recoveryCodes = state.recoveryCodes;
    }

    return SingleChildScrollView(
      padding: context.horizontalPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          _buildStepIndicator(context, 4, 4),
          const SizedBox(height: 32),
          Center(
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: context.priceUpColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Icon(
                    Icons.check_circle,
                    color: context.priceUpColor,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Two-Factor Authentication Enabled!',
                  style: context.h4,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Your account is now more secure with 2FA',
                  style: context.bodyL.copyWith(color: context.textSecondary),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          if (recoveryCodes.isNotEmpty) ...[
            const SizedBox(height: 32),
            Container(
              width: double.infinity,
              padding: context.cardPadding,
              decoration: BoxDecoration(
                color: context.warningColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border:
                    Border.all(color: context.warningColor.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.warning_amber,
                        color: context.warningColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Recovery Codes',
                        style: context.labelL.copyWith(
                          color: context.warningColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Save these recovery codes in a safe place. You can use them to access your account if you lose your authenticator device.',
                    style: context.bodyS.copyWith(color: context.warningColor),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: context.cardBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: context.borderColor),
                    ),
                    child: Column(
                      children: recoveryCodes
                          .map((code) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4),
                                child: Text(
                                  code,
                                  style: context.bodyM.copyWith(
                                    fontFamily: 'monospace',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => _downloadRecoveryCodes(recoveryCodes),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: context.warningColor,
                        side: BorderSide(color: context.warningColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.download, size: 18),
                          const SizedBox(width: 8),
                          Text('Download Codes'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.colors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Complete Setup',
                style: context.labelL.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods continue in the next part...

  // Helper Methods
  Widget _buildStepIndicator(
      BuildContext context, int currentStep, int totalSteps) {
    return Row(
      children: List.generate(totalSteps, (index) {
        final stepNumber = index + 1;
        final isActive = stepNumber <= currentStep;
        final isCurrent = stepNumber == currentStep;

        return Expanded(
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color:
                        isActive ? context.colors.primary : context.borderColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              if (index < totalSteps - 1) const SizedBox(width: 8),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildMethodCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: context.cardPadding,
          decoration: BoxDecoration(
            color: isSelected
                ? context.colors.primary.withValues(alpha: 0.1)
                : context.cardBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? context.colors.primary : context.borderColor,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isSelected
                      ? context.colors.primary
                      : context.colors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(
                  icon,
                  color: isSelected ? Colors.white : context.colors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: context.labelL.copyWith(
                        color: context.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: context.bodyS.copyWith(
                        color: context.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: context.colors.primary,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _getMethodDisplayName(String method) {
    switch (method) {
      case 'APP':
        return 'Authenticator App';
      case 'SMS':
        return 'SMS';
      case 'EMAIL':
        return 'Email';
      default:
        return 'Unknown Method';
    }
  }

  String _getSetupInstructions(String method) {
    switch (method) {
      case 'APP':
        return 'Scan the QR code below with your authenticator app or enter the secret key manually.';
      case 'SMS':
        return 'We\'ll send a verification code to your registered phone number.';
      case 'EMAIL':
        return 'We\'ll send a verification code to your registered email address.';
      default:
        return 'Follow the instructions to set up two-factor authentication.';
    }
  }

  Widget _buildQrCodeSection(BuildContext context) {
    if (_selectedMethod != 'APP' || (_currentQrCode?.isEmpty ?? true)) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        const SizedBox(height: 24),
        Text(
          'Scan QR Code',
          style: context.labelL.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        Center(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: context.borderColor),
            ),
            child: (_currentQrCode?.isNotEmpty ?? false)
                ? Image.memory(
                    // Decode base64 data URL to display as image
                    base64Decode(_currentQrCode!
                        .replaceFirst('data:image/png;base64,', '')),
                    width: 200,
                    height: 200,
                    fit: BoxFit.contain,
                  )
                : Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: context.cardBackground,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildSecretSection(BuildContext context) {
    if (_selectedMethod != 'APP' || (_currentSecret?.isEmpty ?? true)) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        const SizedBox(height: 24),
        Text(
          'Manual Entry',
          style: context.labelL.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Text(
          'If you can\'t scan the QR code, enter this secret key manually:',
          style: context.bodyS.copyWith(color: context.textSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.cardBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.borderColor),
          ),
          child: Column(
            children: [
              Text(
                _currentSecret ?? '',
                style: context.bodyM.copyWith(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: () => _copyToClipboard(_currentSecret ?? ''),
                icon: Icon(Icons.copy, size: 18),
                label: Text('Copy Secret'),
                style: TextButton.styleFrom(
                  foregroundColor: context.colors.primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCodeSentSection(BuildContext context) {
    if (_selectedMethod == 'APP') {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          padding: context.cardPadding,
          decoration: BoxDecoration(
            color: context.colors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: context.colors.primary.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            children: [
              Icon(
                _selectedMethod == 'SMS' ? Icons.sms : Icons.email,
                color: context.colors.primary,
                size: 32,
              ),
              const SizedBox(height: 12),
              Text(
                'Code Sent',
                style: context.labelL.copyWith(
                  color: context.colors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _selectedMethod == 'SMS'
                    ? 'We\'ve sent a verification code to your phone number.'
                    : 'We\'ve sent a verification code to your email address.',
                style: context.bodyS.copyWith(
                  color: context.colors.primary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCodeInputFields(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(6, (index) {
        return SizedBox(
          width: 45,
          height: 55,
          child: TextField(
            controller: _codeControllers[index],
            focusNode: _codeFocusNodes[index],
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            style: context.h5.copyWith(fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              counterText: '',
              filled: true,
              fillColor: context.inputBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: context.borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: context.borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: context.colors.primary, width: 2),
              ),
            ),
            onChanged: (value) => _onCodeChanged(value, index),
          ),
        );
      }),
    );
  }

  void _generateSecret(BuildContext context) {
    context.read<TwoFactorSetupBloc>().add(
          TwoFactorSecretGenerateRequested(
            method: _selectedMethod ?? 'APP',
            phoneNumber: _phoneController.text,
          ),
        );
  }

  void _moveToVerification(BuildContext context) {
    // Navigation handled by PageView in BlocConsumer
    context.read<TwoFactorSetupBloc>().add(
          TwoFactorSecretGenerateRequested(
            method: _selectedMethod ?? 'APP',
            phoneNumber: _phoneController.text,
          ),
        );
  }

  void _verifyCode(BuildContext context) {
    final code = _codeControllers.map((c) => c.text).join();
    if (code.length == 6) {
      context.read<TwoFactorSetupBloc>().add(
            TwoFactorCodeVerifyRequested(
              secret: _currentSecret ?? '',
              code: code,
              method: _selectedMethod ?? 'APP',
            ),
          );
    }
  }

  void _downloadRecoveryCodes(List<String> codes) {
    // TODO: Implement download functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Recovery codes download feature coming soon',
          style: context.bodyM.copyWith(color: context.textPrimary),
        ),
        backgroundColor: context.colors.surface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: context.borderColor),
        ),
        elevation: 4,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _copyToClipboard(String text) {
    if (text.isEmpty) return;

    // Copy to clipboard
    Clipboard.setData(ClipboardData(text: text));

    // Show success toast with proper theme colors
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: context.priceUpColor,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Secret copied to clipboard',
                style: context.bodyM.copyWith(color: context.textPrimary),
              ),
            ),
          ],
        ),
        backgroundColor: context.colors.surface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: context.borderColor),
        ),
        elevation: 4,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _onCodeChanged(String value, int index) {
    if (value.isNotEmpty && index < 5) {
      _codeFocusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _codeFocusNodes[index - 1].requestFocus();
    }
  }
}
