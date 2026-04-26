import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/config/app_config.dart';
import 'package:mobile/core/services/market_service.dart';
import 'package:mobile/core/services/websocket_service.dart';

/// Regression tests for WebSocketService dispose / subscription lifecycle.
///
/// These pin down the fixes for two production bugs:
///   1. Reconnect spam: `_handleError` used to schedule a reconnect
///      unconditionally, even after disconnect() / dispose() — producing an
///      infinite "Connecting -> Error -> Connecting" loop and burning the
///      user's battery / data.
///   2. Closed-controller crash: `_tickersController.add()` could fire after
///      dispose() during a debounced flush, throwing
///      "Cannot add new events after calling close".
///
/// We use the @visibleForTesting `debugInjectMessage` / `debugTriggerError` /
/// `debugTriggerDisconnection` seams to drive the private handlers directly,
/// so we can exercise the exact regression code paths without standing up a
/// real WebSocket.
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
      expect(ws.debugReconnectAttempts, equals(0));
      expect(ws.debugHasReconnectTimerScheduled, isFalse);
    });

    test('unsubscribeFromTickerUpdates never drives counter below zero', () {
      expect(ws.globalSubscriptionCount, equals(0));

      // Calling unsubscribe more times than subscribe must not produce a
      // negative counter (which would later make _scheduleReconnect think
      // there ARE no subs and never reconnect a real session, OR — in older
      // code — would underflow the > 0 guard inside _handleError).
      ws.unsubscribeFromTickerUpdates();
      ws.unsubscribeFromTickerUpdates();
      ws.unsubscribeFromTickerUpdates();

      expect(ws.globalSubscriptionCount, equals(0));
    });

    test('tickersStream is a broadcast stream (supports multiple listeners)',
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

    test('dispose is idempotent and completes without throwing', () async {
      await ws.dispose();
      // Second dispose hits already-closed controllers; if .close() / .add()
      // call sites aren't guarded, this throws StateError. We assert on the
      // returned Future actually completing (not just on the synchronous
      // construction of the closure not throwing).
      await expectLater(ws.dispose(), completes);
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

    test('disconnect after dispose completes without throwing', () async {
      await ws.dispose();
      // The reconnect-spam fix relies on `_manuallyDisconnected` being
      // honored even after dispose. Calling disconnect() again must be safe
      // *and* must actually return (not just construct a non-throwing
      // closure).
      await expectLater(ws.disconnect(), completes);
    });
  });

  group('WebSocketService closed-controller guards (post-dispose events)', () {
    late MarketService marketService;
    late WebSocketService ws;

    setUp(() {
      marketService = MarketService();
      ws = WebSocketService(marketService);
    });

    test(
        'debugInjectMessage after dispose does not crash on closed ticker '
        'controller (debounced flush guard)', () async {
      await ws.dispose();

      // The original bug: _handleMessage parses the ticker payload, kicks
      // off a 100ms debounce Timer, and then the Timer callback calls
      // `_tickersController.add(...)` — which throws StateError if dispose
      // ran in the meantime. The fix wraps that .add() in `if (!isClosed)`.
      // We synchronously inject a valid ticker frame here, then wait for
      // the debounce window to pass; if the guard regresses, the timer
      // callback will throw asynchronously and the test will fail.
      expect(
        () => ws.debugInjectMessage(
            '{"stream":"tickers","data":{"BTC/USDT":{"last":50000}}}'),
        returnsNormally,
      );

      // Wait safely past the debounce window so the late add() would fire.
      await Future<void>.delayed(
          ws.debugUpdateDebounceDelay + const Duration(milliseconds: 50));
    });

    test(
        'debugTriggerError after dispose does not schedule a reconnect '
        '(manual-disconnect guard honored)', () async {
      await ws.dispose();

      ws.debugTriggerError('synthetic socket error');

      // dispose() set _manuallyDisconnected = true and zeroed the
      // subscription counter; both gates in _scheduleReconnect must hold.
      expect(ws.debugHasReconnectTimerScheduled, isFalse);
      expect(ws.debugReconnectAttempts, equals(0));
    });

    test(
        'debugTriggerDisconnection after dispose does not schedule a '
        'reconnect', () async {
      await ws.dispose();

      ws.debugTriggerDisconnection();

      expect(ws.debugHasReconnectTimerScheduled, isFalse);
      expect(ws.debugReconnectAttempts, equals(0));
    });
  });

  group('WebSocketService reconnect-storm prevention', () {
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

    test(
        'manual disconnect blocks subsequent error from scheduling reconnect',
        () async {
      // Pretend the app had subscribers (so _scheduleReconnect's other
      // gate — count > 0 — would otherwise allow a reconnect).
      ws.subscribeToTickerUpdates();
      expect(ws.globalSubscriptionCount, greaterThan(0));

      await ws.disconnect();

      // After disconnect: _manuallyDisconnected = true. A late socket
      // error must NOT schedule a reconnect; this is the regression that
      // produced the infinite "Connecting -> Error -> Connecting" loop.
      ws.debugTriggerError('socket dropped after manual disconnect');

      expect(ws.debugHasReconnectTimerScheduled, isFalse);
      expect(ws.debugReconnectAttempts, equals(0));
    });

    test(
        'rapid back-to-back errors collapse into a single pending reconnect '
        'timer (no timer pile-up)', () async {
      // Need at least one subscriber so the reconnect gate opens.
      ws.subscribeToTickerUpdates();

      // Fire three errors in quick succession. _scheduleReconnect must
      // cancel the previous timer each time, so we end up with exactly
      // one pending reconnect timer (not three) and the attempt counter
      // reflects the number of schedules, not a runaway loop.
      ws.debugTriggerError('err 1');
      ws.debugTriggerError('err 2');
      ws.debugTriggerError('err 3');

      expect(ws.debugHasReconnectTimerScheduled, isTrue,
          reason: 'one reconnect timer should be active');
      expect(ws.debugReconnectAttempts, equals(3),
          reason: 'each error increments the attempt counter, but only the '
              'most recent timer should remain pending (older timers cancelled)');
    });

    test(
        'reconnect attempts stop scheduling after _maxReconnectAttempts '
        '(bounded backoff, no infinite loop)', () async {
      ws.subscribeToTickerUpdates();

      // _maxReconnectAttempts is 5; trigger 6 errors and assert the 6th
      // does not schedule another timer.
      for (var i = 0; i < 5; i++) {
        ws.debugTriggerError('err $i');
      }
      expect(ws.debugReconnectAttempts, equals(5));
      expect(ws.debugHasReconnectTimerScheduled, isTrue);

      // Cancel the pending timer to set up a clean "no timer" baseline,
      // then trigger one more error — the cap should refuse to schedule.
      // (We can't directly cancel from outside; instead we observe that
      // the attempt counter does not move past 5 on the next error.)
      ws.debugTriggerError('err overflow');
      expect(ws.debugReconnectAttempts, equals(5),
          reason: 'attempt counter must not advance past max');
    });
  });
}
