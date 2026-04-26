import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/services/chart_service.dart';
import 'package:mobile/core/services/market_service.dart';
import 'package:mobile/features/market/domain/entities/chart_data_entity.dart';
import 'package:mobile/features/market/domain/entities/market_entity.dart';
import 'package:mobile/features/market/domain/entities/market_data_entity.dart';
import 'package:mobile/features/market/domain/entities/ticker_entity.dart';

/// Regression tests for the ChartService dispose lifecycle.
///
/// These tests pin down the fix for the production bug:
///   "Bad state: Cannot add new events after calling close"
/// which was being thrown when MarketService emitted a late update
/// after ChartService.dispose() had already closed its broadcast
/// StreamController.
void main() {
  group('ChartService dispose lifecycle', () {
    late MarketService marketService;
    late ChartService chartService;

    setUp(() {
      marketService = MarketService();
      chartService = ChartService(marketService);
    });

    tearDown(() {
      // Some tests dispose explicitly; double-dispose should still be safe.
      try {
        chartService.dispose();
      } catch (_) {}
    });

    test('updatePrice emits to chartUpdatesStream', () async {
      final emitted = <Map<String, dynamic>>[];
      final sub = chartService.chartUpdatesStream.listen(emitted.add);

      chartService.updatePrice('BTC/USDT', 50000.0, volume: 100.0);

      // Let the broadcast event propagate.
      await Future<void>.delayed(Duration.zero);

      expect(emitted, isNotEmpty);
      expect(emitted.last.containsKey('BTC/USDT'), isTrue);

      await sub.cancel();
    });

    test('updatePrice after dispose does NOT throw (post-close guard)',
        () async {
      chartService.dispose();

      // The original bug: this call would synchronously throw
      //   StateError: "Cannot add new events after calling close"
      // because _emitChartUpdate() called add() on a closed controller.
      expect(
        () => chartService.updatePrice('BTC/USDT', 51000.0, volume: 1.0),
        returnsNormally,
      );
    });

    test('clearAllChartData after dispose does NOT throw', () async {
      chartService.dispose();
      expect(() => chartService.clearAllChartData(), returnsNormally);
    });

    test('clearChartData after dispose does NOT throw', () async {
      chartService.dispose();
      expect(() => chartService.clearChartData('BTC/USDT'), returnsNormally);
    });

    test('initializeSymbols after dispose does NOT throw', () async {
      chartService.dispose();
      expect(
        () => chartService.initializeSymbols(
          const ['BTC/USDT'],
          const {'BTC/USDT': 50000.0},
        ),
        returnsNormally,
      );
    });

    test('disposing chart before market does not throw', () async {
      // ChartService subscribes to MarketService.marketsStream in its
      // constructor. Tearing down chart first must not leave a dangling
      // subscription that crashes when MarketService is later poked.
      chartService.dispose();

      // Calling a MarketService method after the chart is gone should be
      // a no-op (no listeners to dispatch to, no closed-controller writes).
      expect(
        () => marketService.updateMarketsWithTickers(const {}),
        returnsNormally,
      );

      await Future<void>.delayed(Duration.zero);
    });

    test('dispose is safe to call twice (idempotent)', () {
      chartService.dispose();
      expect(() => chartService.dispose(), returnsNormally);
    });

    test('chartUpdatesStream emits done after dispose', () async {
      final completer = Completer<void>();
      chartService.chartUpdatesStream.listen(
        (_) {},
        onDone: completer.complete,
      );

      chartService.dispose();

      await completer.future.timeout(
        const Duration(seconds: 2),
        onTimeout: () => fail('chartUpdatesStream did not emit done'),
      );
    });

    test('getChartStreamForSymbol survives dispose without throwing',
        () async {
      // Subscribe through the per-symbol stream (which is built from the
      // broadcast). After dispose the inner stream completes; consumers must
      // not see any post-close add().
      final received = <MarketChartEntity?>[];
      final sub = chartService
          .getChartStreamForSymbol('BTC/USDT')
          .listen(received.add);

      chartService.updatePrice('BTC/USDT', 50000.0, volume: 1.0);
      await Future<void>.delayed(Duration.zero);

      chartService.dispose();
      await Future<void>.delayed(Duration.zero);

      // Post-dispose updatePrice must not crash even with an active listener.
      expect(
        () => chartService.updatePrice('BTC/USDT', 50001.0, volume: 1.0),
        returnsNormally,
      );

      await sub.cancel();
    });
  });

  // Touch unused entity types so the import isn't dropped by analyzer.
  group('test wiring', () {
    test('imports compile', () {
      expect(MarketEntity, isNotNull);
      expect(TickerEntity, isNotNull);
    });
  });
}
