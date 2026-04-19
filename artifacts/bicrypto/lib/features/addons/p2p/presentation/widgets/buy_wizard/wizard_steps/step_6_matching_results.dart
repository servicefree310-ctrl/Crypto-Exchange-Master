import 'package:flutter/material.dart';
import '../../../../../../../core/theme/global_theme_extensions.dart';
import '../../../../domain/entities/p2p_offer_entity.dart';
import '../../offers/offer_card.dart';

/// Step 6: Matching Results
class Step6MatchingResults extends StatelessWidget {
  final Map<String, dynamic> formData;
  final List<P2POfferEntity> offers;
  final Function() onStartOver;

  const Step6MatchingResults({
    super.key,
    required this.formData,
    required this.offers,
    required this.onStartOver,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.buyColor.withValues(alpha: 0.05),
              border: Border.all(
                color: context.buyColor.withValues(alpha: 0.2),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.auto_awesome,
                  color: context.buyColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Matching Results',
                        style: context.bodyL.copyWith(
                          fontWeight: FontWeight.bold,
                          color: context.textPrimary,
                        ),
                      ),
                      Text(
                        'Based on your preferences, we found ${offers.length} offer(s) for you',
                        style: context.bodyS.copyWith(
                          color: context.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Results
          Expanded(
            child: offers.isEmpty
                ? _buildEmptyResults(context)
                : _buildOffersList(context),
          ),

          // Action buttons
          Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onStartOver,
                    child: const Text('Start Over'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed:
                        offers.isNotEmpty ? () => _refineSearch(context) : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.buyColor,
                    ),
                    child: const Text('Refine Search'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyResults(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: context.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            'No matching offers found',
            style: context.h6.copyWith(
              fontWeight: FontWeight.bold,
              color: context.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your preferences or check back later for new offers.',
            style: context.bodyM.copyWith(
              color: context.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildOffersList(BuildContext context) {
    return ListView.builder(
      itemCount: offers.length,
      itemBuilder: (context, index) {
        final offer = offers[index];
        return OfferCard(
          offer: offer,
          cardType: OfferCardType.buy,
          onTap: () => _viewOfferDetail(context, offer),
          onTrade: () => _initiateTrade(context, offer),
        );
      },
    );
  }

  void _viewOfferDetail(BuildContext context, P2POfferEntity offer) {
    // Navigate to offer detail page
    Navigator.pushNamed(
      context,
      '/p2p/offer/${offer.id}',
      arguments: {'offer': offer, 'mode': 'buy'},
    );
  }

  void _initiateTrade(BuildContext context, P2POfferEntity offer) {
    // Show trade confirmation dialog or navigate to trade flow
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Initiate Trade'),
        content:
            Text('Are you sure you want to start a trade with this offer?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement trade initiation
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Trade initiated successfully!')),
              );
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _refineSearch(BuildContext context) {
    // Go back to modify search criteria
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Refine search feature coming soon!')),
    );
  }
}
