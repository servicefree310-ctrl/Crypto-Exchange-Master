import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/config/app_config.dart';
import 'package:mobile/core/services/market_service.dart';
import 'package:mobile/core/services/websocket_service.dart';

/// Regression tests for WebSocketService dispose / subscription lifecycle.
///
/// These pin down the fix for the production bugs:
///   1. Reconnect spam: `_handleError` used to schedule a reconnect
///      unconditionally, even after disconnect() / dispose() — producing an
///      infinite "Connecting -> Error -> Connecting" loop.
///   2. Closed-controller crash: `_tickersController.add()` could fire after
///      dispose() during a debounced flush, throwing
///      "Cannot add new events after calling close".
void main() {
  setUpAll(() {
    AppConfig.reset();
    AppConfig.initializeForTesting();
  });

  group('WebSocketService lifecycle', () {
    late MarketService marketService;
    late WebSocketService ws;

    setUp(() {
      marketService = MarketService();
      ws = WebSocketService(marketService);
    });

    tearDown(() async {
      try {
        await ws.dispose();
      } catch (_) {}
    });

    test('initial state is disconnected with zero subscribers', () {
      expect(ws.status, equals(WebSocketConnectionStatus.disconnected));
      expect(ws.isConnected, isFalse);
      expect(ws.globalSubscriptionCount, equals(0));
    });

    test(
        'unsubscribeFromTickerUpdates never drives counter below zero',
        () {
      expect(ws.globalSubscriptionCount, equals(0));

      // Calling unsubscribe more times than subscribe must not produce a
      // negative counter (which would later make _scheduleReconnect think
      // there ARE no subs and never reconnect a real session, OR — in older
      // code — would underflow guards).
      ws.unsubscribeFromTickerUpdates();
      ws.unsubscribeFromTickerUpdates();
      ws.unsubscribeFromTickerUpdates();

      expect(ws.globalSubscriptionCount, equals(0));
    });

    test(
        'tickersStream is a broadcast stream (supports multiple listeners)',
        () {
      // Sanity-check that consumers can attach independent listeners
      // (which is what the rest of the app relies on for ticker fan-out).
      final s1 = ws.tickersStream.listen((_) {});
      final s2 = ws.tickersStream.listen((_) {});
      s1.cancel();
      s2.cancel();
    });

    test('statusStream is broadcast', () {
      final s1 = ws.statusStream.listen((_) {});
      final s2 = ws.statusStream.listen((_) {});
      s1.cancel();
      s2.cancel();
    });

    test('dispose is idempotent', () async {
      await ws.dispose();
      // Second dispose hits already-closed controllers; if .close() / .add()
      // call sites aren't guarded, this throws StateError.
      expect(() async => ws.dispose(), returnsNormally);
    });

    test('dispose closes tickersStream (done event fires)', () async {
      var done = false;
      ws.tickersStream.listen((_) {}, onDone: () => done = true);
      await ws.dispose();
      // Allow the broadcast done event to propagate.
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(done, isTrue);
    });

    test('dispose closes statusStream (done event fires)', () async {
      var done = false;
      ws.statusStream.listen((_) {}, onDone: () => done = true);
      await ws.dispose();
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(done, isTrue);
    });

    test('dispose resets the global subscription counter', () async {
      ws.subscribeToTickerUpdates();
      ws.subscribeToTickerUpdates();
      expect(ws.globalSubscriptionCount, greaterThanOrEqualTo(1));

      await ws.dispose();
      expect(ws.globalSubscriptionCount, equals(0));
      expect(ws.isGlobalInitialized, isFalse);
    });

    test('disconnect after dispose does not throw', () async {
      await ws.dispose();
      // The reconnect-spam fix relies on `_manuallyDisconnected` being
      // honored even after dispose. Calling disconnect() again must be safe.
      expect(() async => ws.disconnect(), returnsNormally);
    });
  });
}
