import 'package:flutter/material.dart';
import 'package:mobile/features/addons/staking/domain/entities/staking_position_entity.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/features/addons/staking/presentation/bloc/position_bloc.dart';
import 'package:mobile/features/addons/staking/presentation/bloc/position_event.dart';
import 'package:mobile/features/addons/staking/presentation/pages/position_detail_page.dart';

class PositionCard extends StatelessWidget {
  final StakingPositionEntity position;
  const PositionCard({super.key, required this.position});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Position #${position.id}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    position.status,
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Staked: \$${position.amount.toStringAsFixed(4)}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              'Rewards: ${position.earningsUnclaimed.toStringAsFixed(4)}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (position.timeRemaining != null) ...[
              const SizedBox(height: 8),
              Text(
                'Time Remaining: ${position.timeRemaining} days',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                final bloc = context.read<PositionBloc>();
                if (position.status == 'ACTIVE') {
                  bloc.add(ClaimRewardsRequested(position.id));
                } else if (position.status == 'PENDING_WITHDRAWAL') {
                  bloc.add(WithdrawRequested(position.id));
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PositionDetailPage(position: position),
                    ),
                  );
                }
              },
              child: Text(
                position.status == 'ACTIVE' ? 'Claim Rewards' : 'View Details',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
