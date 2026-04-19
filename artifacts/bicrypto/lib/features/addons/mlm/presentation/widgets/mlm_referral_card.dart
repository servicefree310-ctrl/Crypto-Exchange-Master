import 'package:flutter/material.dart';
import '../../domain/entities/mlm_referral_entity.dart';
import '../../../../../core/constants/api_constants.dart';

class MlmReferralCard extends StatelessWidget {
  final MlmReferralEntity referral;
  final VoidCallback? onTap;

  const MlmReferralCard({
    super.key,
    required this.referral,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor:
                    _getStatusColor(referral.status).withValues(alpha: 0.2),
                child: Text(
                  referral.referred.firstName.isNotEmpty
                      ? referral.referred.firstName[0].toUpperCase()
                      : 'U',
                  style: TextStyle(
                    color: _getStatusColor(referral.status),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${referral.referred.firstName} ${referral.referred.lastName}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      referral.referred.email,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(referral.status)
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            referral.status.name.toUpperCase(),
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: _getStatusColor(referral.status),
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _formatDate(referral.createdAt),
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey.shade600,
                                  ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(MlmReferralStatus status) {
    switch (status) {
      case MlmReferralStatus.active:
        return const Color(0xFF0ECE7A); // green
      case MlmReferralStatus.pending:
        return const Color(0xFFF39C12); // orange
      case MlmReferralStatus.rejected:
        return const Color(0xFFFF5A5F); // red
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
