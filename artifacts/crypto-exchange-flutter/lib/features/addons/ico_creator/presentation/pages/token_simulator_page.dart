import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;
import 'dart:ui';

class TokenSimulatorPage extends StatefulWidget {
  const TokenSimulatorPage({super.key});

  @override
  State<TokenSimulatorPage> createState() => _TokenSimulatorPageState();
}

class _TokenSimulatorPageState extends State<TokenSimulatorPage>
    with TickerProviderStateMixin {
  // Controllers
  final _totalSupplyCtrl = TextEditingController(text: '1000000000');
  final _priceCtrl = TextEditingController(text: '0.001');

  // Animation
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Current View
  int _currentView = 0;

  // Allocations - More compact structure
  final List<TokenAllocation> _allocations = [
    TokenAllocation(
        'Public Sale', 30, const Color(0xFF06B6D4), Icons.public, 0, 0, 100),
    TokenAllocation(
        'Team', 20, const Color(0xFF3B82F6), Icons.groups, 48, 12, 0),
    TokenAllocation(
        'Ecosystem', 20, const Color(0xFF10B981), Icons.eco, 36, 0, 10),
    TokenAllocation(
        'Private Sale', 15, const Color(0xFF8B5CF6), Icons.lock, 18, 3, 15),
    TokenAllocation(
        'Marketing', 10, const Color(0xFFF59E0B), Icons.campaign, 24, 0, 20),
    TokenAllocation(
        'Reserve', 5, const Color(0xFF64748B), Icons.savings, 36, 12, 0),
  ];

  // Metrics
  double _circulatingSupply = 0;
  int _selectedMonth = 0;
  final List<double> _priceHistory = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
    _calculateMetrics();
    _generatePriceSimulation();
  }

  @override
  void dispose() {
    _totalSupplyCtrl.dispose();
    _priceCtrl.dispose();
    _animationController.dispose();
    super.dispose();
  }

  double get _totalSupply => double.tryParse(_totalSupplyCtrl.text) ?? 0;
  double get _price => double.tryParse(_priceCtrl.text) ?? 0;
  double get _totalPercent =>
      _allocations.fold(0, (sum, a) => sum + a.percentage);

  void _calculateMetrics() {
    setState(() {
      _circulatingSupply = _calculateCirculating(_selectedMonth);
    });
  }

  double _calculateCirculating(int months) {
    double total = 0;
    for (var alloc in _allocations) {
      double amount = (_totalSupply * alloc.percentage) / 100;
      total += _calculateUnlocked(amount, months, alloc);
    }
    return total;
  }

  double _calculateUnlocked(double amount, int months, TokenAllocation alloc) {
    if (alloc.vesting == 0) return amount;

    double tge = (amount * alloc.tgeUnlock) / 100;
    if (months < alloc.cliff) return tge;

    double remaining = amount - tge;
    int vestPeriod = alloc.vesting - alloc.cliff;
    int monthsVested = months - alloc.cliff;

    if (monthsVested >= vestPeriod) return amount;

    return tge + (remaining * monthsVested / vestPeriod);
  }

  void _generatePriceSimulation() {
    _priceHistory.clear();
    double p = _price;
    final r = math.Random();

    for (int i = 0; i <= 60; i++) {
      double change = (r.nextDouble() - 0.5) * 0.2;
      p *= (1 + change);
      p = math.max(p, _price * 0.1);
      _priceHistory.add(p);
    }
  }

  String _formatNumber(double n) {
    if (n >= 1e9) return '${(n / 1e9).toStringAsFixed(1)}B';
    if (n >= 1e6) return '${(n / 1e6).toStringAsFixed(1)}M';
    if (n >= 1e3) return '${(n / 1e3).toStringAsFixed(1)}K';
    return n.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0A0E27),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF6366F1),
          secondary: Color(0xFF06B6D4),
        ),
      ),
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: _buildCurrentView(),
                ),
              ),
              _buildBottomNav(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (Navigator.canPop(context))
            IconButton(
              icon: const Icon(Icons.arrow_back_ios, size: 20),
              onPressed: () => Navigator.pop(context),
              color: Colors.white70,
            )
          else
            const SizedBox(width: 48),
          Expanded(
            child: Column(
              children: [
                const Text(
                  'Token Simulator',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Supply: ${_formatNumber(_totalSupply)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings, size: 20),
            onPressed: _showSettings,
            color: Colors.white70,
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentView() {
    switch (_currentView) {
      case 0:
        return _buildAllocationView();
      case 1:
        return _buildVestingView();
      case 2:
        return _buildAnalyticsView();
      default:
        return _buildAllocationView();
    }
  }

  Widget _buildAllocationView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildCompactMetrics(),
          const SizedBox(height: 16),
          _buildPieChart(),
          const SizedBox(height: 16),
          _buildAllocationList(),
          if (_totalPercent != 100)
            Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
              ),
              child: Text(
                'Total must equal 100% (current: ${_totalPercent.toStringAsFixed(0)}%)',
                style: const TextStyle(color: Colors.red, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCompactMetrics() {
    final mc = _circulatingSupply * _price;
    final fdv = _totalSupply * _price;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF6366F1).withValues(alpha: 0.15),
            const Color(0xFF06B6D4).withValues(alpha: 0.10),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
                child: _buildMetricItem('Price',
                    '\$${_price.toStringAsFixed(3)}', const Color(0xFF10B981))),
            VerticalDivider(color: Colors.white12, width: 1),
            Expanded(
                child: _buildMetricItem('Market Cap', '\$${_formatNumber(mc)}',
                    const Color(0xFF6366F1))),
            VerticalDivider(color: Colors.white12, width: 1),
            Expanded(
                child: _buildMetricItem(
                    'FDV', '\$${_formatNumber(fdv)}', const Color(0xFF06B6D4))),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricItem(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 11,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final chartSize = math.min(availableWidth - 32, 180.0);

        return Container(
          height: chartSize + 48,
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  sectionsSpace: 3,
                  centerSpaceRadius: chartSize * 0.28,
                  sections: _getSections(chartSize),
                  pieTouchData: PieTouchData(
                    touchCallback: (event, response) {
                      // Handle touch events
                    },
                  ),
                ),
              ),
              _buildCenterContent(chartSize),
            ],
          ),
        );
      },
    );
  }

  List<PieChartSectionData> _getSections(double chartSize) {
    final List<Map<String, dynamic>> sections = [
      {
        'title': 'Team',
        'value': _allocations[1].percentage,
        'colors': [
          const Color(0xFF6366F1), // Indigo
          const Color(0xFF818CF8), // Lighter Indigo
        ],
      },
      {
        'title': 'Advisors',
        'value': _allocations[2].percentage,
        'colors': [
          const Color(0xFF06B6D4), // Cyan
          const Color(0xFF22D3EE), // Lighter Cyan
        ],
      },
      {
        'title': 'Marketing',
        'value': _allocations[4].percentage,
        'colors': [
          const Color(0xFFF59E0B), // Amber
          const Color(0xFFFBBF24), // Lighter Amber
        ],
      },
      {
        'title': 'Development',
        'value': _allocations[3].percentage,
        'colors': [
          const Color(0xFF10B981), // Emerald
          const Color(0xFF34D399), // Lighter Emerald
        ],
      },
      {
        'title': 'Treasury',
        'value': _allocations[5].percentage,
        'colors': [
          const Color(0xFFEC4899), // Pink
          const Color(0xFFF472B6), // Lighter Pink
        ],
      },
      {
        'title': 'Public',
        'value': _allocations[0].percentage,
        'colors': [
          const Color(0xFF8B5CF6), // Purple
          const Color(0xFFA78BFA), // Lighter Purple
        ],
      },
    ];

    return sections.asMap().entries.map((entry) {
      final data = entry.value;
      final value = data['value'] as double;
      final colors = data['colors'] as List<Color>;

      if (value <= 0) {
        return PieChartSectionData(value: 0, color: Colors.transparent);
      }

      return PieChartSectionData(
        value: value,
        title: '${value.toStringAsFixed(1)}%',
        titleStyle: TextStyle(
          color: Colors.white.withValues(alpha: 0.9),
          fontSize: 12,
          fontWeight: FontWeight.w600,
          shadows: [
            Shadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 3,
            ),
          ],
        ),
        radius: chartSize * 0.32,
        badgeWidget: _buildSectionBadge(data['title'], colors[0]),
        badgePositionPercentageOffset: 0.8,
        color: colors[0],
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors[0],
            colors[1],
          ],
          stops: const [0.2, 0.8],
        ),
        borderSide: BorderSide(
          color: Colors.white.withValues(alpha: 0.15),
          width: 1,
        ),
      );
    }).toList();
  }

  Widget _buildSectionBadge(String title, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.9),
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildCenterContent(double chartSize) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: chartSize * 0.52,
          height: chartSize * 0.52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.05),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
              width: 1,
            ),
            gradient: RadialGradient(
              colors: [
                Colors.white.withValues(alpha: 0.1),
                Colors.white.withValues(alpha: 0.05),
                Colors.transparent,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${_totalPercent.toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: chartSize * 0.14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Total',
                    style: TextStyle(
                      fontSize: chartSize * 0.06,
                      color: Colors.white.withValues(alpha: 0.7),
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAllocationList() {
    return Column(
      children: _allocations.map((alloc) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: alloc.color.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: alloc.color.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(alloc.icon, color: alloc.color, size: 16),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            alloc.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${_formatNumber((_totalSupply * alloc.percentage) / 100)} tokens',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.5),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${alloc.percentage}%',
                      style: TextStyle(
                        color: alloc.color,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              SliderTheme(
                data: SliderThemeData(
                  activeTrackColor: alloc.color,
                  inactiveTrackColor: alloc.color.withValues(alpha: 0.2),
                  thumbColor: alloc.color,
                  overlayColor: alloc.color.withValues(alpha: 0.1),
                  trackHeight: 4,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 6,
                  ),
                ),
                child: Slider(
                  value: alloc.percentage,
                  min: 0,
                  max: 100,
                  onChanged: (value) {
                    setState(() {
                      alloc.percentage = value;
                      _calculateMetrics();
                    });
                  },
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildVestingView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildMonthSelector(),
          const SizedBox(height: 16),
          _buildVestingChart(),
          const SizedBox(height: 16),
          _buildVestingDetails(),
        ],
      ),
    );
  }

  Widget _buildMonthSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Timeline',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.4),
                  ),
                ),
                child: Text(
                  'Month $_selectedMonth',
                  style: const TextStyle(
                    color: Color(0xFF6366F1),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: const Color(0xFF6366F1),
              inactiveTrackColor: Colors.white.withValues(alpha: 0.1),
              thumbColor: const Color(0xFF6366F1),
              overlayColor: const Color(0xFF6366F1).withValues(alpha: 0.1),
              trackHeight: 6,
              thumbShape: const RoundSliderThumbShape(
                enabledThumbRadius: 10,
              ),
            ),
            child: Slider(
              value: _selectedMonth.toDouble(),
              min: 0,
              max: 60,
              divisions: 60,
              onChanged: (value) {
                setState(() {
                  _selectedMonth = value.toInt();
                  _calculateMetrics();
                });
              },
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTimeLabel('TGE', 0),
              _buildTimeLabel('1Y', 12),
              _buildTimeLabel('2Y', 24),
              _buildTimeLabel('3Y', 36),
              _buildTimeLabel('4Y', 48),
              _buildTimeLabel('5Y', 60),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeLabel(String label, int month) {
    final isActive = _selectedMonth == month;
    return GestureDetector(
      onTap: () => setState(() {
        _selectedMonth = month;
        _calculateMetrics();
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFF6366F1).withValues(alpha: 0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive
                ? const Color(0xFF6366F1)
                : Colors.white.withValues(alpha: 0.4),
            fontSize: 11,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildVestingChart() {
    return Container(
      height: 240,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background gradient
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF6366F1).withValues(alpha: 0.05),
                    const Color(0xFF06B6D4).withValues(alpha: 0.02),
                  ],
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Vesting Schedule',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Row(
                    children: _allocations
                        .where((a) => a.vesting > 0)
                        .map((alloc) => Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: alloc.color.withValues(alpha: 0.2),
                                  border: Border.all(color: alloc.color),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Center(
                                  child: Icon(
                                    alloc.icon,
                                    size: 8,
                                    color: alloc.color,
                                  ),
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: true,
                      horizontalInterval: 20,
                      verticalInterval: 12, // Every year
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: Colors.white.withValues(alpha: 0.05),
                          strokeWidth: 1,
                        );
                      },
                      getDrawingVerticalLine: (value) {
                        return FlLine(
                          color: Colors.white.withValues(alpha: 0.03),
                          strokeWidth: 1,
                        );
                      },
                    ),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 20,
                          reservedSize: 35,
                          getTitlesWidget: (value, meta) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Text(
                                '${value.toInt()}%',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.5),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 12,
                          getTitlesWidget: (value, meta) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                '${(value / 12).round()}Y',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.5),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    lineTouchData: LineTouchData(
                      enabled: true,
                      touchTooltipData: LineTouchTooltipData(
                        tooltipBgColor: const Color(0xFF1E293B),
                        tooltipRoundedRadius: 8,
                        tooltipPadding: const EdgeInsets.all(8),
                        getTooltipItems: (touchedSpots) {
                          return touchedSpots.map((spot) {
                            final alloc = _allocations.firstWhere(
                              (a) => a.color == spot.bar.color!,
                              orElse: () => _allocations.first,
                            );
                            return LineTooltipItem(
                              '${alloc.name}\n${spot.y.toStringAsFixed(1)}%',
                              TextStyle(
                                color: spot.bar.color!,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            );
                          }).toList();
                        },
                      ),
                      getTouchedSpotIndicator: (barData, spotIndexes) {
                        return spotIndexes.map((spotIndex) {
                          return TouchedSpotIndicatorData(
                            FlLine(
                              color: barData.color!.withValues(alpha: 0.2),
                              strokeWidth: 2,
                            ),
                            FlDotData(
                              getDotPainter: (spot, percent, barData, index) {
                                return FlDotCirclePainter(
                                  radius: index == _selectedMonth ? 5 : 0,
                                  color: barData.color ?? Colors.transparent,
                                  strokeWidth: 2,
                                  strokeColor: Colors.white,
                                );
                              },
                            ),
                          );
                        }).toList();
                      },
                      touchCallback: (event, response) {
                        if (response?.lineBarSpots != null &&
                            response!.lineBarSpots!.isNotEmpty &&
                            event is FlTapUpEvent) {
                          final month = response.lineBarSpots![0].x.toInt();
                          setState(() {
                            _selectedMonth = month;
                            _calculateMetrics();
                          });
                        }
                      },
                    ),
                    minX: 0,
                    maxX: 60,
                    minY: 0,
                    maxY: 100,
                    lineBarsData:
                        _allocations.where((a) => a.vesting > 0).map((alloc) {
                      final spots = List.generate(61, (month) {
                        double unlocked = _calculateUnlocked(100, month, alloc);
                        return FlSpot(month.toDouble(), unlocked);
                      });

                      return LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        curveSmoothness: 0.3,
                        color: alloc.color,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, barData, index) {
                            return FlDotCirclePainter(
                              radius: index == _selectedMonth ? 5 : 0,
                              color: barData.color ?? Colors.transparent,
                              strokeWidth: 2,
                              strokeColor: Colors.white,
                            );
                          },
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              alloc.color.withValues(alpha: 0.2),
                              alloc.color.withValues(alpha: 0.0),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  duration: const Duration(milliseconds: 300),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVestingDetails() {
    final circPercent = (_circulatingSupply / _totalSupply) * 100;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF10B981).withValues(alpha: 0.15),
                const Color(0xFF10B981).withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF10B981).withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.lock_open, color: const Color(0xFF10B981), size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Circulating Supply',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_formatNumber(_circulatingSupply)} (${circPercent.toStringAsFixed(1)}%)',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ...List.generate(
          (_allocations.length / 2).ceil(),
          (index) {
            final start = index * 2;
            final end = math.min(start + 2, _allocations.length);

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  for (int i = start; i < end; i++) ...[
                    Expanded(
                      child: _buildVestingCard(_allocations[i]),
                    ),
                    if (i < end - 1) const SizedBox(width: 8),
                  ],
                  if (end - start == 1) const Expanded(child: SizedBox()),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildVestingCard(TokenAllocation alloc) {
    final unlocked = _calculateUnlocked(100, _selectedMonth, alloc);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: alloc.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: alloc.color.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(alloc.icon, color: alloc.color, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  alloc.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: unlocked / 100,
            backgroundColor: alloc.color.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(alloc.color),
            minHeight: 4,
          ),
          const SizedBox(height: 4),
          Text(
            '${unlocked.toStringAsFixed(1)}% unlocked',
            style: TextStyle(
              color: alloc.color,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildPriceChart(),
          const SizedBox(height: 16),
          _buildAnalyticsGrid(),
          const SizedBox(height: 16),
          _buildDistributionBreakdown(),
        ],
      ),
    );
  }

  Widget _buildPriceChart() {
    final currentPrice = _selectedMonth < _priceHistory.length
        ? _priceHistory[_selectedMonth]
        : _priceHistory.isNotEmpty
            ? _priceHistory.last
            : _price;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Price Simulation',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${currentPrice.toStringAsFixed(4)}',
                    style: TextStyle(
                      color: currentPrice >= _price
                          ? const Color(0xFF10B981)
                          : const Color(0xFFEF4444),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.refresh, size: 20),
                onPressed: () {
                  _generatePriceSimulation();
                  _calculateMetrics();
                },
                color: Colors.white54,
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 60,
                lineBarsData: [
                  LineChartBarData(
                    spots: _priceHistory.asMap().entries.map((e) {
                      return FlSpot(e.key.toDouble(), e.value);
                    }).toList(),
                    isCurved: true,
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF6366F1),
                        const Color(0xFF06B6D4),
                      ],
                    ),
                    barWidth: 2,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0xFF6366F1).withValues(alpha: 0.2),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsGrid() {
    final mc = _circulatingSupply * _price;
    final fdv = _totalSupply * _price;
    final locked = (1 - _circulatingSupply / _totalSupply) * 100;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 1.8,
      children: [
        _buildAnalyticsCard(
          'Market Cap',
          '\$${_formatNumber(mc)}',
          Icons.trending_up,
          const Color(0xFF10B981),
        ),
        _buildAnalyticsCard(
          'FDV',
          '\$${_formatNumber(fdv)}',
          Icons.analytics,
          const Color(0xFF6366F1),
        ),
        _buildAnalyticsCard(
          'Circulating',
          '${((_circulatingSupply / _totalSupply) * 100).toStringAsFixed(1)}%',
          Icons.pie_chart,
          const Color(0xFF06B6D4),
        ),
        _buildAnalyticsCard(
          'Locked',
          '${locked.toStringAsFixed(1)}%',
          Icons.lock,
          const Color(0xFFEF4444),
        ),
      ],
    );
  }

  Widget _buildAnalyticsCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 18),
              Text(
                title,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 11,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDistributionBreakdown() {
    final community = _allocations
        .where((a) => ['Public Sale', 'Ecosystem'].contains(a.name))
        .fold(0.0, (sum, a) => sum + a.percentage);

    final team = _allocations
        .where((a) => ['Team'].contains(a.name))
        .fold(0.0, (sum, a) => sum + a.percentage);

    final investors = _allocations
        .where((a) => ['Private Sale'].contains(a.name))
        .fold(0.0, (sum, a) => sum + a.percentage);

    final operations = _allocations
        .where((a) => ['Marketing', 'Reserve'].contains(a.name))
        .fold(0.0, (sum, a) => sum + a.percentage);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Distribution Breakdown',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildBreakdownRow('Community', community, const Color(0xFF10B981)),
          const SizedBox(height: 8),
          _buildBreakdownRow('Team', team, const Color(0xFF3B82F6)),
          const SizedBox(height: 8),
          _buildBreakdownRow('Investors', investors, const Color(0xFF8B5CF6)),
          const SizedBox(height: 8),
          _buildBreakdownRow('Operations', operations, const Color(0xFFF59E0B)),
        ],
      ),
    );
  }

  Widget _buildBreakdownRow(String label, double percentage, Color color) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 30,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: percentage / 100,
                backgroundColor: color.withValues(alpha: 0.2),
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 4,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '${percentage.toStringAsFixed(0)}%',
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.pie_chart, 'Allocation'),
              _buildNavItem(1, Icons.schedule, 'Vesting'),
              _buildNavItem(2, Icons.analytics, 'Analytics'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isActive = _currentView == index;

    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _currentView = index),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isActive ? const Color(0xFF6366F1) : Colors.white38,
                size: 20,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isActive ? const Color(0xFF6366F1) : Colors.white38,
                  fontSize: 11,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
                alignment: Alignment.center,
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const Text(
                'Token Settings',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _totalSupplyCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Total Supply',
                  labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF6366F1)),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _priceCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Initial Price (\$)',
                  labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF6366F1)),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  _calculateMetrics();
                  _generatePriceSimulation();
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Apply Settings',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

class TokenAllocation {
  final String name;
  double percentage;
  final Color color;
  final IconData icon;
  final int vesting;
  final int cliff;
  final double tgeUnlock;

  TokenAllocation(
    this.name,
    this.percentage,
    this.color,
    this.icon,
    this.vesting,
    this.cliff,
    this.tgeUnlock,
  );
}
