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
import 'banks_screen.dart';
import 'kyc_screen.dart';

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
      body: pairs.isEmpty
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : ListView.separated(
              padding: const EdgeInsets.all(8),
              itemCount: pairs.length,
              separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.border),
              itemBuilder: (_, i) {
                final p = pairs[i];
                final symbol = (p['symbol'] ?? '').toString();
                final last = Fmt.parseNum(p['lastPrice']);
                final change = Fmt.parseNum(p['change24h']);
                final up = change >= 0;
                final isInr = symbol.endsWith('INR');
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

const Map<String, Color> _coinColors = {
  'BTC': Color(0xFFF7931A), 'ETH': Color(0xFF627EEA), 'BNB': Color(0xFFF3BA2F),
  'SOL': Color(0xFF14F195), 'XRP': Color(0xFF0085C0), 'DOGE': Color(0xFFC2A633),
  'MATIC': Color(0xFF8247E5), 'USDT': Color(0xFF26A17B), 'ADA': Color(0xFF0033AD),
  'AVAX': Color(0xFFE84142), 'ATOM': Color(0xFF2E3148), 'LTC': Color(0xFF345D9D),
  'DOT': Color(0xFFE6007A), 'LINK': Color(0xFF2A5ADA),
};

enum _MarketTab { hot, gainers, losers, brandNew }
enum _MarketKind { spot, futures }
enum _QuoteFilter { inr, usdt }

class _Dashboard extends StatefulWidget {
  const _Dashboard();
  @override
  State<_Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<_Dashboard> {
  String _search = '';
  _MarketTab _tab = _MarketTab.hot;
  _MarketKind _kind = _MarketKind.spot;
  _QuoteFilter _quote = _QuoteFilter.inr;
  bool _hideBalance = false;

  void _login() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  void _go(Widget? screen, {bool requiresAuth = false}) {
    final auth = context.read<AuthState>();
    if (requiresAuth && !auth.isLoggedIn) { _login(); return; }
    if (screen == null) return;
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  String _formatPrice(double p, bool inr) {
    final sym = inr ? '₹' : '\$';
    if (p < 1) return '$sym${p.toStringAsFixed(p < 0.01 ? 6 : 4)}';
    return '$sym${Fmt.num2(p)}';
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthState>();
    final m = context.watch<MarketsState>();
    final wallets = context.watch<WalletsState>();

    final priceMap = <String, Map<String, double>>{};
    for (final c in m.coins) {
      final s = (c['symbol'] ?? '').toString();
      if (s.isEmpty) continue;
      priceMap[s] = {
        'usdt': Fmt.parseNum(c['currentPrice']),
        'inr': Fmt.parseNum(c['priceInr']),
        'change': Fmt.parseNum(c['change24h']),
      };
    }

    final coinIdToSym = <int, String>{};
    for (final c in m.coins) {
      final id = c['id'];
      final s = (c['symbol'] ?? '').toString();
      if (id is int && s.isNotEmpty) coinIdToSym[id] = s;
    }

    (String, String) splitSym(String s) {
      for (final q in ['USDT', 'USDC', 'INR', 'USD', 'BTC', 'ETH']) {
        if (s.endsWith(q) && s.length > q.length) return (s.substring(0, s.length - q.length), q);
      }
      return (s, '');
    }

    (String, String) resolveBaseQuote(Map p) {
      final baseId = p['baseCoinId'];
      final quoteId = p['quoteCoinId'];
      String? base = baseId is int ? coinIdToSym[baseId] : null;
      String? quote = quoteId is int ? coinIdToSym[quoteId] : null;
      if (base != null && quote != null) return (base, quote);
      return splitSym((p['symbol'] ?? '').toString());
    }

    final eligible = m.pairs.where((p) {
      final (_, q) = resolveBaseQuote(p as Map);
      if (_quote == _QuoteFilter.inr && q != 'INR') return false;
      if (_quote == _QuoteFilter.usdt && q != 'USDT') return false;
      if (_kind == _MarketKind.futures && p['futuresEnabled'] != true) return false;
      if (_kind == _MarketKind.spot && p['tradingEnabled'] == false) return false;
      return true;
    }).map((p) {
      final (base, quote) = resolveBaseQuote(p as Map);
      final live = priceMap[base];
      return {
        ...Map<String, dynamic>.from(p),
        'baseCoin': base,
        'quoteCoin': quote,
        'price': live != null
            ? (_quote == _QuoteFilter.inr ? (live['inr'] ?? 0) : (live['usdt'] ?? 0))
            : Fmt.parseNum(p['lastPrice']),
        'change': live != null ? (live['change'] ?? Fmt.parseNum(p['change24h'])) : Fmt.parseNum(p['change24h']),
        'vol': Fmt.parseNum(p['volume24h']),
      };
    }).map((row) {
      // Fallback: if priceMap had 0, use lastPrice
      if ((row['price'] as double) <= 0) {
        row['price'] = Fmt.parseNum(row['lastPrice']);
      }
      return row;
    }).toList();

    List<Map<String, dynamic>> sorted;
    if (_tab == _MarketTab.hot) {
      sorted = [...eligible]..sort((a, b) => (b['vol'] as double).compareTo(a['vol'] as double));
    } else if (_tab == _MarketTab.gainers) {
      sorted = eligible.where((c) => (c['change'] as double) > 0).toList()
        ..sort((a, b) => (b['change'] as double).compareTo(a['change'] as double));
    } else if (_tab == _MarketTab.losers) {
      sorted = eligible.where((c) => (c['change'] as double) < 0).toList()
        ..sort((a, b) => (a['change'] as double).compareTo(b['change'] as double));
    } else {
      sorted = [...eligible]..sort((a, b) {
        final ta = DateTime.tryParse((a['createdAt'] ?? '').toString())?.millisecondsSinceEpoch ?? 0;
        final tb = DateTime.tryParse((b['createdAt'] ?? '').toString())?.millisecondsSinceEpoch ?? 0;
        return tb.compareTo(ta);
      });
    }
    if (_search.isNotEmpty) {
      final q = _search.toLowerCase();
      sorted = sorted.where((c) =>
          (c['baseCoin'] ?? '').toString().toLowerCase().contains(q) ||
          (c['symbol'] ?? '').toString().toLowerCase().contains(q)).toList();
    }
    final filtered = sorted.take(8).toList();

    final totalInr = wallets.wallets.fold<double>(0, (s, w) => s + Fmt.parseNum(w['inrValue']));
    final kycLevel = Fmt.parseNum(auth.user?['kycLevel']).toInt();

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () => m.refresh(),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const SizedBox(height: 12),
            _header(),
            const SizedBox(height: 8),
            _searchBar(),
            const SizedBox(height: 12),
            auth.isLoggedIn ? _assetCard(totalInr, kycLevel) : _loginCta(),
            const SizedBox(height: 12),
            _quickActions(),
            const SizedBox(height: 14),
            _bannerStrip(),
            const SizedBox(height: 4),
            _marketsSection(eligible.length, filtered),
            const SizedBox(height: 14),
            _newsStrip(),
            const SizedBox(height: 10),
            _promoCard(
              icon: Icons.trending_up,
              iconColor: AppColors.success,
              title: 'Earn Passive Income',
              sub: 'Stake USDT @ 8.5% · BTC @ 4.2% · ETH @ 5.1% APY',
              onTap: () => _go(const EarnScreen(), requiresAuth: true),
            ),
            _promoCard(
              icon: Icons.card_giftcard,
              iconColor: const Color(0xFFA06AF5),
              title: 'Refer & Earn 30%',
              sub: 'Invite friends, earn lifetime trading commission',
              onTap: () => _go(const ReferScreen(), requiresAuth: true),
            ),
            const SizedBox(height: 24),
            _footer(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ------ HEADER ------
  Widget _header() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(children: [
        Container(
          width: 30, height: 30,
          decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8)),
          alignment: Alignment.center,
          child: const Text('Z', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
        ),
        const SizedBox(width: 8),
        const Expanded(child: Text('ZEBVIX', style: TextStyle(color: AppColors.fg, fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 0.5))),
        _iconBtn(Icons.qr_code_scanner, () => _go(const DepositScreen(), requiresAuth: true)),
        const SizedBox(width: 6),
        _iconBtn(Icons.search, () { /* focus search */ }),
        const SizedBox(width: 6),
        _iconBtn(Icons.notifications_outlined, () => _go(const BanksScreen(), requiresAuth: true)),
        const SizedBox(width: 6),
        _iconBtn(Icons.person_outline, () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AccountScreen()));
        }),
      ]),
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(17),
      child: Container(
        width: 34, height: 34,
        decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(17)),
        alignment: Alignment.center,
        child: Icon(icon, size: 17, color: AppColors.fg),
      ),
    );
  }

  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Container(
        height: 38,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(children: [
          const Icon(Icons.search, size: 14, color: AppColors.muted),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              onChanged: (v) => setState(() => _search = v),
              style: const TextStyle(color: AppColors.fg, fontSize: 13),
              decoration: const InputDecoration(
                hintText: 'Search BTC, ETH, SOL...',
                hintStyle: TextStyle(color: AppColors.muted, fontSize: 13),
                border: InputBorder.none,
                isCollapsed: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ]),
      ),
    );
  }

  // ------ HERO ------
  Widget _loginCta() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: InkWell(
        onTap: _login,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(14)),
          child: Row(children: [
            const Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Login or Sign Up', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
                SizedBox(height: 3),
                Text('Start trading INR & USDT pairs · Get ₹100 bonus', style: TextStyle(color: Colors.white70, fontSize: 11)),
              ]),
            ),
            Container(
              width: 32, height: 32,
              decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: const Icon(Icons.arrow_forward, size: 16, color: Colors.white),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _assetCard(double totalInr, int kycLevel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Total Portfolio (INR)', style: TextStyle(color: AppColors.muted, fontSize: 11, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Row(children: [
                  Text(
                    _hideBalance ? '₹••••••' : '₹${Fmt.num2(totalInr)}',
                    style: const TextStyle(color: AppColors.fg, fontSize: 22, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => setState(() => _hideBalance = !_hideBalance),
                    child: Icon(_hideBalance ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 15, color: AppColors.muted),
                  ),
                ]),
              ]),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.13), borderRadius: BorderRadius.circular(6)),
              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.trending_up, size: 11, color: AppColors.success),
                SizedBox(width: 4),
                Text('+0.00%', style: TextStyle(color: AppColors.success, fontSize: 11, fontWeight: FontWeight.w600)),
              ]),
            ),
          ]),
          if (kycLevel == 0) ...[
            const SizedBox(height: 12),
            InkWell(
              onTap: () => _go(const KycScreen(), requiresAuth: true),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(8)),
                child: Row(children: [
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: const [
                        Icon(Icons.verified_user_outlined, size: 11, color: AppColors.primary),
                        SizedBox(width: 6),
                        Text('KYC Level 0 → Level 1', style: TextStyle(color: AppColors.fg, fontSize: 11, fontWeight: FontWeight.w500)),
                      ]),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: 0.05,
                          minHeight: 4,
                          backgroundColor: AppColors.border,
                          valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                        ),
                      ),
                    ]),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.chevron_right, size: 14, color: AppColors.muted),
                ]),
              ),
            ),
          ],
        ]),
      ),
    );
  }

  // ------ QUICK ACTIONS ------
  Widget _quickActions() {
    final items = [
      (Icons.south_east, 'Deposit', AppColors.success, true, () => _go(const DepositScreen(), requiresAuth: true)),
      (Icons.north_east, 'Withdraw', AppColors.danger, true, () => _go(const WithdrawScreen(), requiresAuth: true)),
      (Icons.credit_card, 'Buy', const Color(0xFF5B8DEF), false, () {
        final s = context.findAncestorStateOfType<_HomeScreenState>();
        s?.setState(() => s._idx = 2);
      }),
      (Icons.trending_up, 'Earn', const Color(0xFFA06AF5), true, () => _go(const EarnScreen(), requiresAuth: true)),
      (Icons.swap_horiz, 'Transfer', const Color(0xFF00C2FF), true, () => _go(const TransferScreen(), requiresAuth: true)),
      (Icons.card_giftcard, 'Refer', const Color(0xFFFF8A3D), true, () => _go(const ReferScreen(), requiresAuth: true)),
      (Icons.account_balance, 'Banks', const Color(0xFFFCD535), true, () => _go(const BanksScreen(), requiresAuth: true)),
      (Icons.grid_view, 'More', AppColors.muted, false, () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const AccountScreen()));
      }),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
        decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(14)),
        child: GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 4,
          mainAxisSpacing: 12,
          childAspectRatio: 1.05,
          children: items.map((it) {
            return InkWell(
              onTap: it.$5,
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Container(
                  width: 42, height: 42,
                  decoration: BoxDecoration(color: it.$3.withValues(alpha: 0.13), shape: BoxShape.circle),
                  alignment: Alignment.center,
                  child: Icon(it.$1, color: it.$3, size: 18),
                ),
                const SizedBox(height: 6),
                Text(it.$2, style: const TextStyle(color: AppColors.fg, fontSize: 11, fontWeight: FontWeight.w500)),
              ]),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ------ BANNER ------
  Widget _bannerStrip() {
    final banners = [
      ('₹100 Welcome Bonus', 'Complete KYC & start trading', const Color(0xFF1652F0), Icons.card_giftcard),
      ('1% TDS Compliant', 'India\'s trusted exchange · safe & secure', const Color(0xFF0ECB81), Icons.shield_outlined),
      ('Earn up to 12% APY', 'Stake USDT, BTC, ETH and more', const Color(0xFFA06AF5), Icons.trending_up),
    ];
    return SizedBox(
      height: 86,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        itemCount: banners.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final b = banners[i];
          return Container(
            width: 280,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: b.$3, borderRadius: BorderRadius.circular(12)),
            child: Row(children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(b.$1, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text(b.$2, style: const TextStyle(color: Colors.white70, fontSize: 11)),
                ]),
              ),
              Container(
                width: 42, height: 42,
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.18), shape: BoxShape.circle),
                alignment: Alignment.center,
                child: Icon(b.$4, size: 22, color: Colors.white),
              ),
            ]),
          );
        },
      ),
    );
  }

  // ------ MARKETS ------
  Widget _marketsSection(int pairCount, List<Map<String, dynamic>> rows) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Markets', style: TextStyle(color: AppColors.fg, fontSize: 15, fontWeight: FontWeight.w800)),
            InkWell(
              onTap: () {
                final s = context.findAncestorStateOfType<_HomeScreenState>();
                s?.setState(() => s._idx = 1);
              },
              child: const Text('View All →', style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w500)),
            ),
          ]),
        ),
        const SizedBox(height: 8),
        // Spot/Futures toggle
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Container(
            height: 36,
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(children: [
              _segBtn(Icons.bar_chart, 'Spot', _kind == _MarketKind.spot, () => setState(() => _kind = _MarketKind.spot)),
              _segBtn(Icons.flash_on, 'Futures', _kind == _MarketKind.futures, () => setState(() => _kind = _MarketKind.futures)),
            ]),
          ),
        ),
        const SizedBox(height: 8),
        // Quote pills + count
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(children: [
            _quotePill('₹ INR', _quote == _QuoteFilter.inr, () => setState(() => _quote = _QuoteFilter.inr)),
            const SizedBox(width: 8),
            _quotePill('\$ USDT', _quote == _QuoteFilter.usdt, () => setState(() => _quote = _QuoteFilter.usdt)),
            const Spacer(),
            Text('$pairCount pairs', style: const TextStyle(color: AppColors.muted, fontSize: 10, fontWeight: FontWeight.w500)),
          ]),
        ),
        const SizedBox(height: 8),
        // Tabs
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Container(
            decoration: const Border(bottom: BorderSide(color: AppColors.border)).toBoxDecoration(),
            child: Row(children: [
              _tabItem('Hot', _MarketTab.hot, Icons.local_fire_department, const Color(0xFFF6465D)),
              _tabItem('Gainers', _MarketTab.gainers, Icons.trending_up, AppColors.success),
              _tabItem('Losers', _MarketTab.losers, Icons.trending_down, AppColors.danger),
              _tabItem('New', _MarketTab.brandNew, Icons.star_outline, const Color(0xFFA06AF5)),
            ]),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: rows.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 28),
                    child: Center(child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2)),
                  )
                : Column(
                    children: List.generate(rows.length, (i) {
                      final c = rows[i];
                      return _PriceRow(
                        rank: i + 1,
                        base: (c['baseCoin'] ?? '').toString(),
                        quote: (c['quoteCoin'] ?? '').toString(),
                        symbol: (c['symbol'] ?? '').toString(),
                        price: c['price'] as double,
                        change: c['change'] as double,
                        volume: c['vol'] as double,
                        isFutures: _kind == _MarketKind.futures,
                        isLast: i == rows.length - 1,
                        onTap: () {
                          final sym = (c['symbol'] ?? '').toString();
                          Navigator.push(context, MaterialPageRoute(builder: (_) => TradeScreen(symbol: sym)));
                        },
                      );
                    }),
                  ),
          ),
        ),
      ]),
    );
  }

  Widget _segBtn(IconData icon, String label, bool active, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          decoration: BoxDecoration(
            color: active ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, size: 12, color: active ? Colors.white : AppColors.muted),
            const SizedBox(width: 5),
            Text(label, style: TextStyle(color: active ? Colors.white : AppColors.muted, fontSize: 12, fontWeight: FontWeight.w800)),
          ]),
        ),
      ),
    );
  }

  Widget _quotePill(String label, bool active, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: active ? AppColors.primary.withValues(alpha: 0.13) : AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: active ? AppColors.primary : AppColors.border),
        ),
        child: Text(label, style: TextStyle(color: active ? AppColors.primary : AppColors.muted, fontSize: 11, fontWeight: FontWeight.w800)),
      ),
    );
  }

  Widget _tabItem(String label, _MarketTab t, IconData icon, Color iconColor) {
    final active = _tab == t;
    return InkWell(
      onTap: () => setState(() => _tab = t),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Stack(alignment: Alignment.bottomCenter, children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(icon, size: 10, color: active ? AppColors.primary : iconColor),
              const SizedBox(width: 4),
              Text(label, style: TextStyle(color: active ? AppColors.primary : AppColors.muted, fontSize: 13, fontWeight: FontWeight.w600)),
            ]),
          ),
          if (active) Container(height: 2, width: 28, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(2))),
        ]),
      ),
    );
  }

  // ------ NEWS ------
  Widget _newsStrip() {
    final news = [
      ('Bitcoin holds above \$76K as ETF inflows continue', 'Reuters · 2h ago'),
      ('RBI clarifies VDA tax: 1% TDS unchanged for FY26', 'ET Markets · 5h ago'),
      ('Solana hits new ATH on rising DeFi volume', 'CoinDesk · 8h ago'),
      ('Ethereum Pectra upgrade goes live on mainnet', 'Bloomberg · 1d ago'),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(2, 0, 0, 8),
          child: Text('Crypto News', style: TextStyle(color: AppColors.fg, fontSize: 15, fontWeight: FontWeight.w800)),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: List.generate(news.length, (i) {
              final n = news[i];
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  border: i == news.length - 1 ? null : const Border(bottom: BorderSide(color: AppColors.border, width: 0.5)),
                ),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(width: 4, height: 4, margin: const EdgeInsets.only(top: 7), decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(n.$1, style: const TextStyle(color: AppColors.fg, fontSize: 12.5, fontWeight: FontWeight.w500, height: 1.35)),
                      const SizedBox(height: 3),
                      Text(n.$2, style: const TextStyle(color: AppColors.muted, fontSize: 10)),
                    ]),
                  ),
                ]),
              );
            }),
          ),
        ),
      ]),
    );
  }

  Widget _promoCard({required IconData icon, required Color iconColor, required String title, required String sub, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.13), shape: BoxShape.circle),
              alignment: Alignment.center,
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: const TextStyle(color: AppColors.fg, fontSize: 13, fontWeight: FontWeight.w800)),
                const SizedBox(height: 3),
                Text(sub, style: const TextStyle(color: AppColors.muted, fontSize: 11)),
              ]),
            ),
            const Icon(Icons.chevron_right, size: 18, color: AppColors.muted),
          ]),
        ),
      ),
    );
  }

  Widget _footer() {
    return Column(children: [
      const Text('ZEBVIX', style: TextStyle(color: AppColors.primary, fontSize: 18, fontWeight: FontWeight.w900)),
      const SizedBox(height: 4),
      const Text('India\'s premier crypto exchange · 1% TDS compliant', style: TextStyle(color: AppColors.muted, fontSize: 11)),
      const SizedBox(height: 10),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        for (final ic in [Icons.alternate_email, Icons.public, Icons.send, Icons.play_circle_outline])
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Container(
              width: 30, height: 30,
              decoration: const BoxDecoration(color: AppColors.card, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: Icon(ic, size: 13, color: AppColors.muted),
            ),
          ),
      ]),
    ]);
  }
}

