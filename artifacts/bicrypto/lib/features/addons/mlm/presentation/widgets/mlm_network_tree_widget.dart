import 'package:flutter/material.dart';
import '../../../../../core/theme/global_theme_extensions.dart';
import '../../domain/entities/mlm_network_entity.dart';
import '../../domain/entities/mlm_user_entity.dart';
import 'mlm_user_node_widget.dart';

class MlmNetworkTreeWidget extends StatelessWidget {
  const MlmNetworkTreeWidget({
    super.key,
    required this.network,
    required this.referrals,
  });

  final MlmNetworkEntity network;
  final List<MlmReferralNodeEntity> referrals;

  @override
  Widget build(BuildContext context) {
    if (referrals.isEmpty) {
      return _buildEmptyState(context);
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            'Direct Referrals',
            style: context.h6.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: referrals.length,
              itemBuilder: (context, index) {
                final referral = referrals[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: MlmUserNodeWidget(
                    user: MlmUserEntity(
                      id: referral.referred.id,
                      firstName: referral.referred.firstName,
                      lastName: referral.referred.lastName,
                      email: '',
                      avatar: referral.referred.avatar,
                      status: referral.referred.status,
                      joinDate:
                          DateTime.tryParse(referral.referred.joinDate ?? '') ??
                              DateTime.now(),
                    ),
                    showStats: true,
                    onTap: () => _showReferralDetails(context, referral),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline_rounded,
              size: 64,
              color: context.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'No Referrals Yet',
              style: context.h6.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start referring friends to build your network',
              style: context.bodyM.copyWith(
                color: context.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showReferralDetails(
      BuildContext context, MlmReferralNodeEntity referral) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 4,
              decoration: BoxDecoration(
                color: context.borderColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.borderColor),
              ),
              child: Column(
                children: [
                  Text(
                    '${referral.referred.firstName} ${referral.referred.lastName}',
                    style: context.h6.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    referral.referred.status.toUpperCase(),
                    style: context.bodyS.copyWith(color: context.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Referral Details',
              style: context.h6,
            ),
            const SizedBox(height: 16),
            _buildDetailRow(context, 'Referrer ID', referral.referrerId),
            _buildDetailRow(context, 'Status', referral.status.toUpperCase()),
            _buildDetailRow(context, 'Created', referral.createdAt),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: context.bodyM.copyWith(
              color: context.textSecondary,
            ),
          ),
          Text(
            value,
            style: context.bodyM.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
