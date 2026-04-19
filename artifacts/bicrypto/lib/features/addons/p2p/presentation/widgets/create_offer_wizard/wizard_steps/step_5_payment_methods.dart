import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/offers/create_offer_bloc.dart';
import '../../../bloc/offers/create_offer_event.dart';
import '../../../bloc/offers/create_offer_state.dart';

/// Payment Method Model - V5 Compatible
class PaymentMethodModel {
  final String id;
  final String name;
  final String icon;
  final String description;
  final String? processingTime;
  final String? fees;
  final bool available;
  final bool isCustom;
  final String? instructions;

  const PaymentMethodModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.description,
    this.processingTime,
    this.fees,
    this.available = true,
    this.isCustom = false,
    this.instructions,
  });
}

/// Step 5: Payment Methods Selection - V5 Compatible Mobile Implementation
class Step5PaymentMethods extends StatefulWidget {
  const Step5PaymentMethods({super.key});

  @override
  State<Step5PaymentMethods> createState() => _Step5PaymentMethodsState();
}

class _Step5PaymentMethodsState extends State<Step5PaymentMethods> {
  final TextEditingController _customNameController = TextEditingController();
  final TextEditingController _customDescriptionController =
      TextEditingController();
  final TextEditingController _customInstructionsController =
      TextEditingController();
  final TextEditingController _customProcessingTimeController =
      TextEditingController();

  bool _showCreateCustom = false;
  bool _isCreatingCustom = false;

  @override
  void initState() {
    super.initState();
    // Fetch payment methods when widget initializes
    context.read<CreateOfferBloc>().add(const CreateOfferFetchPaymentMethods());
  }