extension _BorderToBox on Border {
  BoxDecoration toBoxDecoration() => BoxDecoration(border: this);
}

class _PriceRow extends StatefulWidget {
  final int rank;
  final String base, quote, symbol;
  final double price, change, volume;
  final bool isFutures, isLast;
  final VoidCallback onTap;
  const _PriceRow({
    required this.rank,
    required this.base,
    required this.quote,
    required this.symbol,
    required this.price,
    required this.change,
    required this.volume,
    required this.isFutures,
    required this.isLast,
    required this.onTap,
  });
  @override
  State<_PriceRow> createState() => _PriceRowState();
}

class _PriceRowState extends State<_PriceRow> with SingleTickerProviderStateMixin {
  double _prev = 0;
  String? _dir;
  late AnimationController _flash = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));

  @override
  void initState() {
    super.initState();
    _prev = widget.price;
    _flash = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
  }

  @override
  void didUpdateWidget(_PriceRow old) {
    super.didUpdateWidget(old);
    if (widget.price != _prev && _prev > 0) {
      _dir = widget.price > _prev ? 'up' : 'down';
      _flash.forward(from: 1).then((_) => _flash.value = 0);
      _flash.value = 1;
      _flash.animateTo(0, duration: const Duration(milliseconds: 700));
    }
    _prev = widget.price;
  }

  @override
  void dispose() {
    _flash.dispose();
    super.dispose();
  }

  String _fmtPrice() {
    final sym = widget.quote == 'INR' ? '₹' : '\$';
    if (widget.price < 1) return '$sym${widget.price.toStringAsFixed(widget.price < 0.01 ? 6 : 4)}';
    return '$sym${Fmt.num2(widget.price)}';
  }

  @override
  Widget build(BuildContext context) {
    final up = widget.change >= 0;
    final flashColor = _dir == 'up' ? AppColors.success : AppColors.danger;
    final coinColor = _coinColors[widget.base] ?? const Color(0xFF888888);

    return InkWell(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _flash,
        builder: (_, __) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              color: _dir == null ? Colors.transparent : flashColor.withValues(alpha: 0.18 * _flash.value),
              border: widget.isLast ? null : const Border(bottom: BorderSide(color: AppColors.border, width: 0.5)),
            ),
            child: Row(children: [
              Container(
                width: 18, height: 18,
                decoration: const BoxDecoration(color: Color(0xFF1A1F2A), shape: BoxShape.circle),
                alignment: Alignment.center,
                child: Text('${widget.rank}', style: const TextStyle(color: AppColors.muted, fontSize: 10, fontWeight: FontWeight.w800)),
              ),
              const SizedBox(width: 8),
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(color: coinColor.withValues(alpha: 0.18), shape: BoxShape.circle),
                alignment: Alignment.center,
                child: Text(widget.base.isEmpty ? '?' : widget.base[0], style: TextStyle(color: coinColor, fontSize: 13, fontWeight: FontWeight.w800)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Text(widget.base, style: const TextStyle(color: AppColors.fg, fontSize: 13, fontWeight: FontWeight.w600)),
                    Text('/${widget.quote}', style: const TextStyle(color: AppColors.muted, fontSize: 11)),
                    if (widget.isFutures) ...[
                      const SizedBox(width: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(color: const Color(0xFFF3BA2F).withValues(alpha: 0.13), borderRadius: BorderRadius.circular(3)),
                        child: const Text('PERP', style: TextStyle(color: Color(0xFFF3BA2F), fontSize: 8, fontWeight: FontWeight.w800, letterSpacing: 0.4)),
                      ),
                    ],
                  ]),
                  const SizedBox(height: 2),
                  Text('Vol ${Fmt.compact(widget.volume)}', style: const TextStyle(color: AppColors.muted, fontSize: 10)),
                ]),
              ),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(_fmtPrice(), style: TextStyle(color: _dir != null ? Color.lerp(AppColors.fg, flashColor, _flash.value) : AppColors.fg, fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 3),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: (up ? AppColors.success : AppColors.danger).withValues(alpha: 0.13), borderRadius: BorderRadius.circular(4)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(up ? Icons.arrow_upward : Icons.arrow_downward, size: 9, color: up ? AppColors.success : AppColors.danger),
                    const SizedBox(width: 2),
                    Text('${up ? '+' : ''}${widget.change.toStringAsFixed(2)}%', style: TextStyle(color: up ? AppColors.success : AppColors.danger, fontSize: 10, fontWeight: FontWeight.w600)),
                  ]),
                ),
              ]),
            ]),
          );
        },
      ),
    );
  }
}
