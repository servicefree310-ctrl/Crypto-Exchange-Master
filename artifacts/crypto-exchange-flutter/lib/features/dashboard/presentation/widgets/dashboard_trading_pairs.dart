import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/global_theme_extensions.dart';
import '../../../../core/widgets/animated_price.dart';
import '../../../market/domain/entities/market_data_entity.dart';
import '../../../chart/presentation/pages/chart_page.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_state.dart';

class DashboardTradingPairs extends StatefulWidget {
  const DashboardTradingPairs({super.key});

  @override
  State<DashboardTradingPairs> createState() => _DashboardTradingPairsState();
}

class _DashboardTradingPairsState extends State<DashboardTradingPairs>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<double> _slideAnimation;

  int _selectedTabIndex = 0;
  final List<String> _tabs = ['Gainers', 'Losers', 'Volume'];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        if (state is DashboardLoaded) {
          return _buildTradingPairsContent(context, state);
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildTradingPairsContent(
      BuildContext context, DashboardLoaded state) {
    return Container(
      padding: EdgeInsets.all(context.isSmallScreen ? 16.0 : 20.0),
      decoration: BoxDecoration(
        color: context.cardBackground,
        borderRadius:
            BorderRadius.circular(context.isSmallScreen ? 14.0 : 16.0),
        border: Border.all(
          color: context.borderColor,
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with title and tabs
          _buildHeader(context),
          SizedBox(height: context.isSmallScreen ? 16.0 : 20.0),

          // Tab content
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _buildTabContent(context, state),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: context.inputBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.borderColor.withValues(alpha: 0.3)),
      ),
      child: Stack(
        children: [
          // Animated selection indicator
          AnimatedPositioned(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            left: _selectedTabIndex *
                (MediaQuery.of(context).size.width - 64) /
                3,
            top: 2,
            child: Container(
              width: (MediaQuery.of(context).size.width - 64) / 3,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.grey,
                  width: 1.5,
                ),
              ),
            ),
          ),
          // Tab buttons
          Row(
            children: _tabs.asMap().entries.map((entry) {
              final index = entry.key;
              final tab = entry.value;
              final isSelected = index == _selectedTabIndex;

              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedTabIndex = index;
                    });
                    _slideController.forward(from: 0.0);
                  },
                  child: SizedBox(
                    height: 36,
                    child: Center(
                      child: Text(
                        tab,
                        style: context.bodyS.copyWith(
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w500,
                          color:
                              isSelected ? Colors.grey : context.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent(BuildContext context, DashboardLoaded state) {
    switch (_selectedTabIndex) {
      case 0:
        return _buildGainersTab(context, state);
      case 1:
        return _buildLosersTab(context, state);
      case 2:
        return _buildVolumeTab(context, state);
      default:
        return _buildGainersTab(context, state);
    }
  }

  Widget _buildGainersTab(BuildContext context, DashboardLoaded state) {
    return _buildMarketList(context, state.topGainers, 'Top Gainers', '🚀');
  }

  Widget _buildLosersTab(BuildContext context, DashboardLoaded state) {
    return _buildMarketList(context, state.topLosers, 'Top Losers', '📉');
  }

  Widget _buildVolumeTab(BuildContext context, DashboardLoaded state) {
    return _buildMarketList(
        context, state.highVolumeMarkets, 'High Volume', '💎');
  }

  Widget _buildMarketList(BuildContext context, List<MarketDataEntity> markets,
      String title, String icon) {
    if (markets.isEmpty) {
      return _buildEmptyState(context, title, icon);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...markets
            .map((market) => _buildMarketListItem(context, market))
            ,
        SizedBox(height: context.isSmallScreen ? 8.0 : 12.0),
        Center(
          child: TextButton(
            onPressed: () => _navigateToMarketTab(context),
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(
                horizontal: context.isSmallScreen ? 12.0 : 16.0,
                vertical: 4.0,
              ),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'View More',
              style: context.bodyS.copyWith(
                color: context.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMarketListItem(BuildContext context, MarketDataEntity market) {
    return GestureDetector(
      onTap: () => _navigateToChartPage(context, market),
      child: Container(
        margin: EdgeInsets.only(bottom: context.isSmallScreen ? 8.0 : 12.0),
        padding: EdgeInsets.all(context.isSmallScreen ? 12.0 : 16.0),
        decoration: BoxDecoration(
          color: context.inputBackground,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: context.borderColor.withValues(alpha: 0.3),
            width: 1.0,
          ),
        ),
        child: Row(
          children: [
            // Crypto icon
            Container(
              width: context.isSmallScreen ? 32.0 : 36.0,
              height: context.isSmallScreen ? 32.0 : 36.0,
              decoration: BoxDecoration(
                color: context.colors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(
                  color: context.colors.primary.withValues(alpha: 0.2),
                  width: 1.0,
                ),
              ),
              child: Center(
                child: Text(
                  market.symbol.split('/')[0].substring(0, 1),
                  style: context.labelM.copyWith(
                    fontSize: context.isSmallScreen ? 12.0 : 14.0,
                    fontWeight: FontWeight.w600,
                    color: context.colors.primary,
                  ),
                ),
              ),
            ),
            SizedBox(width: context.isSmallScreen ? 12.0 : 16.0),

            // Market info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    market.symbol,
                    style: context.cryptoSymbol().copyWith(
                          fontSize: context.isSmallScreen ? 13.0 : 14.0,
                          fontWeight: FontWeight.w600,
                          color: context.textPrimary,
                        ),
                  ),
                  SizedBox(height: 2.0),
                  Text(
                    'Vol: ${_formatVolume(market.baseVolume)}',
                    style: context.bodyS.copyWith(
                      color: context.textSecondary,
                      fontSize: context.isSmallScreen ? 11.0 : 12.0,
                    ),
                  ),
                ],
              ),
            ),

            // Price and change
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                AnimatedPrice(
                  symbol: market.symbol,
                  price: market.price,
                  style: context.priceMedium().copyWith(
                        fontSize: context.isSmallScreen ? 13.0 : 14.0,
                        fontWeight: FontWeight.w600,
                        color: context.textPrimary,
                      ),
                  decimalPlaces: _getOptimalDecimalPlaces(market.price),
                ),
                SizedBox(height: 4.0),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.isSmallScreen ? 6.0 : 8.0,
                    vertical: 2.0,
                  ),
                  decoration: BoxDecoration(
                    color: market.isPositive
                        ? context.priceUpColor.withValues(alpha: 0.1)
                        : context.priceDownColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6.0),
                    border: Border.all(
                      color: market.isPositive
                          ? context.priceUpColor.withValues(alpha: 0.2)
                          : context.priceDownColor.withValues(alpha: 0.2),
                      width: 1.0,
                    ),
                  ),
                  child: AnimatedPercentage(
                    symbol: market.symbol,
                    percentage: market.changePercent,
                    style: context.bodyS.copyWith(
                      fontSize: context.isSmallScreen ? 10.0 : 11.0,
                      fontWeight: FontWeight.w600,
                      color: market.isPositive
                          ? context.priceUpColor
                          : context.priceDownColor,
                    ),
                    showSign: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String title, String icon) {
    return Container(
      padding: EdgeInsets.all(context.isSmallScreen ? 24.0 : 32.0),
      child: Column(
        children: [
          Text(icon,
              style: TextStyle(fontSize: context.isSmallScreen ? 32.0 : 40.0)),
          SizedBox(height: context.isSmallScreen ? 12.0 : 16.0),
          Text(
            'No $title Available',
            style: context.h6.copyWith(
              color: context.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: context.isSmallScreen ? 6.0 : 8.0),
          Text(
            'Check back later for updated market data',
            style: context.bodyS.copyWith(
              color: context.textTertiary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _formatVolume(double volume) {
    if (volume >= 1e12) {
      return '${(volume / 1e12).toStringAsFixed(1)}T';
    } else if (volume >= 1e9) {
      return '${(volume / 1e9).toStringAsFixed(1)}B';
    } else if (volume >= 1e6) {
      return '${(volume / 1e6).toStringAsFixed(1)}M';
    } else if (volume >= 1e3) {
      return '${(volume / 1e3).toStringAsFixed(1)}K';
    } else {
      return volume.toStringAsFixed(0);
    }
  }

  /// Navigate to market tab in HomePage
  void _navigateToMarketTab(BuildContext context) {
    HomePage.navigateToTab(context, 'market');
  }

  /// Navigate to chart page for specific market
  void _navigateToChartPage(BuildContext context, MarketDataEntity market) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChartPage(
          symbol: market.symbol,
          marketData: market,
        ),
      ),
    );
  }

  /// Get optimal decimal places for price display
  int _getOptimalDecimalPlaces(double price) {
    if (price >= 1000) return 2;
    if (price >= 1) return 4;
    if (price >= 0.01) return 6;
    return 8;
  }
}
