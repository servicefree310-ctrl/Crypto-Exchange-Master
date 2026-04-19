import 'package:flutter/material.dart';
import '../../../../../core/theme/global_theme_extensions.dart';
import '../../domain/entities/mlm_user_entity.dart';

class MlmUserNodeWidget extends StatelessWidget {
  const MlmUserNodeWidget({
    super.key,
    required this.user,
    this.isCurrentUser = false,
    this.showStats = false,
    this.onTap,
  });

  final MlmUserEntity user;
  final bool isCurrentUser;
  final bool showStats;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isCurrentUser
              ? context.priceUpColor.withValues(alpha: 0.1)
              : context.colors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isCurrentUser ? context.priceUpColor : context.borderColor,
            width: isCurrentUser ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Avatar
            CircleAvatar(
              radius: 24,
              backgroundColor: context.priceUpColor.withValues(alpha: 0.2),
              backgroundImage:
                  user.avatar != null ? NetworkImage(user.avatar!) : null,
              child: user.avatar == null
                  ? Text(
                      _getInitials(user.firstName, user.lastName),
                      style: context.labelM.copyWith(
                        color: context.priceUpColor,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),

            const SizedBox(height: 8),

            // Name
            Text(
              '${user.firstName} ${user.lastName}',
              style: context.labelM.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            if (isCurrentUser)
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: context.priceUpColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'YOU',
                  style: context.labelS.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),

            if (showStats && user.status.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  user.status.toUpperCase(),
                  style: context.labelS.copyWith(
                    color: context.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

            if (showStats) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    context,
                    'Joined',
                    '${user.joinDate.day}/${user.joinDate.month}/${user.joinDate.year}',
                  ),
                  _buildStatItem(
                    context,
                    'Status',
                    user.status,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: context.labelM.copyWith(
            fontWeight: FontWeight.bold,
            color: context.priceUpColor,
          ),
        ),
        Text(
          label,
          style: context.labelS.copyWith(
            color: context.textSecondary,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  String _getInitials(String firstName, String lastName) {
    final first = firstName.isNotEmpty ? firstName[0] : '';
    final last = lastName.isNotEmpty ? lastName[0] : '';
    return '$first$last'.toUpperCase();
  }
}