  @override
  void dispose() {
    _customNameController.dispose();
    _customDescriptionController.dispose();
    _customInstructionsController.dispose();
    _customProcessingTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CreateOfferBloc, CreateOfferState>(
      builder: (context, state) {
        if (state is! CreateOfferEditing) {
          return const Center(child: CircularProgressIndicator());
        }

        final availablePaymentMethods =
            state.formData['availablePaymentMethods'] as List<dynamic>? ?? [];
        final selectedMethodIds =
            state.formData['paymentMethodIds'] as List<String>? ?? [];
        final isLoading = state.isLoading;
        final error = state.validationErrors['paymentMethods'];

        return Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, state),
                  const SizedBox(height: 16),
                  if (error != null) _buildErrorCard(context, error),
                  if (selectedMethodIds.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _buildSelectedMethods(
                        context, availablePaymentMethods, selectedMethodIds),
                  ],
                  const SizedBox(height: 16),
                  _buildAvailableMethods(
                      context, availablePaymentMethods, selectedMethodIds),
                  const SizedBox(height: 16),
                  _buildCustomMethodSection(context),
                  if (selectedMethodIds.isEmpty) const SizedBox(height: 8),
                  if (selectedMethodIds.isEmpty) _buildValidationError(context),
                  const SizedBox(height: 16),
                ],
              ),
            ),

            // Loading overlay
            if (isLoading)
              Container(
                color: Colors.black.withValues(alpha: 0.3),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, CreateOfferEditing state) {
    final tradeType = state.tradeType ?? 'BUY';
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Methods',
          style: theme.textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'Select the payment methods you ${tradeType == 'BUY' ? 'will use to pay' : 'will accept'} for this trade.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.textTheme.bodySmall?.color,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorCard(BuildContext context, String error) {
    return Card(
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade600),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                error,
                style: TextStyle(color: Colors.red.shade700),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedMethods(BuildContext context, List<dynamic> allMethods,
      List<String> selectedIds) {
    final selectedMethods = allMethods
        .where((method) => selectedIds.contains(method['id']))
        .toList();
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green.shade600, size: 20),
            const SizedBox(width: 8),
            Text(
              'Selected Payment Methods (${selectedMethods.length})',
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.green.shade700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...selectedMethods
            .map((method) => _buildSelectedMethodCard(context, method)),
      ],
    );
  }

  Widget _buildSelectedMethodCard(
      BuildContext context, Map<String, dynamic> method) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                _getIconForMethod(method['icon']),
                color: Colors.green.shade700,
                size: 16,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    method['name'] ?? '',
                    style: theme.textTheme.titleSmall,
                  ),
                  if (method['description'] != null &&
                      method['description'].isNotEmpty)
                    Text(
                      method['description'],
                      style: theme.textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (method['processingTime'] != null)
                    Text(
                      'Processing: ${method['processingTime']}',
                      style: theme.textTheme.labelSmall,
                    ),
                ],
              ),
            ),
            SizedBox(
              width: 36,
              height: 36,
              child: IconButton(
                onPressed: () => _removePaymentMethod(context, method['id']),
                icon: Icon(Icons.close, color: Colors.red.shade600, size: 18),
                padding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailableMethods(BuildContext context, List<dynamic> allMethods,
      List<String> selectedIds) {
    final availableMethods = allMethods
        .where((method) =>
            !selectedIds.contains(method['id']) &&
            (method['available'] == true))
        .toList();
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available Payment Methods',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        if (availableMethods.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Text(
                  'No available payment methods found.',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1.8,
            ),
            itemCount: availableMethods.length,
            itemBuilder: (context, index) {
              final method = availableMethods[index];
              return _buildAvailableMethodCard(context, method);
            },
          ),
      ],
    );
  }

  Widget _buildAvailableMethodCard(
      BuildContext context, Map<String, dynamic> method) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        onTap: () => _addPaymentMethod(context, method['id']),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      _getIconForMethod(method['icon']),
                      color: theme.primaryColor,
                      size: 14,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      method['name'] ?? '',
                      style: theme.textTheme.titleSmall?.copyWith(fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              if (method['description'] != null &&
                  method['description'].isNotEmpty)
                Text(
                  method['description'],
                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              const Spacer(),
              Row(
                children: [
                  Icon(Icons.add_circle_outline,
                      size: 14, color: theme.primaryColor),
                  const SizedBox(width: 3),
                  Text(
                    'Add',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.primaryColor,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomMethodSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const SizedBox(height: 16),
        if (!_showCreateCustom)
          Card(
            child: InkWell(
              onTap: () => setState(() => _showCreateCustom = true),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        Icons.add,
                        color: Theme.of(context).primaryColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Create Custom Payment Method',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            'Add your own payment method with custom instructions',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 14),
                  ],
                ),
              ),
            ),
          )
        else
          _buildCreateCustomForm(context),
      ],
    );
  }

  Widget _buildCreateCustomForm(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Create Custom Payment Method',
                  style: theme.textTheme.titleMedium,
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _showCreateCustom = false;
                      _clearCustomForm();
                    });
                  },
                  child: const Text('Cancel'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _customNameController,
              decoration: const InputDecoration(
                labelText: 'Payment Method Name *',
                hintText: 'e.g., My Bank Account',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _customDescriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Brief description of your payment method',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _customInstructionsController,
              decoration: const InputDecoration(
                labelText: 'Payment Instructions *',
                hintText:
                    'Detailed instructions for traders on how to use this method',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _customProcessingTimeController,
              decoration: const InputDecoration(
                labelText: 'Processing Time',
                hintText: 'e.g., Instant, 1-2 hours, 1-3 business days',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isCreatingCustom
                    ? null
                    : () => _createCustomMethod(context),
                child: _isCreatingCustom
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Create Payment Method'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildValidationError(BuildContext context) {
    return Card(
      color: Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.warning_amber, color: Colors.orange.shade600),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'At least one payment method must be selected',
                style: TextStyle(color: Colors.orange.shade700),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addPaymentMethod(BuildContext context, String methodId) {
    final bloc = context.read<CreateOfferBloc>();
    final state = bloc.state;

    if (state is CreateOfferEditing) {
      final currentIds = List<String>.from(
          state.formData['paymentMethodIds'] as List<String>? ?? []);
      if (!currentIds.contains(methodId)) {
        currentIds.add(methodId);
        bloc.add(
            CreateOfferUpdatePaymentMethods(selectedMethodIds: currentIds));
      }
    }
  }

  void _removePaymentMethod(BuildContext context, String methodId) {
    final bloc = context.read<CreateOfferBloc>();
    final state = bloc.state;

    if (state is CreateOfferEditing) {
      final currentIds = List<String>.from(
          state.formData['paymentMethodIds'] as List<String>? ?? []);
      currentIds.remove(methodId);
      bloc.add(CreateOfferUpdatePaymentMethods(selectedMethodIds: currentIds));
    }
  }

  void _createCustomMethod(BuildContext context) async {
    if (_customNameController.text.trim().isEmpty ||
        _customInstructionsController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name and instructions are required')),
      );
      return;
    }

    setState(() => _isCreatingCustom = true);

    context.read<CreateOfferBloc>().add(
          CreateOfferCreatePaymentMethod(
            name: _customNameController.text.trim(),
            description: _customDescriptionController.text.trim().isEmpty
                ? null
                : _customDescriptionController.text.trim(),
            instructions: _customInstructionsController.text.trim(),
            processingTime: _customProcessingTimeController.text.trim().isEmpty
                ? null
                : _customProcessingTimeController.text.trim(),
            icon: 'credit_card',
          ),
        );

    // Listen for completion
    final subscription = context.read<CreateOfferBloc>().stream.listen((state) {
      if (state is CreateOfferEditing) {
        final error = state.validationErrors['createPaymentMethod'];
        if (error == null && !state.isLoading) {
          // Success
          setState(() {
            _isCreatingCustom = false;
            _showCreateCustom = false;
            _clearCustomForm();
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Custom payment method created successfully!')),
          );
        } else if (error != null) {
          // Error
          setState(() => _isCreatingCustom = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $error')),
          );
        }
      }
    });

    // Clean up subscription after a short delay
    Future.delayed(const Duration(seconds: 3), () => subscription.cancel());
  }

  void _clearCustomForm() {
    _customNameController.clear();
    _customDescriptionController.clear();
    _customInstructionsController.clear();
    _customProcessingTimeController.clear();
  }

  IconData _getIconForMethod(String? iconType) {
    switch (iconType?.toLowerCase()) {
      case 'bank':
      case 'bank_transfer':
        return Icons.account_balance;
      case 'paypal':
        return Icons.payment;
      case 'wise':
        return Icons.sync_alt;
      case 'venmo':
      case 'cash_app':
        return Icons.phone_android;
      case 'zelle':
        return Icons.flash_on;
      case 'wallet':
        return Icons.account_balance_wallet;
      case 'credit_card':
      default:
        return Icons.credit_card;
    }
  }
}
