import 'package:flutter/material.dart';

import '../../domain/entities/kyc_application_entity.dart';

class KycStatusCard extends StatelessWidget {
  final List<KycApplicationEntity>? applications;

  const KycStatusCard({super.key, this.applications});

  @override
  Widget build(BuildContext context) {
    final statusInfo = _getStatusInfo();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusInfo.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusInfo.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                statusInfo.icon,
                color: statusInfo.iconColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Verification Status',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: statusInfo.iconColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: statusInfo.dotColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                statusInfo.statusText,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            statusInfo.description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  _StatusInfo _getStatusInfo() {
    if (applications == null || applications!.isEmpty) {
      return _StatusInfo(
        statusText: 'Not Verified',
        description:
            'Complete KYC verification to unlock all platform features and increase your trading limits.',
        icon: Icons.account_circle_outlined,
        iconColor: Colors.blue.shade700,
        dotColor: Colors.orange,
        backgroundColor: Colors.blue.shade50,
        borderColor: Colors.blue.shade200,
      );
    }

    // Check for approved application (highest priority)
    final approved = applications!
        .where((a) => a.status == KycApplicationStatus.approved)
        .toList();
    if (approved.isNotEmpty) {
      final highestLevel = approved.fold<int>(
          0, (max, a) => (a.level?.level ?? 0) > max ? (a.level?.level ?? 0) : max);
      return _StatusInfo(
        statusText: 'Verified (Level $highestLevel)',
        description:
            'Your identity has been verified. You have full access to platform features.',
        icon: Icons.verified_user,
        iconColor: Colors.green.shade700,
        dotColor: Colors.green,
        backgroundColor: Colors.green.shade50,
        borderColor: Colors.green.shade200,
      );
    }

    // Check for pending application
    final pending = applications!
        .where((a) => a.status == KycApplicationStatus.pending)
        .toList();
    if (pending.isNotEmpty) {
      return _StatusInfo(
        statusText: 'Pending Review',
        description:
            'Your KYC application is being reviewed. This usually takes 1-3 business days.',
        icon: Icons.hourglass_top,
        iconColor: Colors.amber.shade700,
        dotColor: Colors.amber,
        backgroundColor: Colors.amber.shade50,
        borderColor: Colors.amber.shade200,
      );
    }

    // Check for additional info required
    final additionalInfo = applications!
        .where(
            (a) => a.status == KycApplicationStatus.additionalInfoRequired)
        .toList();
    if (additionalInfo.isNotEmpty) {
      return _StatusInfo(
        statusText: 'Additional Information Required',
        description:
            'Please update your application with the requested information.',
        icon: Icons.info_outline,
        iconColor: Colors.blue.shade700,
        dotColor: Colors.blue,
        backgroundColor: Colors.blue.shade50,
        borderColor: Colors.blue.shade200,
      );
    }

    // Check for rejected application
    final rejected = applications!
        .where((a) => a.status == KycApplicationStatus.rejected)
        .toList();
    if (rejected.isNotEmpty) {
      return _StatusInfo(
        statusText: 'Rejected',
        description: rejected.first.adminNotes ??
            'Your application was rejected. Please review and resubmit.',
        icon: Icons.cancel_outlined,
        iconColor: Colors.red.shade700,
        dotColor: Colors.red,
        backgroundColor: Colors.red.shade50,
        borderColor: Colors.red.shade200,
      );
    }

    return _StatusInfo(
      statusText: 'Not Verified',
      description:
          'Complete KYC verification to unlock all platform features and increase your trading limits.',
      icon: Icons.account_circle_outlined,
      iconColor: Colors.blue.shade700,
      dotColor: Colors.orange,
      backgroundColor: Colors.blue.shade50,
      borderColor: Colors.blue.shade200,
    );
  }
}

class _StatusInfo {
  final String statusText;
  final String description;
  final IconData icon;
  final Color iconColor;
  final Color dotColor;
  final Color backgroundColor;
  final Color borderColor;

  const _StatusInfo({
    required this.statusText,
    required this.description,
    required this.icon,
    required this.iconColor,
    required this.dotColor,
    required this.backgroundColor,
    required this.borderColor,
  });
}
