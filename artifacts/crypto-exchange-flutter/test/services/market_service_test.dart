import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/services/market_service.dart';
import 'package:mobile/features/market/data/models/market_model.dart';

void main() {
  group('MarketService', () {
    late MarketService marketService;

    setUp(() {
      marketService = MarketService();
    });

    tearDown(() {
      marketService.dispose();
    });

    test('should parse market API response correctly', () {
      // Sample API response data
      final apiResponse = [
        {
          "metadata": {
            "taker": 0.001,
            "maker": 0.001,
            "precision": {"price": 4, "amount": 1},
            "limits": {
              "amount": {"min": 0.1, "max": 9000000},
              "price": {"min": 0.0001, "max": 1000},
              "cost": {"min": 5, "max": 9000000},
              "leverage": {}
            }
          },
          "id": "06fefb20-83dc-464b-b2ad-72e792d34470",
          "currency": "TRX",
          "pair": "USDT",
          "isTrending": false,
          "isHot": false,
          "status": true,
          "isEco": false
        },
        {
          "metadata": {
            "taker": 0.001,
            "maker": 0.001,
            "precision": {"price": 6, "amount": 0},
            "limits": {
              "amount": {"min": 1, "max": 8384883677},
              "price": {"min": 0.000001, "max": 10},
              "cost": {"min": 1, "max": 9000000},
              "leverage": {}
            }
          },
          "id": "083da7e2-8072-474a-ad05-cc78ea5717a8",
          "currency": "TURBO",
          "pair": "USDT",
          "isTrending": false,
          "isHot": false,
          "status": true,
          "isEco": false
        }
      ];

      // Test parsing
      final markets =
          apiResponse.map((json) => MarketModel.fromJson(json)).toList();

      expect(markets.length, equals(2));

      // Test first market
      final trxMarket = markets[0];
      expect(trxMarket.id, equals("06fefb20-83dc-464b-b2ad-72e792d34470"));
      expect(trxMarket.currency, equals("TRX"));
      expect(trxMarket.pair, equals("USDT"));
      expect(trxMarket.isTrending, equals(false));
      expect(trxMarket.isHot, equals(false));
      expect(trxMarket.status, equals(true));
      expect(trxMarket.isEco, equals(false));

      // Test metadata
      expect(trxMarket.metadata, isNotNull);
      expect(trxMarket.metadata!.taker, equals(0.001));
      expect(trxMarket.metadata!.maker, equals(0.001));
      expect(trxMarket.metadata!.precision.price, equals(4));
      expect(trxMarket.metadata!.precision.amount, equals(1));
      expect(trxMarket.metadata!.limits.amount?.min, equals(0.1));
      expect(trxMarket.metadata!.limits.amount?.max, equals(9000000));
      expect(trxMarket.metadata!.limits.price?.min, equals(0.0001));
      expect(trxMarket.metadata!.limits.price?.max, equals(1000));
      expect(trxMarket.metadata!.limits.cost?.min, equals(5));
      expect(trxMarket.metadata!.limits.cost?.max, equals(9000000));

      // Test second market
      final turboMarket = markets[1];
      expect(turboMarket.id, equals("083da7e2-8072-474a-ad05-cc78ea5717a8"));
      expect(turboMarket.currency, equals("TURBO"));
      expect(turboMarket.pair, equals("USDT"));
      expect(turboMarket.metadata!.precision.price, equals(6));
      expect(turboMarket.metadata!.precision.amount, equals(0));
    });

    test('should convert to entity correctly', () {
      final marketModel = MarketModel(
        id: "test-id",
        currency: "BTC",
        pair: "USDT",
        isTrending: true,
        isHot: false,
        status: true,
        isEco: false,
        metadata: MarketMetadataModel(
          taker: 0.001,
          maker: 0.001,
          precision: MarketPrecisionModel(price: 2, amount: 5),
          limits: MarketLimitsModel(
            amount: MarketLimitModel(min: 0.001, max: 1000),
            price: MarketLimitModel(min: 0.01, max: 100000),
            cost: MarketLimitModel(min: 5, max: 9000000),
          ),
        ),
      );

      final entity = marketModel.toEntity();

      expect(entity.id, equals("test-id"));
      expect(entity.symbol, equals("BTC/USDT"));
      expect(entity.currency, equals("BTC"));
      expect(entity.pair, equals("USDT"));
      expect(entity.isTrending, equals(true));
      expect(entity.isHot, equals(false));
      expect(entity.status, equals(true));
      expect(entity.isEco, equals(false));
      expect(entity.taker, equals(0.001));
      expect(entity.maker, equals(0.001));
      expect(entity.precision!.price, equals(2));
      expect(entity.precision!.amount, equals(5));
      expect(entity.limits!.minAmount, equals(0.001));
      expect(entity.limits!.maxAmount, equals(1000));
      expect(entity.limits!.minPrice, equals(0.01));
      expect(entity.limits!.maxPrice, equals(100000));
      expect(entity.limits!.minCost, equals(5));
      expect(entity.limits!.maxCost, equals(9000000));
    });
  });
}
