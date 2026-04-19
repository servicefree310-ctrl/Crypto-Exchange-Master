import 'package:flutter/material.dart';
import 'package:mobile/features/addons/staking/domain/entities/staking_position_entity.dart';

class PositionDetailPage extends StatelessWidget {
  final StakingPositionEntity position;

  const PositionDetailPage({super.key, required this.position});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Position #${position.id}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status: ${position.status}',
                style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 12),
            Text('Staked Amount: \$${position.amount.toStringAsFixed(4)}',
                style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 8),
            Text('Total Rewards: ${position.earningsTotal.toStringAsFixed(4)}',
                style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 8),
            Text(
                'Unclaimed Rewards: ${position.earningsUnclaimed.toStringAsFixed(4)}',
                style: Theme.of(context).textTheme.bodyMedium),
            if (position.timeRemaining != null) ...[
              const SizedBox(height: 8),
              Text('Time Remaining: ${position.timeRemaining} days',
                  style: Theme.of(context).textTheme.bodySmall),
            ],
          ],
        ),
      ),
    );
  }
}
