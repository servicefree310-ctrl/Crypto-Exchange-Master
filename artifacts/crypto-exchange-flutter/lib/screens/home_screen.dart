import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../services/state.dart';
import '../utils/format.dart';
import 'markets_screen.dart';
import 'wallet_screen.dart';
import 'account_screen.dart';
import 'login_screen.dart';
import 'trade_screen.dart';
import 'transfer_screen.dart';
import 'deposit_screen.dart';
import 'withdraw_screen.dart';
import 'earn_screen.dart';
import 'refer_screen.dart';
import 'fees_screen.dart';
import 'orders_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _idx = 0;
  final _pages = const [_Dashboard(), MarketsScreen(), TradeQuickEntry(), WalletScreen(), AccountScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _idx, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _idx,
        onTap: (i) => setState(() => _idx = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.show_chart_outlined), activeIcon: Icon(Icons.show_chart), label: 'Markets'),
          BottomNavigationBarItem(icon: Icon(Icons.candlestick_chart_outlined), activeIcon: Icon(Icons.candlestick_chart), label: 'Trade'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_outlined), activeIcon: Icon(Icons.account_balance_wallet), label: 'Wallet'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Account'),
        ],
      ),
    );
  }
}

class TradeQuickEntry extends StatelessWidget {
  const TradeQuickEntry({super.key});
  @override
  Widget build(BuildContext context) {
    final m = context.watch<MarketsState>();
    final pairs = m.pairs.take(20).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Trade', style: TextStyle(fontWeight: FontWeight.w800))),
      body: pairs.isEmpty ? const Center(child: CircularProgressIndicator(color: AppColors.primary)) :
        ListView.separated(
          padding: const EdgeInsets.all(8),
          itemCount: pairs.length,
          separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.border),
          itemBuilder: (_, i) {
            final p = pairs[i];
            final symbol = (p['symbol'] ?? '').toString();
            final last = Fmt.parseNum(p['lastPrice']);
            final change = Fmt.parseNum(p['change24h']);
            final up = change >= 0;
            final isInr = p['quoteCoin'] == 'INR';
            return InkWell(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TradeScreen(symbol: symbol))),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                child: Row(children: [
                  Expanded(child: Text(symbol, style: const TextStyle(color: AppColors.fg, fontWeight: FontWeight.w700))),
                  Expanded(child: Text('${isInr ? '₹' : ''}${Fmt.num2(last)}', textAlign: TextAlign.right, style: const TextStyle(color: AppColors.fg))),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 70,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(color: (up ? AppColors.success : AppColors.danger).withValues(alpha: 0.18), borderRadius: BorderRadius.circular(4)),
                      child: Text(Fmt.pct(change), textAlign: TextAlign.center, style: TextStyle(color: up ? AppColors.success : AppColors.danger, fontWeight: FontWeight.w700, fontSize: 11)),
                    ),
                  ),
                ]),
              ),
            );
          },
        ),
    );
  }
}

