import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/config/app_config.dart';
import 'package:mobile/core/services/futures_websocket_service.dart';

/// Regression tests for FuturesWebSocketService dispose lifecycle.
///
/// These pin down that the per-controller `isClosed` guards on
/// `_tickerCtrl.add()`, `_orderBookCtrl.add()`, and `_tradesCtrl.add()` keep
/// the service from throwing
///   "Bad state: Cannot add new events after calling close"
/// if a stray packet is parsed after dispose() (or if dispose is called twice).
void main() {
  setUpAll(() {
    // Constructor doesn't read AppConfig, but `connect()` does. Initialize so
    // tests that touch ApiConstants don't crash with "AppConfig not initialized".
    AppConfig.reset();
    AppConfig.initializeForTesting();
  });

  group('FuturesWebSocketService dispose lifecycle', () {
    test('constructor + immediate dispose is safe', () {
      final svc = FuturesWebSocketService();
      expect(() => svc.dispose(), returnsNormally);
    });

    test('dispose closes all three streams (done event fires)', () async {
      final svc = FuturesWebSocketService();

      var tickerDone = false;
      var orderBookDone = false;
      var tradesDone = false;

      svc.tickerStream.listen((_) {}, onDone: () => tickerDone = true);
      svc.orderBookStream.listen((_) {}, onDone: () => orderBookDone = true);
      svc.tradesStream.listen((_) {}, onDone: () => tradesDone = true);

      svc.dispose();

      // Allow the broadcast done events to propagate.
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(tickerDone, isTrue, reason: 'tickerStream should emit done');
      expect(orderBookDone, isTrue, reason: 'orderBookStream should emit done');
      expect(tradesDone, isTrue, reason: 'tradesStream should emit done');
    });

    test('dispose is idempotent', () {
      final svc = FuturesWebSocketService();
      svc.dispose();
      // Second dispose hits already-closed StreamControllers; if the .close()
      // calls are not guarded, this would throw.
      expect(() => svc.dispose(), returnsNormally);
    });

    test('initial state: not connected, no current symbol', () {
      final svc = FuturesWebSocketService();
      try {
        expect(svc.isConnected, isFalse);
        expect(svc.currentSymbol, isEmpty);
      } finally {
        svc.dispose();
      }
    });

    test('streams are broadcast (multiple listeners allowed)', () {
      final svc = FuturesWebSocketService();
      try {
        final s1 = svc.tickerStream.listen((_) {});
        final s2 = svc.tickerStream.listen((_) {});
        // If the stream were single-subscription, the second listen would throw.
        s1.cancel();
        s2.cancel();
      } finally {
        svc.dispose();
      }
    });

    test(
        'debugInjectMessage after dispose does not crash on closed ticker / '
        'orderbook / trades controllers', () {
      final svc = FuturesWebSocketService();
      svc.dispose();

      // Drive the real private message handler with valid frames AFTER
      // dispose. Without `if (!ctrl.isClosed)` guards inside _parseTicker /
      // _parseOrderBook / _parseTrades, these would throw
      //   "Bad state: Cannot add new events after calling close"
      // synchronously inside the handler.
      const ticker =
          '{"stream":"ticker","data":{"symbol":"BTC/USDT","last":50000,"baseVolume":1,"quoteVolume":1,"percentage":0,"bid":0,"ask":0,"high":0,"low":0}}';
      const orderbook =
          '{"stream":"orderbook","data":{"bids":[[50000,1]],"asks":[[50001,1]]}}';
      const trades = '{"stream":"trades","data":[]}';

      expect(() => svc.debugInjectMessage(ticker), returnsNormally);
      expect(() => svc.debugInjectMessage(orderbook), returnsNormally);
      expect(() => svc.debugInjectMessage(trades), returnsNormally);
    });

    test('debugInjectMessage tolerates malformed input (no crash)', () {
      final svc = FuturesWebSocketService();
      try {
        expect(() => svc.debugInjectMessage('not json'), returnsNormally);
        expect(() => svc.debugInjectMessage('{}'), returnsNormally);
        expect(() => svc.debugInjectMessage('{"stream":"unknown"}'),
            returnsNormally);
      } finally {
        svc.dispose();
      }
    });
  });
}
