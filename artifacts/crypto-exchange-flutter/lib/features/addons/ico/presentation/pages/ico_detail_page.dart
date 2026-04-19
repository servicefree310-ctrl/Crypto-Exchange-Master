import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../domain/entities/ico_offering_entity.dart';
import '../bloc/ico_bloc.dart';
import '../bloc/ico_event.dart';
import '../bloc/ico_state.dart';
import '../widgets/ico_card.dart';
import '../widgets/ico_error_state.dart';
import '../widgets/ico_loading_state.dart';
import '../widgets/ico_invest_sheet.dart';

class IcoDetailPage extends StatelessWidget {
  const IcoDetailPage({super.key, required this.offeringId});

  final String offeringId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.instance<IcoBloc>()..add(IcoLoadOfferingDetailRequested(offeringId)),
      child: Scaffold(
        appBar: AppBar(title: const Text('ICO Detail')),
        body: BlocBuilder<IcoBloc, IcoState>(
          builder: (context, state) {
            if (state is IcoLoading) {
              return const IcoLoadingState(showPortfolio: false);
            }
            if (state is IcoError) {
              return IcoErrorState(
                  message: state.message,
                  onRetry: () {
                    context.read<IcoBloc>().add(IcoLoadOfferingDetailRequested(offeringId));
                  });
            }
            if (state is IcoOfferingDetailLoaded) {
              final offering = state.offering;
              return _buildDetail(context, offering);
            }
            return const SizedBox.shrink();
          },
        ),
        bottomNavigationBar: BlocBuilder<IcoBloc, IcoState>(
          builder: (context, state) {
            if (state is IcoOfferingDetailLoaded) {
              final offering = state.offering;
              final canInvest = offering.isActive;
              return Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: canInvest
                      ? () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(16),
                              ),
                            ),
                            builder: (_) => BlocProvider.value(
                              value: context.read<IcoBloc>(),
                              child: IcoInvestSheet(offering: offering),
                            ),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(canInvest ? 'Invest Now' : 'Closed'),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildDetail(BuildContext context, IcoOfferingEntity o) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IcoCard(offering: o, showProgress: true),
          const SizedBox(height: 24),
          Text('About', style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(o.description),
          const SizedBox(height: 24),
          Text('Tokenomics', style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _statChip(
                  'Total supply', o.totalSupply?.toStringAsFixed(0) ?? '-'),
              _statChip('Tokens for sale',
                  o.tokensForSale?.toStringAsFixed(0) ?? '-'),
              _statChip(
                  'Sale %',
                  o.salePercentage != null
                      ? '${o.salePercentage!.toStringAsFixed(1)}%'
                      : '-'),
              _statChip('Blockchain', o.blockchain),
              _statChip('Token type', o.tokenType.name),
            ],
          ),
          const SizedBox(height: 24),
          if (o.teamMembers.isNotEmpty) ...[
            Text('Team', style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            _buildTeam(o),
          ],
          if (o.roadmapItems.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text('Roadmap', style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            _buildRoadmap(o),
          ],
        ],
      ),
    );
  }

  Widget _statChip(String label, String value) {
    return Chip(
      label: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(fontSize: 11)),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
    );
  }

  Widget _buildTeam(IcoOfferingEntity o) {
    return GridView.count(
      crossAxisCount: 2,
      childAspectRatio: 3 / 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: o.teamMembers
          .map((m) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      CircleAvatar(backgroundImage: NetworkImage(m.avatar)),
                      const SizedBox(height: 8),
                      Text(m.name,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(m.role, style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ))
          .toList(),
    );
  }

  Widget _buildRoadmap(IcoOfferingEntity o) {
    return Column(
      children: o.roadmapItems
          .map((r) => ListTile(
                leading: Icon(r.completed ? Icons.check_circle : Icons.circle),
                title: Text(r.title),
                subtitle: Text(r.date),
              ))
          .toList(),
    );
  }
}
