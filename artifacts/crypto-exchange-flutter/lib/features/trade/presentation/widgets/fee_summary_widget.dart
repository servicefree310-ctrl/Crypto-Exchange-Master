import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/network/dio_client.dart';
import '../../../../core/theme/global_theme_extensions.dart';
import '../../../../core/utils/price_formatter.dart';
import '../../../../injection/injection.dart';

/// Live fee / GST / TDS breakdown rendered just above the Buy/Sell button.
/// Calls `/api/fees/quote` whenever quantity, price, or side changes and
/// debounces the request by 250ms so rapid typing doesn't spam the backend.
class FeeSummaryWidget extends StatefulWidget {
  const FeeSummaryWidget({
    super.key,
    required this.isBuy,
    required this.notional,
    required this.quoteCurrency,
    required this.orderType,
  });

  final bool isBuy;
  final double notional;
  final String quoteCurrency;
  /// 'limit' / 'market' / 'stop' — used to pick maker vs taker fee server-side.
  final String orderType;

  @override
  State<FeeSummaryWidget> createState() => _FeeSummaryWidgetState();
}

class _FeeSummaryWidgetState extends State<FeeSummaryWidget> {
  Timer? _debounce;
  _FeeQuote? _quote;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _scheduleFetch();
  }

  @override
  void didUpdateWidget(covariant FeeSummaryWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isBuy != widget.isBuy ||
        oldWidget.notional != widget.notional ||
        oldWidget.orderType != widget.orderType) {
      _scheduleFetch();
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _scheduleFetch() {
    _debounce?.cancel();
    if (widget.notional <= 0) {
      setState(() => _quote = null);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 250), _fetch);
  }

  Future<void> _fetch() async {
    if (!mounted) return;
    setState(() => _loading = true);
    try {
      final client = getIt<DioClient>();
      final notionalAtRequest = widget.notional;
      final sideAtRequest = widget.isBuy;
      final typeAtRequest = widget.orderType;
      final res = await client.get(
        '/api/fees/quote',
        queryParameters: {
          'side': sideAtRequest ? 'buy' : 'sell',
          'type': typeAtRequest,
          'notional': notionalAtRequest,
        },
      );
      // Drop stale response if user changed inputs while request was in flight.
      if (!mounted ||
          notionalAtRequest != widget.notional ||
          sideAtRequest != widget.isBuy ||
          typeAtRequest != widget.orderType) {
        if (mounted) setState(() => _loading = false);
        return;
      }
      if (!mounted) return;
      final data = res.data;
      if (data is Map<String, dynamic>) {
        setState(() {
          _quote = _FeeQuote.fromJson(data);
          _loading = false;
        });
      } else {
        setState(() => _loading = false);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.notional <= 0 || _quote == null) {
      return const SizedBox.shrink();
    }
    final q = _quote!;
    final currency = widget.quoteCurrency;
    final rows = <Widget>[
      _row(
        context,
        label: 'Trading Fee (${q.baseFeePercent.toStringAsFixed(3)}%)',
        value: PriceFormatter.formatCurrency(q.baseFee, currency),
      ),
      _row(
        context,
        label: 'GST (${q.gstPercent.toStringAsFixed(0)}%)',
        value: PriceFormatter.formatCurrency(q.gstAmount, currency),
      ),
      if (!widget.isBuy)
        _row(
          context,
          label: 'TDS (${q.tdsPercent.toStringAsFixed(2)}%)',
          value: PriceFormatter.formatCurrency(q.tds, currency),
        ),
      const SizedBox(height: 4),
      _row(
        context,
        label: widget.isBuy ? 'Total Payable' : 'You Receive',
        value: PriceFormatter.formatCurrency(q.netReceive, currency),
        emphasized: true,
      ),
    ];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: context.inputBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: context.borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_loading)
            const SizedBox(
              height: 2,
              child: LinearProgressIndicator(minHeight: 2),
            ),
          ...rows,
        ],
      ),
    );
  }

  Widget _row(
    BuildContext context, {
    required String label,
    required String value,
    bool emphasized = false,
  }) {
    final color = emphasized ? context.textPrimary : context.textSecondary;
    final weight = emphasized ? FontWeight.w700 : FontWeight.w500;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: color, fontSize: 10.5)),
          Text(value,
              style: TextStyle(
                  color: context.textPrimary,
                  fontSize: 11,
                  fontWeight: weight)),
        ],
      ),
    );
  }
}

class _FeeQuote {
  _FeeQuote({
    required this.feePercent,
    required this.baseFeePercent,
    required this.gstPercent,
    required this.tdsPercent,
    required this.baseFee,
    required this.gstAmount,
    required this.fee,
    required this.tds,
    required this.netReceive,
  });

  final double feePercent;
  final double baseFeePercent;
  final double gstPercent;
  final double tdsPercent;
  final double baseFee;
  final double gstAmount;
  final double fee;
  final double tds;
  final double netReceive;

  static double _n(dynamic v) => v is num ? v.toDouble() : 0.0;

  factory _FeeQuote.fromJson(Map<String, dynamic> j) => _FeeQuote(
        feePercent: _n(j['feePercent']),
        baseFeePercent: _n(j['baseFeePercent']),
        gstPercent: _n(j['gstPercent']),
        tdsPercent: _n(j['tdsPercent']),
        baseFee: _n(j['baseFee']),
        gstAmount: _n(j['gstAmount']),
        fee: _n(j['fee']),
        tds: _n(j['tds']),
        netReceive: _n(j['netReceive']),
      );
}
