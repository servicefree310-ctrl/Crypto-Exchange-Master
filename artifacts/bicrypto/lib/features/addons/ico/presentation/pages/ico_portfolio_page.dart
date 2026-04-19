import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:get_it/get_it.dart';

import '../bloc/ico_bloc.dart';
import '../bloc/ico_event.dart';
import '../bloc/ico_state.dart';
import '../widgets/portfolio_overview_card.dart';
import '../widgets/ico_investment_card.dart';
import '../widgets/ico_error_state.dart';
import '../widgets/ico_loading_state.dart';
import '../widgets/portfolio_performance_chart.dart';
import '../pages/ico_detail_page.dart';

class IcoPortfolioPage extends StatelessWidget {
  const IcoPortfolioPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.instance<IcoBloc>()..add(const IcoLoadPortfolioRequested()),
      child: Scaffold(
        appBar: AppBar(title: const Text('My ICO Portfolio')),
        body: BlocBuilder<IcoBloc, IcoState>(
          builder: (context, state) {
            if (state is IcoLoading) {
              return const IcoLoadingState(showPortfolio: false);
            }
            if (state is IcoError) {
              return IcoErrorState(
                message: state.message,
                onRetry: () => context.read<IcoBloc>().add(const IcoLoadPortfolioRequested()),
              );
            }
            if (state is IcoPortfolioLoaded) {
              final portfolio = state.portfolio;
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<IcoBloc>().add(const IcoLoadPortfolioRequested());
                },
                child: ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: 1 + portfolio.investments.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          PortfolioOverviewCard(
                              portfolio: portfolio, compact: false),
                          const SizedBox(height: 16),
                          Text('Performance (last 30 days)',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          PortfolioPerformanceChart(
                              points:
                                  (state).performance),
                        ],
                      );
                    }
                    final inv = portfolio.investments[index - 1];
                    return IcoInvestmentCard(
                      investment: inv,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => IcoDetailPage(
                              offeringId: inv.offeringId ?? '',
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
