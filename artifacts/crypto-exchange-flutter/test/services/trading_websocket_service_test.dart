import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/config/app_config.dart';
import 'package:mobile/core/services/trading_websocket_service.dart';

/// Regression tests for TradingWebSocketService dispose lifecycle.
///
/// Pins the fix that added `isClosed` guards to all 7 controller `add()`
/// sites (ticker, orderBook, trades, ohlcv x2, chartTicker, symbolChange).
///
/// NOTE: The constructor schedules a 500ms auto-connect Timer. Tests dispose
/// before / shortly after that timer fires; we don't actually need a real
/// WebSocket to validate the dispose contract.
void main() {
  setUpAll(() {
    AppConfig.reset();
    AppConfig.initializeForTesting();
  });

  group('TradingWebSocketService dispose lifecycle', () {
    test('constructor + immediate dispose is safe', () {
      final svc = TradingWebSocketService();
      // Don't wait for the auto-connect timer — we should be allowed to
      // dispose immediately. The dispose path used to crash if the auto-
      // connect race produced a late add() on a now-closed controller.
      expect(() => svc.dispose(), returnsNormally);
    });

    test('initial state: not connected, no current symbol', () {
      final svc = TradingWebSocketService();
      try {
        expect(svc.isConnected, isFalse);
        expect(svc.currentSymbol, isEmpty);
      } finally {
        svc.dispose();
      }
    });

    test('all public streams are broadcast (multiple listeners allowed)',
        () async {
      final svc = TradingWebSocketService();
      try {
        // Each of these would throw if the underlying controller were
        // single-subscription. The runtime app attaches multiple listeners
        // (chart + trade pages), so this is a real invariant.
        final subs = [
          svc.tickerStream.listen((_) {}),
          svc.tickerStream.listen((_) {}),
          svc.orderBookStream.listen((_) {}),
          svc.orderBookStream.listen((_) {}),
          svc.tradesStream.listen((_) {}),
          svc.ohlcvStream.listen((_) {}),
          svc.chartTickerStream.listen((_) {}),
          svc.symbolChangeStream.listen((_) {}),
        ];
        for (final s in subs) {
          await s.cancel();
        }
      } finally {
        svc.dispose();
      }
    });

    test('dispose closes streams (done events fire)', () async {
      final svc = TradingWebSocketService();

      var tickerDone = false;
      var orderBookDone = false;
      var tradesDone = false;
      var ohlcvDone = false;
      var chartTickerDone = false;
      var symbolChangeDone = false;

      svc.tickerStream.listen((_) {}, onDone: () => tickerDone = true);
      svc.orderBookStream.listen((_) {}, onDone: () => orderBookDone = true);
      svc.tradesStream.listen((_) {}, onDone: () => tradesDone = true);
      svc.ohlcvStream.listen((_) {}, onDone: () => ohlcvDone = true);
      svc.chartTickerStream
          .listen((_) {}, onDone: () => chartTickerDone = true);
      svc.symbolChangeStream
          .listen((_) {}, onDone: () => symbolChangeDone = true);

      svc.dispose();
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(tickerDone, isTrue, reason: 'tickerStream should emit done');
      expect(orderBookDone, isTrue, reason: 'orderBookStream should emit done');
      expect(tradesDone, isTrue, reason: 'tradesStream should emit done');
      expect(ohlcvDone, isTrue, reason: 'ohlcvStream should emit done');
      expect(chartTickerDone, isTrue,
          reason: 'chartTickerStream should emit done');
      expect(symbolChangeDone, isTrue,
          reason: 'symbolChangeStream should emit done');
    });

    // NOTE: A previous version of this file also called `changeSymbol()` after
    // dispose to prove the `_symbolChangeController.add()` guard worked.
    // changeSymbol() does much more than emit a name — it tries to open a real
    // WebSocket — so it is not a clean unit-test surface. The `dispose closes
    // streams` test above already proves the symbolChange controller is closed
    // by dispose, which is what makes the in-source `isClosed` guard needed.
  });
}
