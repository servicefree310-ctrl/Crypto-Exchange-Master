import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:mobile/core/constants/api_constants.dart';
import 'package:mobile/core/theme/global_theme_extensions.dart';

class InstrumentsPage extends StatefulWidget {
  final String category; // 'forex', 'stocks', 'commodities'

  const InstrumentsPage({super.key, required this.category});

  @override
  State<InstrumentsPage> createState() => _InstrumentsPageState();
}

class _InstrumentsPageState extends State<InstrumentsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _instruments = [];
  Map<String, dynamic>? _selected;
  bool _loading = true;
  String? _error;
  Timer? _priceTimer;
  final Random _rng = Random();

  final Map<String, String> _categoryTitles = {
    'forex': 'Forex',
    'stocks': 'Stocks',
    'commodities': 'Commodities',
  };

  final Map<String, IconData> _categoryIcons = {
    'forex': Icons.currency_exchange,
    'stocks': Icons.show_chart,
    'commodities': Icons.diamond,
  };

  final Map<String, Color> _categoryColors = {
    'forex': const Color(0xFF2196F3),
    'stocks': const Color(0xFF4CAF50),
    'commodities': const Color(0xFFFFB300),
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadInstruments();
    _priceTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (mounted && _instruments.isNotEmpty) {
        setState(() {
          for (final inst in _instruments) {
            final drift = (_rng.nextDouble() - 0.49) * 0.001;
            final price = (inst['currentPrice'] as double? ?? 0.0);
            inst['currentPrice'] = price * (1 + drift);
            inst['changePercent'] =
                (inst['changePercent'] as double? ?? 0.0) + drift * 100;
          }
          if (_selected != null) {
            final updated = _instruments.firstWhere(
              (i) => i['symbol'] == _selected!['symbol'],
              orElse: () => _selected!,
            );
            _selected = updated;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _priceTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadInstruments() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final baseUrl = ApiConstants.baseUrl;
      final uri = Uri.parse('$baseUrl/api/instruments?category=${widget.category}');
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 8);
      final request = await client.getUrl(uri);
      request.headers.set('Accept', 'application/json');
      final response = await request.close().timeout(const Duration(seconds: 8));
      final body = await response.transform(utf8.decoder).join();
      client.close();
      if (response.statusCode == 200) {
        final data = jsonDecode(body) as Map<String, dynamic>;
        final list = (data['instruments'] as List? ?? [])
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
        setState(() {
          _instruments = list;
          _selected = list.isNotEmpty ? list.first : null;
          _loading = false;
        });
      } else {
        setState(() {
          _error = 'Server error ${response.statusCode}';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  String _fmtPrice(dynamic val) {
    if (val == null) return '--';
    final d = (val as num).toDouble();
    if (d >= 10000) return d.toStringAsFixed(0);
    if (d >= 100) return d.toStringAsFixed(2);
    if (d >= 1) return d.toStringAsFixed(4);
    return d.toStringAsFixed(6);
  }

  @override
  Widget build(BuildContext context) {
    final catColor =
        _categoryColors[widget.category] ?? context.colors.primary;
    final catTitle = _categoryTitles[widget.category] ?? widget.category;
    final catIcon =
        _categoryIcons[widget.category] ?? Icons.bar_chart;

    return Scaffold(
      backgroundColor: context.background,
      appBar: AppBar(
        backgroundColor: context.cardBackground,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: catColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(catIcon, color: catColor, size: 18),
            ),
            const SizedBox(width: 8),
            Text(
              catTitle,
              style: context.h5.copyWith(
                color: context.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: catColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'CFD',
                style: TextStyle(
                  color: catColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                const Icon(Icons.circle,
                    color: Color(0xFF4CAF50), size: 6),
                const SizedBox(width: 4),
                Text(
                  'Simulated',
                  style: TextStyle(
                    color: const Color(0xFF4CAF50),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: _loading
          ? Center(
              child: CircularProgressIndicator(color: catColor),
            )
          : _error != null
              ? _buildError()
              : Row(
                  children: [
                    // Left list panel
                    SizedBox(
                      width: 160,
                      child: Container(
                        color: context.cardBackground,
                        child: ListView.builder(
                          itemCount: _instruments.length,
                          itemBuilder: (ctx, i) {
                            final inst = _instruments[i];
                            final isSelected =
                                _selected?['symbol'] == inst['symbol'];
                            final chg = (inst['changePercent'] as num?)
                                    ?.toDouble() ??
                                0.0;
                            final chgColor = chg >= 0
                                ? context.priceUpColor
                                : context.priceDownColor;
                            return GestureDetector(
                              onTap: () =>
                                  setState(() => _selected = inst),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 10),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? catColor.withValues(alpha: 0.1)
                                      : Colors.transparent,
                                  border: Border(
                                    left: BorderSide(
                                      color: isSelected
                                          ? catColor
                                          : Colors.transparent,
                                      width: 3,
                                    ),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      inst['symbol'] as String? ?? '',
                                      style: context.labelM.copyWith(
                                        color: isSelected
                                            ? catColor
                                            : context.textPrimary,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _fmtPrice(inst['currentPrice']),
                                      style: context.bodyS.copyWith(
                                        color: context.textPrimary,
                                        fontSize: 11,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${chg >= 0 ? '+' : ''}${chg.toStringAsFixed(3)}%',
                                      style: TextStyle(
                                        color: chgColor,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    // Right detail panel
                    Expanded(
                      child: _selected == null
                          ? Center(
                              child: Text('Select an instrument',
                                  style: context.bodyM.copyWith(
                                      color: context.textSecondary)))
                          : _buildDetail(catColor),
                    ),
                  ],
                ),
    );
  }

  Widget _buildDetail(Color catColor) {
    final inst = _selected!;
    final chg = (inst['changePercent'] as num?)?.toDouble() ?? 0.0;
    final chgColor =
        chg >= 0 ? context.priceUpColor : context.priceDownColor;
    final price = _fmtPrice(inst['currentPrice']);

    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: context.cardBackground,
            border: Border(
              bottom: BorderSide(color: context.dividerColor),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          inst['symbol'] as String? ?? '',
                          style: context.h5.copyWith(
                            color: context.textPrimary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: catColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            inst['exchange'] as String? ?? '',
                            style: TextStyle(
                                color: catColor,
                                fontSize: 9,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      inst['name'] as String? ?? '',
                      style: context.bodyS.copyWith(
                          color: context.textSecondary, fontSize: 11),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    price,
                    style: context.h5.copyWith(
                      color: chgColor,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    '${chg >= 0 ? '+' : ''}${chg.toStringAsFixed(3)}%',
                    style: TextStyle(
                        color: chgColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Tabs
        Container(
          color: context.cardBackground,
          child: TabBar(
            controller: _tabController,
            indicatorColor: catColor,
            labelColor: catColor,
            unselectedLabelColor: context.textSecondary,
            labelStyle: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.w600),
            tabs: const [
              Tab(text: 'Details'),
              Tab(text: 'Place Order'),
            ],
          ),
        ),

        // Tab content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildDetailsTab(inst, catColor),
              _buildOrderTab(inst, catColor, chgColor, price),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsTab(
      Map<String, dynamic> inst, Color catColor) {
    final items = [
      ['Exchange', inst['exchange'] ?? '--'],
      ['Lot Size', inst['lotSize']?.toString() ?? '--'],
      ['Min Qty', inst['minQty']?.toString() ?? '--'],
      ['Max Leverage', '${inst['maxLeverage'] ?? '--'}x'],
      ['Taker Fee', '${((inst['takerFee'] as num?)?.toDouble() ?? 0) * 100}%'],
      ['Margin Req.', '${((inst['marginReq'] as num?)?.toDouble() ?? 0) * 100}%'],
      ['Quote Currency', inst['quoteCurrency'] ?? '--'],
      ['Category', inst['category'] ?? '--'],
    ];

    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        // Simulated chart placeholder
        Container(
          height: 160,
          decoration: BoxDecoration(
            color: context.cardBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.dividerColor),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.bar_chart,
                  size: 40, color: catColor.withValues(alpha: 0.5)),
              const SizedBox(height: 8),
              Text('Live Chart',
                  style: context.bodyM
                      .copyWith(color: context.textSecondary)),
              Text('Connect Angel One API for live data',
                  style: context.bodyS.copyWith(
                      color: context.textTertiary, fontSize: 11)),
            ],
          ),
        ),
        const SizedBox(height: 14),
        // Details grid
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 2.8,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          children: items.map((item) {
            return Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: context.cardBackground,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: context.dividerColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(item[0],
                      style: context.bodyS.copyWith(
                          color: context.textTertiary,
                          fontSize: 10)),
                  Text(item[1],
                      style: context.labelM.copyWith(
                          color: context.textPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildOrderTab(Map<String, dynamic> inst, Color catColor,
      Color chgColor, String price) {
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        // Price summary
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: catColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: catColor.withValues(alpha: 0.2)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(inst['symbol'] as String? ?? '',
                      style: context.labelM.copyWith(
                          color: catColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 13)),
                  Text(inst['name'] as String? ?? '',
                      style: context.bodyS.copyWith(
                          color: context.textSecondary, fontSize: 11)),
                ],
              ),
              Text(price,
                  style: context.h5.copyWith(
                      color: chgColor, fontWeight: FontWeight.w800)),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Buy / Sell buttons
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => _showLoginPrompt(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Buy / Long',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: () => _showLoginPrompt(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF44336),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Sell / Short',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Info card
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: context.cardBackground,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: context.dividerColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.info_outline,
                      size: 14, color: context.textSecondary),
                  const SizedBox(width: 6),
                  Text('Instrument Info',
                      style: context.labelM.copyWith(
                          color: context.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 12)),
                ],
              ),
              const SizedBox(height: 8),
              _infoRow('Lot Size',
                  inst['lotSize']?.toString() ?? '--'),
              _infoRow('Min Qty',
                  inst['minQty']?.toString() ?? '--'),
              _infoRow('Max Leverage',
                  '${inst['maxLeverage'] ?? '--'}x'),
              _infoRow('Margin Req.',
                  '${((inst['marginReq'] as num?)?.toDouble() ?? 0) * 100}%'),
              _infoRow('Taker Fee',
                  '${((inst['takerFee'] as num?)?.toDouble() ?? 0) * 100}%'),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Disclaimer
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: context.warningColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
                color: context.warningColor.withValues(alpha: 0.25)),
          ),
          child: Text(
            'Currently in simulation mode. Login to trade. Connect Angel One credentials in Admin settings for live execution.',
            style: context.bodyS.copyWith(
                color: context.textSecondary, fontSize: 10),
          ),
        ),
      ],
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: context.bodyS.copyWith(
                  color: context.textSecondary, fontSize: 11)),
          Text(value,
              style: context.labelM.copyWith(
                  color: context.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline,
              size: 48, color: context.priceDownColor),
          const SizedBox(height: 12),
          Text('Failed to load instruments',
              style: context.bodyM.copyWith(color: context.textSecondary)),
          const SizedBox(height: 8),
          Text(_error ?? '',
              style: context.bodyS.copyWith(
                  color: context.textTertiary, fontSize: 11),
              textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadInstruments,
            style: ElevatedButton.styleFrom(
                backgroundColor: context.colors.primary),
            child: const Text('Retry',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showLoginPrompt() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Please login to place orders'),
        backgroundColor: context.warningColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
