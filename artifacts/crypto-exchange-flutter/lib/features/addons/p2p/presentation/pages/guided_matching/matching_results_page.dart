import 'package:flutter/material.dart';
import '../../../../../../core/theme/global_theme_extensions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/matching/guided_matching_bloc.dart';
import '../../bloc/matching/guided_matching_state.dart';
import '../../widgets/matching/matched_offer_card.dart';
import '../../bloc/matching/guided_matching_event.dart';

/// Guided Matching – results view displaying matched offers.
class MatchingResultsPage extends StatefulWidget {
  const MatchingResultsPage({super.key});

  @override
  State<MatchingResultsPage> createState() => _MatchingResultsPageState();
}

class _MatchingResultsPageState extends State<MatchingResultsPage> {
  String _sortOption = 'score';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          context.colors.surface,
      appBar: AppBar(
        title: const Text('Matching Results'),
        backgroundColor:
            context.colors.surface,
      ),
      body: BlocBuilder<GuidedMatchingBloc, GuidedMatchingState>(
        builder: (context, state) {
          if (state is GuidedMatchingLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is GuidedMatchingError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(state.failure.message),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => context
                        .read<GuidedMatchingBloc>()
                        .add(const GuidedMatchingRetryRequested()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          if (state is GuidedMatchingLoaded) {
            final response = state.response;
            var matches = [...response.matches];
            // sorting
            if (_sortOption == 'price') {
              matches.sort((a, b) => a.price.compareTo(b.price));
            } else {
              matches.sort((a, b) => b.matchScore.compareTo(a.matchScore));
            }
            if (matches.isEmpty) {
              return const Center(child: Text('No matches found'));
            }

            return Column(
              children: [
                _buildSummaryBar(response),
                _buildSortBar(),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: matches.length,
                    itemBuilder: (context, index) {
                      final offer = matches[index];
                      return MatchedOfferCard(
                        offer: offer,
                        onTap: () => _navigateToOfferDetail(offer.id),
                        onTrade: () => _navigateToOfferDetail(offer.id),
                      );
                    },
                  ),
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildSummaryBar(dynamic response) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: context.colors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${response.matchCount} matches found',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                'Best price: ',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                '\$${response.bestPrice.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              if (response.estimatedSavings > 0) ...[
                const SizedBox(width: 6),
                Text(
                  '• Est. savings \$${response.estimatedSavings.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.colors.primary,
                      ),
                ),
              ]
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSortBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      color: context.colors.surface,
      child: Row(
        children: [
          const Text('Sort by:'),
          const SizedBox(width: 8),
          DropdownButton<String>(
            value: _sortOption,
            items: const [
              DropdownMenuItem(value: 'score', child: Text('Match Score')),
              DropdownMenuItem(value: 'price', child: Text('Best Price')),
            ],
            onChanged: (val) => setState(() => _sortOption = val!),
            underline: const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  void _navigateToOfferDetail(String id) {
    Navigator.pushNamed(context, '/p2p/offer/$id');
  }
}
