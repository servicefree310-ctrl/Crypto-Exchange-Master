import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/offers/create_offer_bloc.dart';
import '../../../bloc/offers/create_offer_event.dart';
import '../../../bloc/offers/create_offer_state.dart';

/// Step 8: User Requirements - V5 Compatible Mobile Implementation
class Step8UserRequirements extends StatefulWidget {
  const Step8UserRequirements({super.key});

  @override
  State<Step8UserRequirements> createState() => _Step8UserRequirementsState();
}

class _Step8UserRequirementsState extends State<Step8UserRequirements> {
  double _minCompletedTrades = 0;
  double _minSuccessRate = 0;
  double _minAccountAge = 0;
  bool _trustedOnly = false;

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  void _loadExistingData() {
    final bloc = context.read<CreateOfferBloc>();
    final state = bloc.state;

    if (state is CreateOfferEditing) {
      final userRequirements =
          state.formData['userRequirements'] as Map<String, dynamic>?;
      if (userRequirements != null) {
        _minCompletedTrades =
            (userRequirements['minCompletedTrades'] ?? 0).toDouble();
        _minSuccessRate = (userRequirements['minSuccessRate'] ?? 0).toDouble();
        _minAccountAge = (userRequirements['minAccountAge'] ?? 0).toDouble();
        _trustedOnly = userRequirements['trustedOnly'] ?? false;
      }
    }

    // Always initialize with defaults and mark step complete (optional step)
    _updateUserRequirements();
  }

  void _updateUserRequirements() {
    final bloc = context.read<CreateOfferBloc>();

    bloc.add(CreateOfferSectionUpdated(
      section: 'userRequirements',
      data: {
        'minCompletedTrades': _minCompletedTrades.toInt(),
        'minSuccessRate': _minSuccessRate.toInt(),
        'minAccountAge': _minAccountAge.toInt(),
        'trustedOnly': _trustedOnly,
      },
    ));
  }

  String _formatAccountAge(double days) {
    if (days == 0) return 'No minimum';
    if (days < 30) return '${days.toInt()} days';
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

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 20),
              _buildTradingExperienceCard(context),
              const SizedBox(height: 16),
              _buildTrustSecurityCard(context),
              const SizedBox(height: 16),
              _buildInfoAlert(context),
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
          'User Requirements',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Set requirements for users who can trade with you. This helps ensure qualified counterparties.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.textTheme.bodySmall?.color,
          ),
        ),
      ],
    );
  }

  Widget _buildTradingExperienceCard(BuildContext context) {
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
                    Icons.people,
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
                        'Trading Experience Requirements',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Set minimum trading experience for potential counterparties',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Minimum Completed Trades
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Minimum Completed Trades',
                      style: theme.textTheme.titleSmall,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: theme.primaryColor.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        _minCompletedTrades > 0
                            ? '${_minCompletedTrades.toInt()}'
                            : 'No minimum',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: theme.primaryColor,
                    inactiveTrackColor:
                        theme.primaryColor.withValues(alpha: 0.3),
                    thumbColor: theme.primaryColor,
                    overlayColor: theme.primaryColor.withValues(alpha: 0.2),
                    trackHeight: 4.0,
                    thumbShape:
                        const RoundSliderThumbShape(enabledThumbRadius: 10),
                  ),
                  child: Slider(
                    value: _minCompletedTrades,
                    min: 0,
                    max: 50,
                    divisions: 50,
                    onChanged: (value) {
                      setState(() {
                        _minCompletedTrades = value;
                      });
                      _updateUserRequirements();
                    },
                  ),
                ),
                Text(
                  'Require users to have completed at least this many trades',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Minimum Success Rate
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Minimum Success Rate',
                      style: theme.textTheme.titleSmall,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: theme.primaryColor.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        _minSuccessRate > 0
                            ? '${_minSuccessRate.toInt()}%'
                            : 'No minimum',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: theme.primaryColor,
                    inactiveTrackColor:
                        theme.primaryColor.withValues(alpha: 0.3),
                    thumbColor: theme.primaryColor,
                    overlayColor: theme.primaryColor.withValues(alpha: 0.2),
                    trackHeight: 4.0,
                    thumbShape:
                        const RoundSliderThumbShape(enabledThumbRadius: 10),
                  ),
                  child: Slider(
                    value: _minSuccessRate,
                    min: 0,
                    max: 100,
                    divisions: 20,
                    onChanged: (value) {
                      setState(() {
                        _minSuccessRate = value;
                      });
                      _updateUserRequirements();
                    },
                  ),
                ),
                Text(
                  'Require users to have this percentage of successful trades',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrustSecurityCard(BuildContext context) {
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
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.security,
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
                        'Trust & Security Requirements',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Set additional security requirements for potential counterparties',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Minimum Account Age
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Minimum Account Age',
                      style: theme.textTheme.titleSmall,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green.shade300),
                      ),
                      child: Text(
                        _formatAccountAge(_minAccountAge),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: Colors.green.shade600,
                    inactiveTrackColor: Colors.green.shade200,
                    thumbColor: Colors.green.shade600,
                    overlayColor: Colors.green.shade200,
                    trackHeight: 4.0,
                    thumbShape:
                        const RoundSliderThumbShape(enabledThumbRadius: 10),
                  ),
                  child: Slider(
                    value: _minAccountAge,
                    min: 0,
                    max: 365,
                    divisions: 12,
                    onChanged: (value) {
                      setState(() {
                        _minAccountAge = (value / 30).round() * 30.0;
                      });
                      _updateUserRequirements();
                    },
                  ),
                ),
                Text(
                  'Require users to have accounts older than this many days',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Trusted Users Only
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Trusted Users Only',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Only allow users you\'ve marked as trusted to respond to your offer',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Switch(
                    value: _trustedOnly,
                    onChanged: (value) {
                      setState(() {
                        _trustedOnly = value;
                      });
                      _updateUserRequirements();
                    },
                    activeThumbColor: theme.primaryColor,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoAlert(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: Colors.blue.shade600,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Setting appropriate user requirements can help prevent problematic trades. However, setting requirements too high may reduce potential counterparties.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.blue.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
