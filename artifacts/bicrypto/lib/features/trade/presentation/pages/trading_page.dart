import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/theme/global_theme_extensions.dart';
import '../../../../injection/injection.dart';
import '../widgets/trading_header.dart';
import '../widgets/trading_section_switcher.dart';
import '../bloc/trading_header_bloc.dart';
import '../widgets/trading_type_tabs.dart';

class TradingPage extends StatefulWidget {
  const TradingPage({
    super.key,
    this.symbol,
    this.marketData,
    this.initialAction,
  });

  final String? symbol;
  final dynamic marketData;
  final String? initialAction; // 'BUY' or 'SELL' for initial action

  @override
  State<TradingPage> createState() => _TradingPageState();
}

class _TradingPageState extends State<TradingPage> {
  late String selectedSymbol;

  @override
  void initState() {
    super.initState();

    // Use provided symbol or default
    selectedSymbol = widget.symbol ?? ApiConstants.defaultTradingPair;

    // Note: Portrait orientation is enforced globally in main.dart
    // No need to set it again here
  }

  @override
  void dispose() {
    // Note: Portrait orientation is maintained globally
    // No need to restore it here
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      body: BlocProvider(
        create: (context) => getIt<TradingHeaderBloc>()
          ..add(TradingHeaderInitialized(symbol: selectedSymbol)),
        child: Column(
          children: [
            // Trading type tabs (Spot / Futures / AI Investment)
            TradingTypeTabs(symbol: selectedSymbol),

            // Fixed Trading Header
            TradingHeader(symbol: selectedSymbol),

            // Content below header (Spot or AI section)
            Expanded(
              child: TradingSectionSwitcher(symbol: selectedSymbol),
            ),
          ],
        ),
      ),
    );
  }
}
