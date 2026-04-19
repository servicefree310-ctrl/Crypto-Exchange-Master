import 'package:flutter/material.dart';
import '../../../../../core/theme/global_theme_extensions.dart';
import '../../domain/entities/mlm_network_entity.dart';

class MlmUnilevelTreeWidget extends StatelessWidget {
  const MlmUnilevelTreeWidget({
    super.key,
    required this.network,
    required this.levels,
  });

  final MlmNetworkEntity network;
  final List<List<MlmNetworkNodeEntity>> levels;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.layers_rounded,
              size: 64,
              color: context.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'Unilevel Tree View',
              style: context.h6.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Unilevel tree visualization coming soon',
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
}
