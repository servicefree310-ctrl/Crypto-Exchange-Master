import 'package:flutter/material.dart';
// ignore_for_file: undefined_method, creation_with_non_type, unchecked_use_of_nullable_value, undefined_getter
import '../../bloc/offers/offers_state.dart';
import '../../../domain/entities/p2p_offer_entity.dart';

/// Matching Results Widget
///
/// Displays P2P offers found through guided matching.
/// Based on V5's MatchingResults component with mobile-first design.
class MatchingResultsWidget extends StatelessWidget {
  const MatchingResultsWidget({
    super.key,
    required this.criteria,
    required this.state,
    required this.onStartOver,
    required this.onRefresh,
    required this.onBrowseAll,
  });

  final Map<String, dynamic> criteria;
  final OffersState state;
  final VoidCallback onStartOver;
  final VoidCallback onRefresh;
  final VoidCallback onBrowseAll;

  @override
  Widget build(BuildContext context) {
    if (state is OffersLoading) {
      return _buildLoadingState(context);
    }

    if (state is OffersError) {
      return _buildErrorState(context, state as OffersError);
    }

    if (state is OffersEmpty) {
      return _buildEmptyState(context, state as OffersEmpty);
    }

    if (state is OffersLoaded) {
      return _buildResultsState(context, state as OffersLoaded);
    }

    return _buildInitialState(context);
  }

  Widget _buildLoadingState(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text('Finding your perfect matches...',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              )),
          const SizedBox(height: 8),
          Text('This may take a moment as we search for the best offers',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, OffersError state) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text('Failed to Load Offers',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                )),
            const SizedBox(height: 8),
            Text(
                'We encountered an error while fetching matching offers. Please try again.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: onRefresh,
                  child: const Text('Try Again'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: onStartOver,
                  child: const Text('Start Over'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, OffersEmpty state) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off,
                size: 64,
                color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text('No Matching Offers Found',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                )),
            const SizedBox(height: 8),
            Text(
                'We couldn\'t find any offers that match your criteria. Try adjusting your preferences or check back later.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: onRefresh,
                  child: const Text('Refresh'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: onStartOver,
                  child: const Text('Start Over'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsState(BuildContext context, OffersLoaded state) {
    final theme = Theme.of(context);
    final tradeType = criteria['tradeType']?.toString().toLowerCase() ?? 'buy';
    final oppositeType = tradeType == 'buy' ? 'sellers' : 'buyers';

    return Column(
      children: [
        // Header with results count and controls
        _buildResultsHeader(context, state, oppositeType),

        const SizedBox(height: 16),

        // Offers list
        Expanded(
          child: state.offers.isEmpty
              ? _buildEmptyState(context, const OffersEmpty())
              : _buildOffersList(context, state.offers),
        ),

        // Footer with actions
        _buildResultsFooter(context),
      ],
    );
  }

  Widget _buildResultsHeader(
      BuildContext context, OffersLoaded state, String oppositeType) {
    final theme = Theme.of(context);
    final crypto =
        criteria['cryptocurrency']?.toString().toUpperCase() ?? 'CRYPTO';

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'We found ${state.offers.length} matching $oppositeType for $crypto',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Based on your preferences, here are the best offers for you',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOffersList(BuildContext context, List<P2POfferEntity> offers) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: offers.length,
      itemBuilder: (context, index) {
        final offer = offers[index];
        return _buildOfferCard(context, offer, index);
      },
    );
  }

  Widget _buildOfferCard(
      BuildContext context, P2POfferEntity offer, int index) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Trader info header
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
                  child: Text(
                    (offer.user?['firstName'] as String?)?.isNotEmpty == true
                        ? (offer.user!['firstName'] as String)[0].toUpperCase()
                        : 'T',
                    style: TextStyle(
                      color: theme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            (offer.user?['firstName'] as String?)?.isNotEmpty == true
                                ? offer.user!['firstName'] as String
                                : 'Trader',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (offer.user?['kyc']?['level'] == 'verified') ...[
                            const SizedBox(width: 4),
                            Icon(Icons.verified, size: 16, color: Colors.green),
                          ],
                        ],
                      ),
                      Text(
                        '${offer.user?['avatar'] ?? 0} trades • Online',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color
                              ?.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Match',
                    style: TextStyle(
                      color: theme.primaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Offer details
            Row(
              children: [
                Expanded(
                  child: _buildInfoBox(
                    context,
                    'Price',
                    '\$${offer.priceConfig.finalPrice.toStringAsFixed(2)}',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildInfoBox(
                    context,
                    'Available',
                    '${offer.amountConfig.available.toStringAsFixed(4)} ${offer.currency}',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildInfoBox(
                    context,
                    'Limits',
                    '\$${offer.amountConfig.min.toStringAsFixed(0)}-\$${offer.amountConfig.max.toStringAsFixed(0)}',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Payment methods
            if (offer.paymentMethods.isNotEmpty) ...[
              Text(
                'Payment Methods:',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 4,
                children: offer.paymentMethods.take(3).map((method) {
                  return Chip(
                    label: Text(
                      method.name,
                      style: const TextStyle(fontSize: 11),
                    ),
                    backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],

            // Trade button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _startTrade(context, offer),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Trade Now'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBox(BuildContext context, String label, String value) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildResultsFooter(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: onStartOver,
              child: const Text('Start Over'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: onBrowseAll,
              child: const Text('Browse All'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialState(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search,
              size: 64,
              color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          Text('Ready to Find Matches',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              )),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: onRefresh,
            child: const Text('Start Search'),
          ),
        ],
      ),
    );
  }

  void _startTrade(BuildContext context, P2POfferEntity offer) {
    // TODO: Navigate to trade creation page
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Starting trade with ${offer.user.firstName}...'),
        backgroundColor: Colors.green,
      ),
    );

    // In a real implementation, this would:
    // 1. Create a trade with the offer
    // 2. Navigate to trade details page
    // 3. Handle trade creation errors
  }
}
