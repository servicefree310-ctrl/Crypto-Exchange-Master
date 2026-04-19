import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import '../../../wallet/presentation/pages/wallet_overview_page.dart';

class WalletTab extends StatelessWidget {
  const WalletTab({super.key});

  @override
  Widget build(BuildContext context) {
    dev.log('🔵 WALLET_TAB: Building wallet tab with new wallet system');
    
    // Return our new wallet overview page
    return const WalletOverviewPage();
  }
} 