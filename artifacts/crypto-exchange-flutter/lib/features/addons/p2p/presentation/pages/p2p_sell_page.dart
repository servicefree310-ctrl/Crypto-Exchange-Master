import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/theme/global_theme_extensions.dart';
import '../../../../../injection/injection.dart';
import '../bloc/offers/offers_bloc.dart';
import '../bloc/offers/offers_event.dart';
import '../bloc/offers/offers_state.dart';
import '../widgets/common/p2p_state_widgets.dart';
import '../widgets/offers/offer_card.dart';

class P2PSellPage extends StatefulWidget {
  const P2PSellPage({super.key});

  @override
  State<P2PSellPage> createState() => _P2PSellPageState();
}

class _P2PSellPageState extends State<P2PSellPage> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          getIt<OffersBloc>()..add(const OffersLoadRequested(type: 'BUY')),
      child: Scaffold(
        backgroundColor: context.colors.surface,
        appBar: AppBar(
          title: const Text('Sell Crypto'),
          backgroundColor: context.colors.surface,
        ),
        body: BlocBuilder<OffersBloc, OffersState>(
          builder: (context, state) {
            if (state is OffersLoading) {
              return const P2PShimmerLoading(itemCount: 8, itemHeight: 140);
            }

            if (state is OffersError) {
              return P2PErrorWidget(
                message: state.failure.message,
                onRetry: () => context
                    .read<OffersBloc>()
                    .add(const OffersLoadRequested(type: 'BUY')),
              );
            }

            if (state is OffersLoaded) {
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.offers.length,
                itemBuilder: (context, index) {
                  final offer = state.offers[index];
                  return OfferCard(
                    offer: offer,
                    cardType: OfferCardType.sell,
                  );
                },
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
