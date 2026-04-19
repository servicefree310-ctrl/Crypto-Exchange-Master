import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/offers/create_offer_bloc.dart';
import '../../../bloc/offers/create_offer_event.dart';
import '../../../bloc/offers/create_offer_state.dart';

/// Step 6: Trade Settings - V5 Compatible Mobile Implementation
class Step6TradeSettings extends StatefulWidget {
  const Step6TradeSettings({super.key});

  @override
  State<Step6TradeSettings> createState() => _Step6TradeSettingsState();
}

class _Step6TradeSettingsState extends State<Step6TradeSettings> {
  final TextEditingController _termsController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  bool _autoCancelEnabled = true;
  int _autoCancelDuration = 60; // Default 1 hour (in minutes)
  bool _isPrivateOffer = false;
  bool _kycRequired = true; // Always true by default in V5

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  @override
  void dispose() {
    _termsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _loadExistingData() {
    final bloc = context.read<CreateOfferBloc>();
    final state = bloc.state;

    if (state is CreateOfferEditing) {
      final tradeSettings =
          state.formData['tradeSettings'] as Map<String, dynamic>?;
      if (tradeSettings != null) {
        _termsController.text = tradeSettings['termsOfTrade'] ?? '';
        _notesController.text = tradeSettings['additionalNotes'] ?? '';
        _autoCancelEnabled = (tradeSettings['autoCancel'] ?? 60) > 0;
        _autoCancelDuration = tradeSettings['autoCancel'] ?? 60;
        _isPrivateOffer = tradeSettings['visibility'] == 'PRIVATE';
        _kycRequired = tradeSettings['kycRequired'] ?? true;
      }
    }
  }

  void _updateTradeSettings() {
    final bloc = context.read<CreateOfferBloc>();

    bloc.add(CreateOfferSectionUpdated(
      section: 'tradeSettings',
      data: {
        'autoCancel': _autoCancelEnabled ? _autoCancelDuration : 0,
        'kycRequired': _kycRequired,
        'termsOfTrade': _termsController.text.trim(),
        'visibility': _isPrivateOffer ? 'PRIVATE' : 'PUBLIC',
        'additionalNotes': _notesController.text.trim(),
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CreateOfferBloc, CreateOfferState>(
      builder: (context, state) {
        if (state is! CreateOfferEditing) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 20),
              _buildAutoCancelCard(context),
              const SizedBox(height: 16),
              _buildVisibilityCard(context),
              const SizedBox(height: 16),
              _buildKycCard(context),
              const SizedBox(height: 16),
              _buildTermsCard(context),
              const SizedBox(height: 16),
              _buildNotesCard(context),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Trade Settings',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Configure additional settings for your trade offer to customize the trading experience',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.textTheme.bodySmall?.color,
          ),
        ),
      ],
    );
  }

  Widget _buildAutoCancelCard(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.schedule,
                    color: theme.primaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Auto-Cancellation',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Automatically cancel if no response within specified time',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _autoCancelEnabled,
                  onChanged: (value) {
                    setState(() {
                      _autoCancelEnabled = value;
                    });
                    _updateTradeSettings();
                  },
                ),
              ],
            ),
            if (_autoCancelEnabled) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              Text(
                'Auto-Cancel Duration',
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              _buildDurationSelector(context),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline,
                        color: Colors.blue.shade600, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'If no response within this time, trade will be automatically cancelled',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.blue.shade700,
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
    );
  }

  Widget _buildDurationSelector(BuildContext context) {
    final durations = [
      {'value': 15, 'label': '15 minutes'},
      {'value': 30, 'label': '30 minutes'},
      {'value': 60, 'label': '1 hour'},
      {'value': 120, 'label': '2 hours'},
      {'value': 360, 'label': '6 hours'},
      {'value': 720, 'label': '12 hours'},
      {'value': 1440, 'label': '1 day'},
      {'value': 2880, 'label': '2 days'},
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: _autoCancelDuration,
          isExpanded: true,
          items: durations.map((duration) {
            return DropdownMenuItem<int>(
              value: duration['value'] as int,
              child: Text(duration['label'] as String),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _autoCancelDuration = value;
              });
              _updateTradeSettings();
            }
          },
        ),
      ),
    );
  }

  Widget _buildVisibilityCard(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _isPrivateOffer ? Icons.visibility_off : Icons.visibility,
                    color: theme.primaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Offer Visibility',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Control who can see and access your trade offer',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildVisibilityOptions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildVisibilityOptions(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        _buildVisibilityOption(
          context,
          isSelected: !_isPrivateOffer,
          title: 'Public Offer',
          description: 'Visible to all users in the marketplace',
          icon: Icons.public,
          onTap: () {
            setState(() {
              _isPrivateOffer = false;
            });
            _updateTradeSettings();
          },
        ),
        const SizedBox(height: 12),
        _buildVisibilityOption(
          context,
          isSelected: _isPrivateOffer,
          title: 'Private Offer',
          description: 'Only users with direct link can view and accept',
          icon: Icons.lock,
          onTap: () {
            setState(() {
              _isPrivateOffer = true;
            });
            _updateTradeSettings();
          },
        ),
      ],
    );
  }

  Widget _buildVisibilityOption(
    BuildContext context, {
    required bool isSelected,
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? theme.primaryColor : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          color: isSelected ? theme.primaryColor.withValues(alpha: 0.05) : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? theme.primaryColor : Colors.grey.shade600,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: isSelected ? theme.primaryColor : null,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    description,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: theme.primaryColor,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildKycCard(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.verified_user,
                color: Colors.green.shade600,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'KYC Verification Required',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'All traders must complete KYC verification',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.check_circle,
              color: Colors.green.shade600,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTermsCard(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.article,
                    color: Colors.orange.shade600,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Terms of Trade',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.red.shade100,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Required',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: Colors.red.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'Enter your terms and conditions for this trade',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _termsController,
              decoration: InputDecoration(
                hintText:
                    'e.g., "Please transfer to my account after confirmation. No third-party payments."',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                isDense: true,
                helperText: '${_termsController.text.length}/500 characters',
              ),
              maxLines: 4,
              maxLength: 500,
              onChanged: (value) {
                setState(() {}); // Update character count
                _updateTradeSettings();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesCard(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.note_add,
                    color: Colors.blue.shade600,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Additional Notes',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Optional',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'Any additional information for traders',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              decoration: InputDecoration(
                hintText:
                    'e.g., "Fast response guaranteed. Available 9 AM - 6 PM UTC."',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                isDense: true,
                helperText: '${_notesController.text.length}/300 characters',
              ),
              maxLines: 3,
              maxLength: 300,
              onChanged: (value) {
                setState(() {}); // Update character count
                _updateTradeSettings();
              },
            ),
          ],
        ),
      ),
    );
  }
}
