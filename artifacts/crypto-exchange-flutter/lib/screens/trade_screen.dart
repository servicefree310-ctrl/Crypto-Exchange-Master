import 'dart:async';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../services/api.dart';
import '../services/state.dart';
import '../utils/format.dart';
import 'login_screen.dart';

class TradeScreen extends StatefulWidget {
  final String symbol;
  const TradeScreen({super.key, required this.symbol});
  @override
  State<TradeScreen> createState() => _TradeScreenState();
}

class _TradeScreenState extends State<TradeScreen> with SingleTickerProviderStateMixin {
  late TabController _sideTab;
  String _orderType = 'limit';
  final _price = TextEditingController();
  final _qty = TextEditingController();
  bool _placing = false;
  String? _msg;

  Map<String, dynamic>? _book;
  List<dynamic> _trades = [];
  List<dynamic> _candles = [];
  bool _loading = true;
  Timer? _timer;

  String get _quote {
    final s = widget.symbol;
    if (s.endsWith('USDT')) return 'USDT';
    if (s.endsWith('INR')) return 'INR';
    if (s.endsWith('USDC')) return 'USDC';
    if (s.endsWith('BTC')) return 'BTC';
    return 'USDT';
  }

  String get _base => widget.symbol.replaceAll(_quote, '');

  String get _pricePrefix => _quote == 'INR' ? '₹' : '';

