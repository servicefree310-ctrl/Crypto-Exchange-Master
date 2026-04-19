import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/deposit_method_entity.dart';
import '../../bloc/deposit_bloc.dart';

class CustomDepositForm extends StatefulWidget {
  const CustomDepositForm({
    super.key,
    required this.method,
    required this.amount,
    required this.currency,
    this.onSubmitted,
  });

  final DepositMethodEntity method;
  final double amount;
  final String currency;
  final VoidCallback? onSubmitted;

  @override
  State<CustomDepositForm> createState() => _CustomDepositFormState();
}

class _CustomDepositFormState extends State<CustomDepositForm> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};
  Map<String, dynamic> _customFields = {};

  @override
  void initState() {
    super.initState();
    _initializeCustomFields();
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _initializeCustomFields() {
    // Parse custom fields from method if available
    if (widget.method.customFields?.isNotEmpty == true) {
      try {
        // Assuming customFields is a JSON string
        // You might need to adjust this based on your backend structure
        _customFields =
            widget.method.customFields ?? {};
      } catch (e) {
        dev.log('Error parsing custom fields: $e');
        _customFields = {};
      }
    }

    // Create default fields if none exist
    if (_customFields.isEmpty) {
      _customFields = {
        'transactionReference': {
          'label': 'Transaction Reference',
          'type': 'text',
          'required': true,
          'placeholder': 'Enter transaction reference number',
        },
        'senderName': {
          'label': 'Sender Name',
          'type': 'text',
          'required': true,
          'placeholder': 'Enter sender full name',
        },
        'paymentDate': {
          'label': 'Payment Date',
          'type': 'date',
          'required': true,
          'placeholder': 'Select payment date',
        },
        'remarks': {
          'label': 'Additional Notes',
          'type': 'textarea',
          'required': false,
          'placeholder': 'Enter any additional information (optional)',
        },
      };
    }

    // Initialize controllers
    for (final fieldKey in _customFields.keys) {
      _controllers[fieldKey] = TextEditingController();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.05),
            Colors.white.withValues(alpha: 0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF6C5CE7).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.description,
                    color: Color(0xFF6C5CE7),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.method.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Amount: ${widget.amount.toStringAsFixed(2)} ${widget.currency}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Instructions
            if (widget.method.instructions.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.blue.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.blue.shade300,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Instructions',
                          style: TextStyle(
                            color: Colors.blue.shade300,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.method.instructions,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Custom Fields
            Text(
              'Deposit Information',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),

            ..._customFields.entries.map((entry) {
              final fieldKey = entry.key;
              final fieldConfig = entry.value as Map<String, dynamic>;
              return _buildCustomField(fieldKey, fieldConfig);
            }),

            const SizedBox(height: 32),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C5CE7),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Submit Deposit Request',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomField(String fieldKey, Map<String, dynamic> fieldConfig) {
    final String label = fieldConfig['label'] ?? fieldKey;
    final String type = fieldConfig['type'] ?? 'text';
    final bool required = fieldConfig['required'] ?? false;
    final String placeholder = fieldConfig['placeholder'] ?? '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (required) ...[
                const SizedBox(width: 4),
                Text(
                  '*',
                  style: TextStyle(
                    color: Colors.red.shade400,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),

          // Field Input
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: _buildFieldInput(fieldKey, type, placeholder, required),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldInput(
      String fieldKey, String type, String placeholder, bool required) {
    final controller = _controllers[fieldKey]!;

    switch (type) {
      case 'textarea':
        return TextFormField(
          controller: controller,
          maxLines: 3,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.all(16),
          ),
          validator: required
              ? (value) =>
                  value?.isEmpty == true ? 'This field is required' : null
              : null,
        );
      case 'date':
        return TextFormField(
          controller: controller,
          readOnly: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.all(16),
            suffixIcon: Icon(
              Icons.calendar_today,
              color: Colors.white.withValues(alpha: 0.6),
              size: 20,
            ),
          ),
          onTap: () => _selectDate(fieldKey),
          validator: required
              ? (value) =>
                  value?.isEmpty == true ? 'This field is required' : null
              : null,
        );
      default:
        return TextFormField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.all(16),
          ),
          validator: required
              ? (value) =>
                  value?.isEmpty == true ? 'This field is required' : null
              : null,
        );
    }
  }

  Future<void> _selectDate(String fieldKey) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF6C5CE7),
              onPrimary: Colors.white,
              surface: Color(0xFF2A2D3A),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      _controllers[fieldKey]!.text = picked.toString().split(' ')[0];
    }
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Collect form data
    final Map<String, dynamic> formData = {};
    for (final entry in _controllers.entries) {
      formData[entry.key] = entry.value.text;
    }

    // Submit the deposit request
    context.read<DepositBloc>().add(
          FiatDepositCreated(
            methodId: widget.method.id,
            amount: widget.amount,
            currency: widget.currency,
            customFields: formData,
          ),
        );

    widget.onSubmitted?.call();
  }
}
