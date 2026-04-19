import 'package:flutter/material.dart';
import '../../../trade/presentation/pages/trading_page.dart';

class TradingTab extends StatelessWidget {
  const TradingTab({
    super.key,
    this.symbol,
    this.marketData,
    this.initialAction,
  });

  final String? symbol;
  final dynamic marketData;
  final String? initialAction;

  @override
  Widget build(BuildContext context) {
    return TradingPage(
      symbol: symbol,
      marketData: marketData,
      initialAction: initialAction,
    );
  }
}