  @override
  void initState() {
    super.initState();
    _sideTab = TabController(length: 2, vsync: this);
    _loadAll();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) => _loadLive());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _sideTab.dispose();
    super.dispose();
  }

  Future<void> _loadAll() async {
    try {
      final results = await Future.wait([
        Api.orderbook(widget.symbol),
        Api.recentTrades(widget.symbol),
        Api.klines(widget.symbol, interval: '1h', limit: 60),
      ]);
      _book = results[0] is Map ? Map<String, dynamic>.from(results[0] as Map) : null;
      _trades = (results[1] as List);
      _candles = (results[2] as List);
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _loadLive() async {
    try {
      final results = await Future.wait([Api.orderbook(widget.symbol), Api.recentTrades(widget.symbol)]);
      if (!mounted) return;
      setState(() {
        _book = results[0] is Map ? Map<String, dynamic>.from(results[0] as Map) : _book;
        _trades = (results[1] as List);
      });
    } catch (_) {}
  }

  Future<void> _placeOrder(String side) async {
    final auth = context.read<AuthState>();
    if (!auth.isLoggedIn) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
      return;
    }
    setState(() { _placing = true; _msg = null; });
    try {
      await Api.placeOrder({
        'symbol': widget.symbol,
        'side': side,
        'type': _orderType,
        if (_orderType == 'limit') 'price': double.tryParse(_price.text) ?? 0,
        'quantity': double.tryParse(_qty.text) ?? 0,
      });
      setState(() => _msg = 'Order placed');
      _qty.clear();
      _loadLive();
    } catch (e) {
      setState(() => _msg = e.toString().replaceAll('ApiException', '').replaceAll(RegExp(r'\(\d+\):\s*'), ''));
    } finally {
      if (mounted) setState(() => _placing = false);
    }
  }

  double get _lastPrice {
    if (_trades.isNotEmpty) return Fmt.parseNum(_trades.first['price']);
    if (_candles.isNotEmpty) return Fmt.parseNum((_candles.last as List).length > 4 ? (_candles.last as List)[4] : 0);
    return context.read<MarketsState>().priceFor(widget.symbol);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthState>();
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          Text(widget.symbol, style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(width: 10),
          if (_lastPrice > 0)
            Text('$_pricePrefix${Fmt.num2(_lastPrice)}', style: const TextStyle(color: AppColors.success, fontSize: 14, fontWeight: FontWeight.w700)),
        ]),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _loadAll)],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SafeArea(child: Column(children: [
              SizedBox(height: 200, child: _chart()),
              const Divider(height: 1, color: AppColors.border),
              Expanded(child: Row(children: [
                Expanded(flex: 5, child: _orderbook()),
                Container(width: 1, color: AppColors.border),
                Expanded(flex: 4, child: auth.isLoggedIn ? _orderForm() : _loginCta()),
              ])),
            ])),
    );
  }

  Widget _chart() {
    if (_candles.isEmpty) return const Center(child: Text('No chart data', style: TextStyle(color: AppColors.muted)));
    final closes = _candles.map((c) => Fmt.parseNum((c as List)[4])).toList();
    double mn = closes.reduce((a, b) => a < b ? a : b);
    double mx = closes.reduce((a, b) => a > b ? a : b);
    if (mn == mx) { mx = mn * 1.001; mn = mn * 0.999; }
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 12, 12, 8),
      child: LineChart(LineChartData(
        minY: mn, maxY: mx,
        titlesData: const FlTitlesData(show: false),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [LineChartBarData(
          spots: [for (int i = 0; i < closes.length; i++) FlSpot(i.toDouble(), closes[i])],
          isCurved: true, barWidth: 2, color: AppColors.primary,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(show: true, color: AppColors.primary.withValues(alpha: 0.12)),
        )],
      )),
    );
  }

  Widget _orderbook() {
    final asks = (_book?['asks'] as List? ?? []).take(8).toList();
    final bids = (_book?['bids'] as List? ?? []).take(8).toList();
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(2, 2, 2, 6),
          child: Row(children: [
            Expanded(child: Text('Price', style: TextStyle(color: AppColors.muted, fontSize: 10))),
            Expanded(child: Text('Size', textAlign: TextAlign.right, style: TextStyle(color: AppColors.muted, fontSize: 10))),
          ]),
        ),
        ...asks.reversed.map((a) => _bookRow(a, AppColors.danger)),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          alignment: Alignment.center,
          child: Text('$_pricePrefix${Fmt.num2(_lastPrice)}',
              style: const TextStyle(color: AppColors.success, fontSize: 14, fontWeight: FontWeight.w800)),
        ),
        ...bids.map((b) => _bookRow(b, AppColors.success)),
      ]),
    );
  }

  Widget _bookRow(dynamic e, Color c) {
    double price = 0, qty = 0;
    if (e is List && e.length >= 2) { price = Fmt.parseNum(e[0]); qty = Fmt.parseNum(e[1]); }
    else if (e is Map) { price = Fmt.parseNum(e['price']); qty = Fmt.parseNum(e['quantity'] ?? e['size']); }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.5, horizontal: 2),
      child: Row(children: [
        Expanded(child: Text(Fmt.num2(price), style: TextStyle(color: c, fontSize: 11))),
        Expanded(child: Text(Fmt.num2(qty), textAlign: TextAlign.right, style: const TextStyle(color: AppColors.fg, fontSize: 11))),
      ]),
    );
  }

  Widget _orderForm() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        TabBar(
          controller: _sideTab,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.fg,
          unselectedLabelColor: AppColors.muted,
          labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
          tabs: const [Tab(text: 'BUY'), Tab(text: 'SELL')],
        ),
        const SizedBox(height: 8),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(value: 'limit', label: Text('Limit', style: TextStyle(fontSize: 11))),
            ButtonSegment(value: 'market', label: Text('Market', style: TextStyle(fontSize: 11))),
          ],
          selected: {_orderType},
          onSelectionChanged: (s) => setState(() => _orderType = s.first),
          style: ButtonStyle(visualDensity: VisualDensity.compact, padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 4, vertical: 4))),
        ),
        const SizedBox(height: 8),
        if (_orderType == 'limit') TextField(
          controller: _price,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: AppColors.fg, fontSize: 12),
          decoration: InputDecoration(
            isDense: true,
            labelText: 'Price ($_quote)',
            labelStyle: const TextStyle(color: AppColors.muted, fontSize: 11),
            border: const OutlineInputBorder(),
          ),
        ),
        if (_orderType == 'limit') const SizedBox(height: 8),
        TextField(
          controller: _qty,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: AppColors.fg, fontSize: 12),
          decoration: InputDecoration(
            isDense: true,
            labelText: 'Quantity ($_base)',
            labelStyle: const TextStyle(color: AppColors.muted, fontSize: 11),
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        AnimatedBuilder(
          animation: _sideTab,
          builder: (_, __) {
            final isBuy = _sideTab.index == 0;
            return FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: isBuy ? AppColors.success : AppColors.danger,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: _placing ? null : () => _placeOrder(isBuy ? 'buy' : 'sell'),
              child: _placing
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text(isBuy ? 'BUY $_base' : 'SELL $_base', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
            );
          },
        ),
        if (_msg != null) Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(_msg!, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.accent, fontSize: 11)),
        ),
      ]),
    );
  }

  Widget _loginCta() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(width: 48, height: 48, decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.18), borderRadius: BorderRadius.circular(24)),
            child: const Icon(Icons.lock_person, color: AppColors.primary, size: 24)),
        const SizedBox(height: 10),
        const Text('Login to Trade', textAlign: TextAlign.center, style: TextStyle(color: AppColors.fg, fontWeight: FontWeight.w800, fontSize: 13)),
        const SizedBox(height: 12),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
          child: const Text('Login'),
        ),
      ]),
    );
  }
}
