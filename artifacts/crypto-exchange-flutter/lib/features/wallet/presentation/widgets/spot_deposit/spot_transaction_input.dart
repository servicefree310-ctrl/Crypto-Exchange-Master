import 'package:flutter/material.dart';

class SpotTransactionInput extends StatefulWidget {
  const SpotTransactionInput({
    super.key,
    required this.currency,
    required this.network,
    required this.onTransactionSubmitted,
  });

  final String currency;
  final String network;
  final Function(String) onTransactionSubmitted;

  @override
  State<SpotTransactionInput> createState() => _SpotTransactionInputState();
}

class _SpotTransactionInputState extends State<SpotTransactionInput> {
  final _formKey = GlobalKey<FormState>();
  final _transactionController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _transactionController.dispose();
    super.dispose();
  }

  void _submitTransaction() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      widget.onTransactionSubmitted(_transactionController.text.trim());
    }
  }

  String? _validateTransactionHash(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Transaction hash is required';
    }

    final trimmedValue = value.trim();

    // Basic validation for transaction hash format
    if (trimmedValue.length < 32) {
      return 'Transaction hash is too short';
    }

    if (trimmedValue.length > 128) {
      return 'Transaction hash is too long';
    }

    // Check if it contains only valid hexadecimal characters
    final hexRegex = RegExp(r'^[a-fA-F0-9]+$');
    if (!hexRegex.hasMatch(trimmedValue)) {
      return 'Transaction hash must contain only hexadecimal characters';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Transaction Details',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Enter the transaction hash of your ${widget.currency} transfer',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
          ),
          const SizedBox(height: 24),

          // Information card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info, color: Colors.blue.shade600),
                    const SizedBox(width: 8),
                    Text(
                      'Important Information',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.blue.shade700,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '• Make sure you have completed the ${widget.currency} transfer to the provided address\n'
                  '• The transaction hash can be found in your wallet or exchange\n'
                  '• Network: ${widget.network}\n'
                  '• Verification typically takes 10-30 minutes',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Form
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Transaction Hash',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _transactionController,
                  decoration: InputDecoration(
                    hintText: 'Enter transaction hash...',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.tag),
                    helperText: 'Copy the transaction hash from your wallet',
                  ),
                  validator: _validateTransactionHash,
                  maxLines: 2,
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
                const SizedBox(height: 24),

                // Example
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Example:',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'a1b2c3d4e5f6789012345678901234567890abcdef1234567890abcdef123456',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontFamily: 'monospace',
                              color: Colors.grey.shade600,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          // Submit button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submitTransaction,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Start Verification'),
            ),
          ),
        ],
      ),
    );
  }
}
