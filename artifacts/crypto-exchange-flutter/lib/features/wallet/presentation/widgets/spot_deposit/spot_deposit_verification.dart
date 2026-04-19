import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/spot_deposit_bloc.dart';
import '../../bloc/spot_deposit_state.dart';
import '../../bloc/spot_deposit_event.dart';

class SpotDepositVerification extends StatelessWidget {
  const SpotDepositVerification({
    super.key,
    required this.transactionId,
    required this.currency,
    required this.network,
    required this.onComplete,
  });

  final String? transactionId;
  final String currency;
  final String network;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Deposit Verification'),
        backgroundColor: colorScheme.surface,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Header section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Verification in Progress',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'We are verifying your $currency deposit on $network network',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Content section (scrollable)
              Expanded(
                child: SingleChildScrollView(
                  child: BlocBuilder<SpotDepositBloc, SpotDepositState>(
                    builder: (context, state) {
                      if (state is SpotDepositVerifying) {
                        return _buildVerifyingState(context, state);
                      } else if (state is SpotDepositVerified) {
                        return _buildVerifiedState(context, state);
                      } else if (state is SpotDepositNetworkError) {
                        return _buildErrorState(context, state);
                      }

                      return _buildInitialState(context);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInitialState(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircularProgressIndicator(),
        const SizedBox(height: 16),
        Text(
          'Initializing verification...',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildVerifyingState(
      BuildContext context, SpotDepositVerifying state) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        // Status card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer.withValues(alpha: 
              theme.brightness == Brightness.dark ? 0.2 : 0.3,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colorScheme.primary.withValues(alpha: 
                theme.brightness == Brightness.dark ? 0.3 : 0.5,
              ),
            ),
          ),
          child: Column(
            children: [
              CircularProgressIndicator(
                color: colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Checking Transaction',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                state.message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Transaction info
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.brightness == Brightness.dark
                ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)
                : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Transaction Details',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              _buildInfoRow(context, 'Transaction ID:', transactionId ?? 'N/A'),
              _buildInfoRow(context, 'Currency:', currency),
              _buildInfoRow(context, 'Network:', network),
              _buildInfoRow(context, 'Status:', 'Pending Verification'),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Instructions
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.brightness == Brightness.dark
                ? colorScheme.secondaryContainer.withValues(alpha: 0.15)
                : colorScheme.secondaryContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colorScheme.secondary.withValues(alpha: 
                theme.brightness == Brightness.dark ? 0.3 : 0.5,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.schedule, color: colorScheme.secondary),
                  const SizedBox(width: 8),
                  Text(
                    'Please Wait',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSecondaryContainer,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'We check the blockchain every 15 seconds for your transaction. '
                'This process can take up to 30 minutes depending on network congestion.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),

        // Cancel button
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Cancel Verification'),
                  content: const Text(
                    'Are you sure you want to cancel the verification process? '
                    'You can restart it later from your transaction history.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Continue Waiting'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        onComplete();
                      },
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: colorScheme.error,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text('Cancel Verification'),
          ),
        ),
      ],
    );
  }

  Widget _buildVerifiedState(BuildContext context, SpotDepositVerified state) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        // Success animation/icon
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.brightness == Brightness.dark
                ? Colors.green.withValues(alpha: 0.1)
                : Colors.green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.brightness == Brightness.dark
                  ? Colors.green.withValues(alpha: 0.3)
                  : Colors.green.withValues(alpha: 0.5),
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.check_circle,
                size: 64,
                color: Colors.green,
              ),
              const SizedBox(height: 16),
              Text(
                'Deposit Completed!',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your $currency deposit has been successfully verified and credited to your account.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Results
        if (state.result.transaction != null) ...[
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.brightness == Brightness.dark
                  ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)
                  : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Transaction Summary',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                _buildInfoRow(context, 'Amount:',
                    '${state.result.transaction!.amount} $currency'),
                _buildInfoRow(
                    context, 'Status:', state.result.transaction!.status),
                if (state.result.balance != null)
                  _buildInfoRow(context, 'New Balance:',
                      '${state.result.balance} $currency'),
                _buildInfoRow(context, 'Date:',
                    _formatDate(state.result.transaction!.createdAt)),
              ],
            ),
          ),
        ],

        const SizedBox(height: 32),

        // Done button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onComplete,
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Done'),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(BuildContext context, SpotDepositNetworkError state) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        // Error card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.brightness == Brightness.dark
                ? Colors.red.withValues(alpha: 0.1)
                : Colors.red.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.brightness == Brightness.dark
                  ? Colors.red.withValues(alpha: 0.3)
                  : Colors.red.withValues(alpha: 0.5),
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                'Verification Error',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                state.message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),

        // Retry and Done buttons
        Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (transactionId != null) {
                    context.read<SpotDepositBloc>().add(
                          SpotDepositVerificationStarted(transactionId!),
                        );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                ),
                child: const Text('Retry Verification'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: onComplete,
                style: TextButton.styleFrom(
                  foregroundColor: colorScheme.onSurface,
                ),
                child: const Text('Done'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontFamily: 'monospace',
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
