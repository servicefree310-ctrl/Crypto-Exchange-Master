import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/global_theme_extensions.dart';
import '../../../../injection/injection.dart';
import '../bloc/trading_header_bloc.dart';
import '../bloc/ai_investment_bloc.dart';
import 'spot_trading_section.dart';
import 'ai_investment_section.dart';

class TradingSectionSwitcher extends StatefulWidget {
  const TradingSectionSwitcher({super.key, required this.symbol});

  final String symbol;

  @override
  State<TradingSectionSwitcher> createState() => _TradingSectionSwitcherState();
}

class _TradingSectionSwitcherState extends State<TradingSectionSwitcher>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocBuilder<TradingHeaderBloc, TradingHeaderState>(
      buildWhen: (prev, curr) {
        if (prev is TradingHeaderLoaded && curr is TradingHeaderLoaded) {
          // Rebuild on both type and symbol changes
          return prev.selectedType != curr.selectedType ||
              prev.symbol != curr.symbol;
        }
        return prev.runtimeType != curr.runtimeType;
      },
      builder: (context, state) {
        if (state is TradingHeaderLoaded) {
          int index = 0;
          if (state.selectedType == TradingType.isolatedMargin) {
            index = 1;
          }
          return IndexedStack(
            index: index,
            children: [
              SpotTradingSection(symbol: state.symbol),
              BlocProvider(
                create: (context) => getIt<AiInvestmentBloc>(),
                child: const AiInvestmentSection(),
              ),
            ],
          );
        }
        return Container(
          color: context.theme.scaffoldBackgroundColor,
          child: const SizedBox.shrink(),
        );
      },
    );
  }
}
