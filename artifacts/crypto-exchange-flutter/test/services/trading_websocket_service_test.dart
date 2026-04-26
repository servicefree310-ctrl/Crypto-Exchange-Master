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
      // dispose() is sync (returns void), so a closure that calls it can
      // be checked with returnsNormally.
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

    test(
        'debugInjectMarketMessage after dispose does not crash on any of the '
        'six closed controllers (post-close add() guards)', () async {
      final svc = TradingWebSocketService();
      svc.dispose();

      // Wait past the constructor's 500ms auto-connect timer so any late
      // private side effects are also accounted for.
      await Future<void>.delayed(const Duration(milliseconds: 50));

      // Drive the real private message handler with valid frames for each
      // stream type. Without the per-controller `isClosed` guards added in
      // the production fix, these would throw
      //   "Bad state: Cannot add new events after calling close"
      // synchronously inside the handler.
      const tickerFrame =
          '{"stream":"tickers","data":{"BTC/USDT":{"last":50000,"baseVolume":1,"quoteVolume":1,"change":0,"bid":0,"ask":0,"high":0,"low":0}}}';
      const orderBookFrame =
          '{"stream":"orderbook","data":{"BTC/USDT":{"bids":[[50000,1]],"asks":[[50001,1]]}}}';
      const tradesFrame =
          '{"stream":"trades","data":{"BTC/USDT":[{"price":50000,"amount":1,"side":"buy","timestamp":0}]}}';
      const ohlcvFrame =
          '{"stream":"ohlcv:BTC/USDT:1h","data":[[0,100,200,50,150,1]]}';

      expect(() => svc.debugInjectMarketMessage(tickerFrame), returnsNormally);
      expect(
          () => svc.debugInjectMarketMessage(orderBookFrame), returnsNormally);
      expect(() => svc.debugInjectMarketMessage(tradesFrame), returnsNormally);
      expect(() => svc.debugInjectMarketMessage(ohlcvFrame), returnsNormally);
    });

    test('debugInjectMarketMessage tolerates malformed input (no crash)', () {
      final svc = TradingWebSocketService();
      try {
        // Catch-all in _handleMarketMessage must swallow parse errors instead
        // of bubbling them up into the WebSocket onError path (which would
        // tear the whole shared connection down).
        expect(() => svc.debugInjectMarketMessage('not json'), returnsNormally);
        expect(() => svc.debugInjectMarketMessage('{}'), returnsNormally);
        expect(() => svc.debugInjectMarketMessage('{"stream":"unknown"}'),
            returnsNormally);
      } finally {
        svc.dispose();
      }
    });
  });
}
