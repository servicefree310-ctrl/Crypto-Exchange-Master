import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/offers/create_offer_bloc.dart';
import '../../../bloc/offers/create_offer_event.dart';
import '../../../bloc/offers/create_offer_state.dart';

/// Step 9: Review & Submit - V5 Compatible Mobile Implementation
class Step9Review extends StatefulWidget {
  const Step9Review({super.key});

  @override
  State<Step9Review> createState() => _Step9ReviewState();
}

class _Step9ReviewState extends State<Step9Review> {
  @override
  void initState() {
    super.initState();
    // Mark this step as complete on load since it's just a review
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bloc = context.read<CreateOfferBloc>();
      bloc.add(const CreateOfferStepCompleted('step_9'));
    });
  }

  String _getWalletTypeName(String? walletType) {
    const walletNames = {
      'FIAT': 'Fiat',
      'SPOT': 'Spot',
      'ECO': 'Funding',
      'FUNDING': 'Funding',
    };
    return walletNames[walletType] ?? walletType ?? 'Not specified';
  }

  Color _getTradeTypeColor(String? tradeType) {
    return tradeType?.toLowerCase() == 'buy' ? Colors.green : Colors.red;
  }

  String _formatAccountAge(int? days) {
    if (days == null || days == 0) return 'No minimum';
    if (days < 30) return '$days days';
    if (days < 365) {
      final months = (days / 30).floor();
      return '$months month${months > 1 ? 's' : ''}';
    }
    final years = (days / 365).floor();
    return '$years year${years > 1 ? 's' : ''}';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CreateOfferBloc, CreateOfferState>(
      builder: (context, state) {
        if (state is! CreateOfferEditing) {
          return const Center(child: CircularProgressIndicator());
        }

        final formData = state.formData;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderBanner(context),
              const SizedBox(height: 20),
              _buildTradeDetailsCard(context, formData),
              const SizedBox(height: 16),
              _buildAmountPricingCard(context, formData),
              const SizedBox(height: 16),
              _buildPaymentMethodsCard(context, formData),
              const SizedBox(height: 16),
              _buildTradeSettingsCard(context, formData),
              const SizedBox(height: 16),
              _buildLocationSettingsCard(context, formData),
              const SizedBox(height: 16),
              _buildUserRequirementsCard(context, formData),
              const SizedBox(height: 16),
              _buildFinalNotice(context),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeaderBanner(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade50, Colors.indigo.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.verified,
              color: Colors.blue.shade600,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Review Your Offer',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Please review all your offer details. Make sure all information is correct before creating.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTradeDetailsCard(
      BuildContext context, Map<String, dynamic> formData) {
    final theme = Theme.of(context);

    return Card(
      child: Container(
        decoration: BoxDecoration(
          border:
              Border(top: BorderSide(color: Colors.blue.shade500, width: 4)),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Trade Details',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getTradeTypeColor(formData['tradeType'])
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: _getTradeTypeColor(formData['tradeType'])
                              .withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      (formData['tradeType'] ?? 'Not specified')
                          .toString()
                          .toUpperCase(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: _getTradeTypeColor(formData['tradeType']),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 16),

              // Trade Type
              _buildDetailRow(
                context,
                icon: Icons.swap_horiz,
                iconColor: Colors.blue.shade600,
                iconBgColor: Colors.blue.shade100,
                label: 'Trade Type',
                value: (formData['tradeType'] ?? 'Not specified').toString(),
                valueColor: _getTradeTypeColor(formData['tradeType']),
              ),

              const SizedBox(height: 16),

              // Wallet Type
              _buildDetailRow(
                context,
                icon: Icons.account_balance_wallet,
                iconColor: Colors.indigo.shade600,
                iconBgColor: Colors.indigo.shade100,
                label: 'Wallet Type',
                value: _getWalletTypeName(formData['walletType']),
              ),

              const SizedBox(height: 16),

              // Currency
              _buildDetailRow(
                context,
                icon: Icons.currency_bitcoin,
                iconColor: Colors.purple.shade600,
                iconBgColor: Colors.purple.shade100,
                label: 'Currency',
                value: formData['currency'] ?? 'Not specified',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAmountPricingCard(
      BuildContext context, Map<String, dynamic> formData) {
    final theme = Theme.of(context);
    final amountConfig = formData['amountConfig'] as Map<String, dynamic>?;
    final priceConfig = formData['priceConfig'] as Map<String, dynamic>?;

    return Card(
      child: Container(
        decoration: BoxDecoration(
          border:
              Border(top: BorderSide(color: Colors.green.shade500, width: 4)),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Amount & Pricing',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 16),

              // Amount
              _buildDetailRow(
                context,
                icon: Icons.attach_money,
                iconColor: Colors.green.shade600,
                iconBgColor: Colors.green.shade100,
                label: 'Amount',
                value: amountConfig != null
                    ? '${amountConfig['total'] ?? 0} ${formData['currency'] ?? 'CRYPTO'}'
                    : 'Not specified',
                child: amountConfig != null &&
                        (amountConfig['min'] != null ||
                            amountConfig['max'] != null)
                    ? Wrap(
                        spacing: 8,
                        children: [
                          if (amountConfig['min'] != null)
                            Chip(
                              label: Text('Min ${amountConfig['min']}',
                                  style: const TextStyle(fontSize: 12)),
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                            ),
                          if (amountConfig['max'] != null)
                            Chip(
                              label: Text('Max ${amountConfig['max']}',
                                  style: const TextStyle(fontSize: 12)),
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                            ),
                        ],
                      )
                    : null,
              ),

              const SizedBox(height: 16),

              // Price
              _buildDetailRow(
                context,
                icon: Icons.trending_up,
                iconColor: Colors.amber.shade600,
                iconBgColor: Colors.amber.shade100,
                label: 'Price',
                value: priceConfig != null
                    ? '\$${priceConfig['finalPrice'] ?? priceConfig['value'] ?? 0} per ${formData['currency'] ?? 'CRYPTO'}'
                    : 'Not specified',
                child: priceConfig != null && priceConfig['model'] == 'MARGIN'
                    ? Chip(
                        label: Text(
                          '${(priceConfig['value'] ?? 0) >= 0 ? '+' : ''}${priceConfig['value']}% from market price',
                          style: const TextStyle(fontSize: 12),
                        ),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethodsCard(
      BuildContext context, Map<String, dynamic> formData) {
    final theme = Theme.of(context);
    final paymentMethods = formData['paymentMethods'] as List<dynamic>?;

    return Card(
      child: Container(
        decoration: BoxDecoration(
          border:
              Border(top: BorderSide(color: Colors.purple.shade500, width: 4)),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Payment Methods',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: theme.primaryColor.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      '${paymentMethods?.length ?? 0} Selected',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 16),
              _buildDetailRow(
                context,
                icon: Icons.payment,
                iconColor: Colors.teal.shade600,
                iconBgColor: Colors.teal.shade100,
                label: 'Accepted Methods',
                value: '',
                child: paymentMethods != null && paymentMethods.isNotEmpty
                    ? Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: paymentMethods.map((method) {
                          final name = method is Map
                              ? (method['name'] ?? method['id'] ?? 'Unknown')
                              : method.toString();
                          return Chip(
                            label: Text(name,
                                style: const TextStyle(fontSize: 12)),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                          );
                        }).toList(),
                      )
                    : Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.amber.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.warning,
                                color: Colors.amber.shade600, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'No payment methods specified. Please go back and select payment methods.',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.amber.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTradeSettingsCard(
      BuildContext context, Map<String, dynamic> formData) {
    final theme = Theme.of(context);
    final tradeSettings = formData['tradeSettings'] as Map<String, dynamic>?;

    return Card(
      child: Container(
        decoration: BoxDecoration(
          border:
              Border(top: BorderSide(color: Colors.teal.shade500, width: 4)),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Trade Settings',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 16),

              // Auto Cancel
              _buildDetailRow(
                context,
                icon: Icons.schedule,
                iconColor: Colors.red.shade600,
                iconBgColor: Colors.red.shade100,
                label: 'Auto Cancel',
                value: '${tradeSettings?['autoCancel'] ?? 30} minutes',
                child: tradeSettings?['autoCancel'] == null
                    ? Chip(
                        label: const Text('Default',
                            style: TextStyle(fontSize: 12)),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      )
                    : null,
              ),

              const SizedBox(height: 16),

              // Visibility
              _buildDetailRow(
                context,
                icon: Icons.visibility,
                iconColor: Colors.orange.shade600,
                iconBgColor: Colors.orange.shade100,
                label: 'Visibility',
                value: (tradeSettings?['visibility'] ?? 'PUBLIC')
                    .toString()
                    .toUpperCase(),
                child: tradeSettings?['visibility'] == null
                    ? Chip(
                        label: const Text('Default',
                            style: TextStyle(fontSize: 12)),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      )
                    : null,
              ),

              // Terms of Trade
              if (tradeSettings?['termsOfTrade'] != null &&
                  tradeSettings!['termsOfTrade'].toString().isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildDetailRow(
                  context,
                  icon: Icons.description,
                  iconColor: Colors.blue.shade600,
                  iconBgColor: Colors.blue.shade100,
                  label: 'Terms of Trade',
                  value: '',
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border(
                          left: BorderSide(
                              color: Colors.blue.shade300, width: 3)),
                    ),
                    child: Text(
                      tradeSettings['termsOfTrade'].toString(),
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationSettingsCard(
      BuildContext context, Map<String, dynamic> formData) {
    final theme = Theme.of(context);
    final locationSettings =
        formData['locationSettings'] as Map<String, dynamic>?;

    return Card(
      child: Container(
        decoration: BoxDecoration(
          border:
              Border(top: BorderSide(color: Colors.green.shade500, width: 4)),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Location Settings',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 16),
              if (locationSettings != null) ...[
                // Trading Location
                _buildDetailRow(
                  context,
                  icon: Icons.location_on,
                  iconColor: Colors.green.shade600,
                  iconBgColor: Colors.green.shade100,
                  label: 'Trading Location',
                  value: () {
                    final location = [
                      locationSettings['country'],
                      locationSettings['region'],
                      locationSettings['city'],
                    ]
                        .where((e) => e != null && e.toString().isNotEmpty)
                        .join(', ');
                    return location.isEmpty
                        ? 'No location specified'
                        : location;
                  }(),
                ),

                // Geographical Restrictions
                if (locationSettings['restrictions'] != null &&
                    (locationSettings['restrictions'] as List).isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    context,
                    icon: Icons.public_off,
                    iconColor: Colors.red.shade600,
                    iconBgColor: Colors.red.shade100,
                    label: 'Geographical Restrictions',
                    value: '',
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: (locationSettings['restrictions'] as List)
                          .map((restriction) {
                        return Chip(
                          label: Text(restriction.toString(),
                              style: const TextStyle(fontSize: 12)),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline,
                          color: Colors.grey.shade600, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'No location settings specified',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserRequirementsCard(
      BuildContext context, Map<String, dynamic> formData) {
    final theme = Theme.of(context);
    final userRequirements =
        formData['userRequirements'] as Map<String, dynamic>?;

    return Card(
      child: Container(
        decoration: BoxDecoration(
          border:
              Border(top: BorderSide(color: Colors.yellow.shade500, width: 4)),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'User Requirements',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 16),
              if (userRequirements != null) ...[
                // Trading Experience
                _buildDetailRow(
                  context,
                  icon: Icons.people,
                  iconColor: Colors.blue.shade600,
                  iconBgColor: Colors.blue.shade100,
                  label: 'Trading Experience',
                  value: '',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if ((userRequirements['minCompletedTrades'] ?? 0) > 0 ||
                          (userRequirements['minSuccessRate'] ?? 0) > 0) ...[
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            if ((userRequirements['minCompletedTrades'] ?? 0) >
                                0)
                              Chip(
                                label: Text(
                                    'Min. ${userRequirements['minCompletedTrades']} completed trades',
                                    style: const TextStyle(fontSize: 12)),
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                visualDensity: VisualDensity.compact,
                              ),
                            if ((userRequirements['minSuccessRate'] ?? 0) > 0)
                              Chip(
                                label: Text(
                                    'Min. ${userRequirements['minSuccessRate']}% success rate',
                                    style: const TextStyle(fontSize: 12)),
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                visualDensity: VisualDensity.compact,
                              ),
                          ],
                        ),
                      ] else ...[
                        Text(
                          'No minimum experience required',
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: Colors.grey.shade600),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Trust & Security
                _buildDetailRow(
                  context,
                  icon: Icons.security,
                  iconColor: Colors.purple.shade600,
                  iconBgColor: Colors.purple.shade100,
                  label: 'Trust & Security',
                  value: '',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if ((userRequirements['minAccountAge'] ?? 0) > 0 ||
                          (userRequirements['trustedOnly'] ?? false)) ...[
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            if ((userRequirements['minAccountAge'] ?? 0) > 0)
                              Chip(
                                label: Text(
                                    'Min. account age ${_formatAccountAge(userRequirements['minAccountAge'])}',
                                    style: const TextStyle(fontSize: 12)),
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                visualDensity: VisualDensity.compact,
                              ),
                            if (userRequirements['trustedOnly'] ?? false)
                              Chip(
                                label: const Text('Trusted users only',
                                    style: TextStyle(fontSize: 12)),
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                visualDensity: VisualDensity.compact,
                                backgroundColor: theme.primaryColor,
                                labelStyle:
                                    const TextStyle(color: Colors.white),
                              ),
                          ],
                        ),
                      ] else ...[
                        Text(
                          'No additional trust requirements',
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: Colors.grey.shade600),
                        ),
                      ],
                    ],
                  ),
                ),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline,
                          color: Colors.grey.shade600, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'No user requirements specified',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFinalNotice(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade50, Colors.indigo.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.info_outline,
              color: Colors.blue.shade600,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ready to Create Your Offer?',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Once you click complete, your offer will be created based on your visibility settings.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String label,
    required String value,
    Color? valueColor,
    Widget? child,
  }) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconBgColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (value.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  value,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: valueColor,
                  ),
                ),
              ],
              if (child != null) ...[
                const SizedBox(height: 8),
                child,
              ],
            ],
          ),
        ),
      ],
    );
  }
}