class _Dashboard extends StatelessWidget {
  const _Dashboard();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthState>();
    final m = context.watch<MarketsState>();
    final topPairs = m.pairs.take(6).toList();
    final topGainers = [...m.coins]..sort((a, b) => Fmt.parseNum(b['change24h']).compareTo(Fmt.parseNum(a['change24h'])));

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 14,
        title: Row(children: const [
          Text('ZEBVIX', style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.primary, fontSize: 22, letterSpacing: 1)),
          SizedBox(width: 6),
          Text('Exchange', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.fg, fontSize: 14)),
        ]),
        actions: [
          if (!auth.isLoggedIn)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilledButton(
                style: FilledButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6)),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
                child: const Text('Login', style: TextStyle(fontSize: 12)),
              ),
            )
          else
            IconButton(icon: const Icon(Icons.notifications_outlined, color: AppColors.fg), onPressed: () {}),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () => m.refresh(),
        child: ListView(padding: const EdgeInsets.all(12), children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppColors.primary, Color(0xFF0E37C7)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(auth.isLoggedIn ? 'Welcome back, ${auth.user?['name'] ?? auth.user?['email'] ?? ''}' : 'Welcome to ZEBVIX', style: const TextStyle(color: Colors.white70, fontSize: 12)),
              const SizedBox(height: 6),
              const Text('Trade Crypto · INR & USDT', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              const Text('Spot · Futures · Earn · Refer & Earn 30%', style: TextStyle(color: Colors.white70, fontSize: 12)),
            ]),
          ),
          const SizedBox(height: 18),
          const Text('Quick Actions', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.fg, fontSize: 14)),
          const SizedBox(height: 10),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 4,
            crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 1,
            children: [
              _action(context, Icons.add_circle_outline, 'Deposit', AppColors.success, const DepositScreen()),
              _action(context, Icons.outbox, 'Withdraw', AppColors.danger, const WithdrawScreen()),
              _action(context, Icons.swap_horiz, 'Transfer', AppColors.primary, const TransferScreen()),
              _action(context, Icons.savings, 'Earn', AppColors.accent, const EarnScreen()),
              _action(context, Icons.show_chart, 'Spot', AppColors.primary, null),
              _action(context, Icons.receipt_long, 'Orders', AppColors.fg, const OrdersScreen()),
              _action(context, Icons.share, 'Refer', AppColors.success, const ReferScreen()),
              _action(context, Icons.workspace_premium, 'VIP', AppColors.accent, const FeesScreen()),
            ],
          ),
          const SizedBox(height: 18),
          Row(children: const [
            Text('Top Markets', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.fg, fontSize: 14)),
          ]),
          const SizedBox(height: 10),
          if (topPairs.isEmpty) const Padding(padding: EdgeInsets.all(20), child: Center(child: CircularProgressIndicator(color: AppColors.primary))),
          ...topPairs.map((p) {
            final symbol = (p['symbol'] ?? '').toString();
            final last = Fmt.parseNum(p['lastPrice']);
            final change = Fmt.parseNum(p['change24h']);
            final up = change >= 0;
            final isInr = p['quoteCoin'] == 'INR';
            return InkWell(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TradeScreen(symbol: symbol))),
              child: Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
                child: Row(children: [
                  Expanded(child: Text(symbol, style: const TextStyle(color: AppColors.fg, fontWeight: FontWeight.w700))),
                  Expanded(child: Text('${isInr ? '₹' : ''}${Fmt.num2(last)}', textAlign: TextAlign.right, style: const TextStyle(color: AppColors.fg, fontWeight: FontWeight.w700))),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 70,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(color: (up ? AppColors.success : AppColors.danger).withValues(alpha: 0.18), borderRadius: BorderRadius.circular(4)),
                      child: Text(Fmt.pct(change), textAlign: TextAlign.center, style: TextStyle(color: up ? AppColors.success : AppColors.danger, fontWeight: FontWeight.w800, fontSize: 11)),
                    ),
                  ),
                ]),
              ),
            );
          }),
          const SizedBox(height: 18),
          const Text('Top Gainers (24h)', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.fg, fontSize: 14)),
          const SizedBox(height: 10),
          SizedBox(
            height: 110,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: topGainers.take(8).length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final c = topGainers[i];
                final change = Fmt.parseNum(c['change24h']);
                final up = change >= 0;
                return Container(
                  width: 130,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text((c['symbol'] ?? '').toString(), style: const TextStyle(color: AppColors.fg, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text('\$${Fmt.num2(Fmt.parseNum(c['currentPrice']))}', style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                    const Spacer(),
                    Text(Fmt.pct(change), style: TextStyle(color: up ? AppColors.success : AppColors.danger, fontWeight: FontWeight.w800, fontSize: 14)),
                  ]),
                );
              },
            ),
          ),
        ]),
      ),
    );
  }

  Widget _action(BuildContext context, IconData icon, String label, Color color, Widget? screen) {
    return InkWell(
      onTap: () {
        final auth = context.read<AuthState>();
        if (screen == null) return;
        if (!auth.isLoggedIn && (label == 'Deposit' || label == 'Withdraw' || label == 'Transfer' || label == 'Orders')) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
          return;
        }
        Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(color: AppColors.fg, fontSize: 11, fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }
}
