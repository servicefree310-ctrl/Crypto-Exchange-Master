import 'package:flutter/material.dart';

import '../../domain/entities/kyc_level_entity.dart';
import '../../domain/entities/kyc_application_entity.dart';

class KycLevelCard extends StatelessWidget {
  final KycLevelEntity level;
  final KycApplicationEntity? application;
  final VoidCallback onTap;

  const KycLevelCard({
    super.key,
    required this.level,
    this.application,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final statusInfo = _getStatusInfo();

    return Card(
      margin: EdgeInsets.zero,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: (statusInfo?.color ?? Theme.of(context).primaryColor)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: statusInfo != null
                          ? Icon(statusInfo.icon, color: statusInfo.color, size: 20)
                          : Text(
                              'L${level.level}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          level.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (level.description != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              level.description!,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (statusInfo != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusInfo.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        statusInfo.label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: statusInfo.color,
                        ),
                      ),
                    )
                  else
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey,
                    ),
                ],
              ),
              if (level.features != null && level.features!.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                Text(
                  'Features unlocked:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: level.features!.map((feature) {
                    return Chip(
                      label: Text(
                        feature,
                        style: const TextStyle(fontSize: 12),
                      ),
                      backgroundColor:
                          Theme.of(context).primaryColor.withValues(alpha: 0.1),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  _StatusBadge? _getStatusInfo() {
    if (application == null) return null;

    switch (application!.status) {
      case KycApplicationStatus.approved:
        return _StatusBadge(
          label: 'Approved',
          color: Colors.green,
          icon: Icons.check_circle,
        );
      case KycApplicationStatus.pending:
        return _StatusBadge(
          label: 'Pending',
          color: Colors.amber.shade700,
          icon: Icons.hourglass_top,
        );
      case KycApplicationStatus.rejected:
        return _StatusBadge(
          label: 'Rejected',
          color: Colors.red,
          icon: Icons.cancel,
        );
      case KycApplicationStatus.additionalInfoRequired:
        return _StatusBadge(
          label: 'Action Required',
          color: Colors.blue,
          icon: Icons.info,
        );
    }
  }
}

class _StatusBadge {
  final String label;
  final Color color;
  final IconData icon;

  const _StatusBadge({
    required this.label,
    required this.color,
    required this.icon,
  });
}
