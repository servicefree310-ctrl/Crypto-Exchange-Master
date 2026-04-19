import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/offers/offers_bloc.dart';
import '../bloc/offers/offers_state.dart';
import '../bloc/offers/offers_event.dart';

/// P2P Matching Results Page - V5 Flow Implementation
class P2PMatchingResultsPage extends StatelessWidget {
  const P2PMatchingResultsPage({
    super.key,
    required this.criteria,
  });

  final Map<String, dynamic> criteria;

  @override
  Widget build(BuildContext context) {
    final tradeType =
        criteria['tradeType']?.toString().toUpperCase() ?? 'TRADE';
    final crypto =
        criteria['cryptocurrency']?.toString().toUpperCase() ?? 'CRYPTO';

    return Scaffold(
      appBar: AppBar(
        title: Text('$tradeType $crypto - Results'),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: BlocBuilder<OffersBloc, OffersState>(
        builder: (context, state) {
          if (state is OffersLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Finding your perfect matches...'),
                ],
              ),
            );
          }

          if (state is OffersError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text('Failed to load offers'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _refresh(context),
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            );
          }

          if (state is OffersEmpty ||
              (state is OffersLoaded && state.offers.isEmpty)) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.search_off, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('No matching offers found'),
                  const Text('Try adjusting your criteria'),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      OutlinedButton(
                        onPressed: () => _refresh(context),
                        child: const Text('Refresh'),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () => _startOver(context),
                        child: const Text('Start Over'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }

          if (state is OffersLoaded) {
            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Text('Found ${state.offers.length} matching offers',
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, color: Colors.green)),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: state.offers.length,
                    itemBuilder: (context, index) {
                      final offer = state.offers[index];
                      return Card(
                        margin: const EdgeInsets.all(8),
                        child: ListTile(
                          title: Text(
                              'Price: \$${offer.priceConfig.finalPrice.toStringAsFixed(2)}'),
                          subtitle: Text(
                              'Amount: ${offer.amountConfig.total.toStringAsFixed(4)} ${offer.currency}'),
                          trailing: ElevatedButton(
                            onPressed: () => _startTrade(context, offer.id),
                            child: const Text('Trade'),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _startOver(context),
                          child: const Text('Start Over'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(context)
                              .pushReplacementNamed('/p2p'),
                          child: const Text('Browse All'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }

          return const Center(child: Text('No offers found'));
        },
      ),
    );
  }

  void _startOver(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _refresh(BuildContext context) {
    context.read<OffersBloc>().add(GuidedMatchingRequested(criteria: criteria));
  }

  void _startTrade(BuildContext context, String offerId) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('Starting trade with offer $offerId...'),
          backgroundColor: Colors.green),
    );
  }
}
