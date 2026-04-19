import 'package:flutter/material.dart';

import '../../../../core/theme/global_theme_extensions.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../../injection/injection.dart';
import '../../domain/entities/futures_market_entity.dart';
import '../../domain/usecases/get_futures_markets_usecase.dart';
import '../../../../core/usecases/usecase.dart';

class FuturesPairSideMenu extends StatefulWidget {
  const FuturesPairSideMenu({
    super.key,
    required this.onPairSelected,
    this.currentSymbol,
  });

  final Function(String symbol) onPairSelected;
  final String? currentSymbol;

  @override
  State<FuturesPairSideMenu> createState() => _FuturesPairSideMenuState();
}

class _FuturesPairSideMenuState extends State<FuturesPairSideMenu>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _slideAnim;

  final TextEditingController _searchCtrl = TextEditingController();
  List<FuturesMarketEntity> _markets = [];
  bool _loading = true;
  String? _error;

  // Static cache for markets data across all instances
  static List<FuturesMarketEntity>? _cachedMarkets;
  static DateTime? _cacheTime;
  static const _cacheValidityDuration =
      Duration(minutes: 5); // Cache for 5 minutes

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _slideAnim = Tween<double>(begin: -1, end: 0).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOut,
    ));
    _animController.forward();
    _loadMarkets();
    _searchCtrl.addListener(() => setState(() {}));
  }

  Future<void> _loadMarkets({bool forceRefresh = false}) async {
    // Check if we have valid cached data
    if (!forceRefresh &&
        _cachedMarkets != null &&
        _cacheTime != null &&
        DateTime.now().difference(_cacheTime!) < _cacheValidityDuration) {
      setState(() {
        _markets = _cachedMarkets!;
        _loading = false;
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    final usecase = getIt<GetFuturesMarketsUseCase>();
    final result = await usecase(const NoParams());
    result.fold((failure) {
      setState(() {
        _loading = false;
        _error = failure.message;
      });
    }, (data) {
      // Update cache
      _cachedMarkets = data;
      _cacheTime = DateTime.now();

      setState(() {
        _loading = false;
        _markets = data;
      });
    });
  }

  List<FuturesMarketEntity> get _filtered {
    final q = _searchCtrl.text.toLowerCase();
    if (q.isEmpty) return _markets;
    return _markets.where((m) => m.symbol.toLowerCase().contains(q)).toList();
  }

  void _onSelect(String symbol) {
    _animController.reverse().then((_) => widget.onPairSelected(symbol));
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width * 0.85;
    return AnimatedBuilder(
      animation: _slideAnim,
      builder: (context, child) {
        return Material(
          color: Colors.transparent,
          child: Transform.translate(
            offset: Offset(_slideAnim.value * w, 0),
            child: Container(
              width: w,
              height: double.infinity,
              decoration: BoxDecoration(
                color: context.theme.scaffoldBackgroundColor,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: const Offset(2, 0),
                  ),
                ],
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                      child: Row(
                        children: [
                          Text(
                            'Futures Pairs',
                            style: TextStyle(
                              color: context.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () => _animController
                                .reverse()
                                .then((_) => Navigator.pop(context)),
                            child:
                                Icon(Icons.close, color: context.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        controller: _searchCtrl,
                        decoration: InputDecoration(
                          hintText: 'Search',
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: context.inputBackground,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: context.borderColor),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 0, horizontal: 8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(child: _buildContent(context)),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context) {
    if (_loading) {
      return ShimmerList(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 10,
        itemBuilder: (context, index) => Container(
          height: 56,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ShimmerLoading(
            child: Row(
              children: [
                Container(
                  width: 100,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const Spacer(),
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Failed: $_error',
                style: TextStyle(color: context.textSecondary)),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _loadMarkets(forceRefresh: true),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    final list = _filtered;
    if (list.isEmpty) {
      return Center(
        child: Text('No pairs', style: TextStyle(color: context.textSecondary)),
      );
    }
    return RefreshIndicator(
      onRefresh: () => _loadMarkets(forceRefresh: true),
      child: ListView.separated(
        itemCount: list.length,
        separatorBuilder: (_, __) =>
            Divider(height: 0.5, color: context.borderColor),
        itemBuilder: (context, i) {
          final m = list[i];
          final selected = m.symbol == widget.currentSymbol;
          return ListTile(
            title: Text(m.symbol, style: TextStyle(color: context.textPrimary)),
            trailing: selected
                ? Icon(Icons.check, color: context.priceUpColor)
                : null,
            onTap: () => _onSelect(m.symbol),
          );
        },
      ),
    );
  }
}
