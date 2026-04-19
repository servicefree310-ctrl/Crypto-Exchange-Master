import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import '../../../market/presentation/pages/market_page.dart';

class MarketTab extends StatelessWidget {
  const MarketTab({super.key});

  @override
  Widget build(BuildContext context) {
    dev.log('🔵 MARKET_TAB: Building market tab with KuCoin UI');

    return const MarketPage();
  }
}
