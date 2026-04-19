import 'package:flutter/material.dart';
import '../theme.dart';
import 'markets_screen.dart';
import 'wallet_screen.dart';
import 'account_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _idx = 0;
  final _screens = const [
    _Dashboard(),
    MarketsScreen(),
    WalletScreen(),
    AccountScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_idx],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _idx,
        onTap: (i) => setState(() => _idx = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.show_chart_outlined), activeIcon: Icon(Icons.show_chart), label: 'Markets'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_outlined), activeIcon: Icon(Icons.account_balance_wallet), label: 'Wallet'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Account'),
        ],
      ),
    );
  }
}

class _Dashboard extends StatelessWidget {
  const _Dashboard();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(children: const [
          Text('ZEBVIX', style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.primary, fontSize: 22, letterSpacing: 1)),
          SizedBox(width: 6),
          Text('Exchange', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.fg, fontSize: 14)),
        ]),
        actions: [
          IconButton(icon: const Icon(Icons.notifications_outlined, color: AppColors.fg), onPressed: () {}),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, Color(0xFF0E37C7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                Text('Welcome to ZEBVIX', style: TextStyle(color: Colors.white70, fontSize: 12)),
                SizedBox(height: 6),
                Text('Trade Crypto · INR & USDT', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                SizedBox(height: 6),
                Text('Spot · Futures · Earn · Refer', style: TextStyle(color: Colors.white70, fontSize: 12)),
              ]),
            ),
            const SizedBox(height: 18),
            const Text('Quick Actions', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.fg, fontSize: 14)),
            const SizedBox(height: 10),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 4,
              crossAxisSpacing: 8, mainAxisSpacing: 8,
              children: [
                _action(Icons.add_circle_outline, 'Deposit', AppColors.success),
                _action(Icons.outbox, 'Withdraw', AppColors.danger),
                _action(Icons.swap_horiz, 'Transfer', AppColors.primary),
                _action(Icons.savings, 'Earn', AppColors.accent),
                _action(Icons.show_chart, 'Spot', AppColors.primary),
                _action(Icons.candlestick_chart, 'Futures', AppColors.accent),
                _action(Icons.share, 'Refer', AppColors.success),
                _action(Icons.workspace_premium, 'VIP', AppColors.accent),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _action(IconData icon, String label, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(color: AppColors.fg, fontSize: 11, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}
