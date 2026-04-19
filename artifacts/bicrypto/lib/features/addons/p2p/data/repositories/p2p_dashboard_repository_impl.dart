import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/errors/failures.dart';
import '../../../../../core/errors/exceptions.dart';
import '../../../../../core/network/network_info.dart';
import '../../domain/entities/p2p_activity_entity.dart';
import '../../domain/entities/p2p_trade_entity.dart';
import '../../domain/repositories/p2p_dashboard_repository.dart';
import '../../domain/usecases/dashboard/get_dashboard_data_usecase.dart';
import '../../domain/usecases/dashboard/get_dashboard_stats_usecase.dart';
import '../../domain/usecases/dashboard/get_portfolio_data_usecase.dart';
import '../datasources/p2p_remote_datasource.dart';
import '../datasources/p2p_local_datasource.dart';

/// Repository implementation for P2P dashboard operations
@Injectable(as: P2PDashboardRepository)
class P2PDashboardRepositoryImpl implements P2PDashboardRepository {
  const P2PDashboardRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
    this._networkInfo,
  );

  final P2PRemoteDataSource _remoteDataSource;
  final P2PLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;

  @override
  Future<Either<Failure, P2PDashboardResponse>> getDashboardData() async {
    try {
      // Check network connectivity
      if (!await _networkInfo.isConnected) {
        // Try to get cached data
        final cachedData = await _localDataSource.getCachedDashboardData();
        if (cachedData != null) {
          return Right(_convertJsonToDashboardResponse(cachedData));
        }
        return Left(NetworkFailure('No internet connection'));
      }

      final response = await _remoteDataSource.getDashboardData();

      // Cache the results
      await _localDataSource.cacheDashboardData(response);

      return Right(_convertJsonToDashboardResponse(response));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, DashboardStatsResponse>> getDashboardStats() async {
    try {
      // Check network connectivity
      if (!await _networkInfo.isConnected) {
        return Left(NetworkFailure('No internet connection'));
      }

      final response = await _remoteDataSource.getDashboardStats();

      return Right(_convertJsonToStatsResponse(response));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<P2PActivityEntity>>> getTradingActivity({
    int limit = 10,
    int offset = 0,
    String? type,
  }) async {
    try {
      // Check network connectivity
      if (!await _networkInfo.isConnected) {
        return Left(NetworkFailure('No internet connection'));
      }

      final response = await _remoteDataSource.getTradingActivity(
        limit: limit,
        offset: offset,
        type: type,
      );

      final activities =
          response.map((json) => _convertJsonToActivityEntity(json)).toList();

      return Right(activities);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PortfolioDataResponse>> getPortfolioData() async {
    try {
      // Check network connectivity
      if (!await _networkInfo.isConnected) {
        return Left(NetworkFailure('No internet connection'));
      }

      final response = await _remoteDataSource.getPortfolioData();

      return Right(_convertJsonToPortfolioResponse(response));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  // Helper methods
  P2PDashboardResponse _convertJsonToDashboardResponse(
      Map<String, dynamic> json) {
    final portfolio = _asMap(json['portfolio']);
    final stats = _extractStatsMap(json['stats'], json);
    final tradingActivity = _asListOfMap(
      json['tradingActivity'] ?? json['recentActivity'],
    );
    final transactions = _asListOfMap(json['transactions']);
    final summary = _asMap(json['summary']);
    final now = DateTime.now();

    final transactionEntities =
        transactions.map((trade) => _convertJsonToTradeEntity(trade)).toList();

    final todayTrades = transactionEntities
        .where((t) =>
            t.createdAt.year == now.year &&
            t.createdAt.month == now.month &&
            t.createdAt.day == now.day)
        .length;
    final weeklyTrades = transactionEntities
        .where((t) => now.difference(t.createdAt).inDays < 7)
        .length;
    final monthlyTrades = transactionEntities
        .where((t) => now.difference(t.createdAt).inDays < 30)
        .length;
    final pendingActions = transactionEntities
        .where((t) =>
            t.status == P2PTradeStatus.pending ||
            t.status == P2PTradeStatus.paymentSent ||
            t.status == P2PTradeStatus.disputed)
        .length;

    return P2PDashboardResponse(
      notifications: _toInt(json['notifications']) ?? 0,
      portfolio: PortfolioData(
        totalValue: _toDouble(portfolio['totalValue']) ?? 0.0,
        totalTrades: _toInt(portfolio['totalTrades']) ??
            _toInt(stats['totalTrades']) ??
            transactionEntities.length,
        profitLoss: _toDouble(portfolio['profitLoss']) ??
            _toDouble(portfolio['change24h']) ??
            0.0,
        monthlyVolume: _toDouble(portfolio['monthlyVolume']) ??
            _toDouble(portfolio['completedVolume']) ??
            0.0,
      ),
      stats: DashboardStats(
        totalTrades: _toInt(stats['totalTrades']) ?? transactionEntities.length,
        activeTrades: _toInt(stats['activeTrades']) ??
            transactionEntities
                .where((t) =>
                    t.status == P2PTradeStatus.pending ||
                    t.status == P2PTradeStatus.inProgress ||
                    t.status == P2PTradeStatus.paymentSent)
                .length,
        completedTrades: _toInt(stats['completedTrades']) ??
            transactionEntities
                .where((t) => t.status == P2PTradeStatus.completed)
                .length,
        successRate: _toDouble(stats['successRate']) ?? 0.0,
        totalVolume: _toDouble(stats['totalVolume']) ??
            transactionEntities.fold<double>(
              0.0,
              (sum, item) => sum + item.fiatAmount,
            ),
        avgTradeSize: _toDouble(stats['avgTradeSize']) ??
            _deriveAverageTradeSize(
              _toDouble(stats['totalVolume']),
              _toInt(stats['totalTrades']) ?? transactionEntities.length,
            ),
      ),
      tradingActivity:
          tradingActivity.map(_convertJsonToActivityEntity).toList(),
      transactions: transactionEntities,
      summary: DashboardSummary(
        todayTrades: _toInt(summary['todayTrades']) ?? todayTrades,
        weeklyTrades: _toInt(summary['weeklyTrades']) ?? weeklyTrades,
        monthlyTrades: _toInt(summary['monthlyTrades']) ?? monthlyTrades,
        pendingActions: _toInt(summary['pendingActions']) ?? pendingActions,
        alerts: _toInt(summary['alerts']) ??
            (_toInt(json['notifications']) != null &&
                    (_toInt(json['notifications']) ?? 0) > 0
                ? 1
                : 0),
      ),
    );
  }

  DashboardStatsResponse _convertJsonToStatsResponse(
      Map<String, dynamic> json) {
    final stats = _extractStatsMap(json['stats'], json);
    final totalTrades =
        _toInt(json['totalTrades']) ?? _toInt(stats['totalTrades']) ?? 0;
    final completedTrades = _toInt(json['completedTrades']) ??
        _toInt(stats['completedTrades']) ??
        0;
    final totalVolume = _toDouble(json['totalVolume']) ??
        _toDouble(stats['totalVolume']) ??
        0.0;

    return DashboardStatsResponse(
      totalTrades: totalTrades,
      activeTrades:
          _toInt(json['activeTrades']) ?? _toInt(stats['activeTrades']) ?? 0,
      completedTrades: completedTrades,
      disputedTrades: _toInt(json['disputedTrades']) ??
          _toInt(stats['disputedTrades']) ??
          0,
      cancelledTrades: _toInt(json['cancelledTrades']) ??
          _toInt(stats['cancelledTrades']) ??
          0,
      successRate: _toDouble(json['successRate']) ??
          _toDouble(stats['successRate']) ??
          (totalTrades > 0 ? (completedTrades / totalTrades) * 100 : 0.0),
      totalVolume: totalVolume,
      monthlyVolume: _toDouble(json['monthlyVolume']) ??
          _toDouble(stats['monthlyVolume']) ??
          0.0,
      averageTradeSize: _toDouble(json['averageTradeSize']) ??
          _toDouble(stats['avgTradeSize']) ??
          _deriveAverageTradeSize(totalVolume, totalTrades),
      averageCompletionTime: _toDouble(json['averageCompletionTime']) ??
          _toDouble(stats['averageCompletionTime']),
    );
  }

  PortfolioDataResponse _convertJsonToPortfolioResponse(
      Map<String, dynamic> json) {
    final topCurrencies = _asListOfMap(json['topCurrencies']);
    final recentPerformance = _asListOfMap(json['recentPerformance']);
    final chartData = _asListOfMap(json['chartData']);

    return PortfolioDataResponse(
      totalValue: _toDouble(json['totalValue']) ?? 0.0,
      totalTrades: _toInt(json['totalTrades']) ?? 0,
      monthlyVolume: _toDouble(json['monthlyVolume']) ??
          _toDouble(json['completedVolume']) ??
          0.0,
      profitLoss:
          _toDouble(json['profitLoss']) ?? _toDouble(json['change24h']) ?? 0.0,
      profitLossPercentage: _toDouble(json['profitLossPercentage']) ??
          _toDouble(json['changePercentage']) ??
          0.0,
      topCurrencies: topCurrencies
          .map((item) => CurrencyData(
                currency: item['currency']?.toString() ?? '',
                volume: _toDouble(item['volume'] ?? item['totalVolume']) ?? 0.0,
                trades: _toInt(item['trades']) ?? 0,
                percentage: _toDouble(item['percentage']) ?? 0.0,
              ))
          .toList(),
      recentPerformance:
          (recentPerformance.isNotEmpty ? recentPerformance : chartData)
              .asMap()
              .entries
              .map((entry) {
        final item = entry.value;
        final fallbackDate = DateTime.now().subtract(
          Duration(days: (chartData.length - entry.key).clamp(1, 365)),
        );

        return PerformanceData(
          date: _parseDate(item['date']) ?? fallbackDate,
          volume: _toDouble(item['volume'] ?? item['value']) ?? 0.0,
          trades: _toInt(item['trades']) ?? 0,
          profit: _toDouble(item['profit']) ?? 0.0,
        );
      }).toList(),
    );
  }

  P2PActivityEntity _convertJsonToActivityEntity(Map<String, dynamic> json) {
    return P2PActivityEntity(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      type: _parseActivityType(json['type']?.toString()),
      message:
          json['message']?.toString() ?? json['description']?.toString() ?? '',
      tradeId: json['tradeId']?.toString(),
      offerId: json['offerId']?.toString(),
      details: {
        'amount': _toDouble(json['amount']),
        'currency': json['currency']?.toString(),
        'status': json['status']?.toString(),
        ...?_asNullableMap(json['metadata']),
      },
      createdAt:
          _parseDate(json['timestamp'] ?? json['createdAt']) ?? DateTime.now(),
    );
  }

  P2PTradeEntity _convertJsonToTradeEntity(Map<String, dynamic> json) {
    final amount = _toDouble(json['amount']) ?? 0.0;
    final fiatAmount = _toDouble(json['total'] ?? json['fiatAmount']) ?? 0.0;
    final createdAt = _parseDate(json['createdAt']) ?? DateTime.now();
    final updatedAt = _parseDate(json['updatedAt']) ?? createdAt;
    final currency =
        json['currency']?.toString() ?? json['coin']?.toString() ?? 'BTC';

    return P2PTradeEntity(
      id: json['id']?.toString() ?? '',
      offerId: json['offerId']?.toString() ?? '',
      buyerId: json['buyerId']?.toString() ?? '',
      sellerId: json['sellerId']?.toString() ?? '',
      type: _parseTradeType(json['type']?.toString()),
      currency: currency,
      amount: amount,
      price:
          _toDouble(json['price']) ?? (amount > 0 ? fiatAmount / amount : 0.0),
      fiatAmount: fiatAmount,
      status: _parseTradeStatus(json['status']?.toString()),
      paymentMethod: json['paymentMethod']?.toString() ??
          json['paymentMethodName']?.toString(),
      paymentDetails: _asNullableMap(json['paymentDetails']),
      disputeReason: json['disputeReason']?.toString(),
      disputeDetails: json['disputeDetails']?.toString(),
      completedAt: _parseDate(json['completedAt']),
      cancelledAt: _parseDate(json['cancelledAt']),
      disputedAt: _parseDate(json['disputedAt']),
      expiresAt: _parseDate(json['expiresAt']),
      buyer: _asNullableMap(json['buyer']),
      seller: _asNullableMap(json['seller']),
      offer: _asNullableMap(json['offer']),
      dispute: _asNullableMap(json['dispute']),
      messages: null,
      timeline: null,
      escrowAmount: _toDouble(json['escrowAmount']),
      escrowFee: _toDouble(json['escrowFee']),
      paymentReference: json['paymentReference']?.toString(),
      paymentProof: null,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  Map<String, dynamic> _extractStatsMap(
    dynamic statsRaw,
    Map<String, dynamic> root,
  ) {
    final statsFromRoot = _asMap(statsRaw);
    if (statsFromRoot.isNotEmpty) {
      return statsFromRoot;
    }

    final cards = _asListOfMap(statsRaw);
    if (cards.isEmpty) {
      return <String, dynamic>{};
    }

    final extracted = <String, dynamic>{};

    for (final card in cards) {
      final title = (card['title'] ?? '').toString().trim().toLowerCase();
      final value = card['value'];
      if (title.contains('active')) {
        extracted['activeTrades'] = _toInt(value);
      } else if (title.contains('success')) {
        extracted['successRate'] = _toDouble(value);
      } else if (title.contains('volume')) {
        extracted['totalVolume'] = _toDouble(value);
      } else if (title.contains('trade')) {
        extracted['totalTrades'] = _toInt(value);
      } else if (title.contains('balance')) {
        extracted['totalBalance'] = _toDouble(value);
      }
    }

    if (root['totalTrades'] != null) {
      extracted['totalTrades'] = _toInt(root['totalTrades']);
    }
    if (root['activeTrades'] != null) {
      extracted['activeTrades'] = _toInt(root['activeTrades']);
    }
    if (root['completedTrades'] != null) {
      extracted['completedTrades'] = _toInt(root['completedTrades']);
    }
    if (root['disputedTrades'] != null) {
      extracted['disputedTrades'] = _toInt(root['disputedTrades']);
    }
    if (root['cancelledTrades'] != null) {
      extracted['cancelledTrades'] = _toInt(root['cancelledTrades']);
    }
    if (root['averageTradeSize'] != null) {
      extracted['avgTradeSize'] = _toDouble(root['averageTradeSize']);
    }
    if (root['averageCompletionTime'] != null) {
      extracted['averageCompletionTime'] =
          _toDouble(root['averageCompletionTime']);
    }
    if (root['monthlyVolume'] != null) {
      extracted['monthlyVolume'] = _toDouble(root['monthlyVolume']);
    }

    final totalTrades = _toInt(extracted['totalTrades']) ?? 0;
    final completedTrades = _toInt(extracted['completedTrades']);
    if (extracted['successRate'] == null &&
        completedTrades != null &&
        totalTrades > 0) {
      extracted['successRate'] = (completedTrades / totalTrades) * 100;
    }

    return extracted;
  }

  double _deriveAverageTradeSize(double? totalVolume, int totalTrades) {
    if (totalTrades <= 0) return 0.0;
    return (totalVolume ?? 0.0) / totalTrades;
  }

  P2PActivityType _parseActivityType(String? rawType) {
    final normalized = _normalizeToken(rawType);

    switch (normalized) {
      case 'OFFER_CREATED':
        return P2PActivityType.offerCreated;
      case 'OFFER_UPDATED':
        return P2PActivityType.offerUpdated;
      case 'OFFER_ACTIVATED':
        return P2PActivityType.offerActivated;
      case 'OFFER_DEACTIVATED':
        return P2PActivityType.offerDeactivated;
      case 'OFFER_DELETED':
        return P2PActivityType.offerDeleted;
      case 'TRADE_INITIATED':
      case 'TRADE_CREATED':
      case 'BUY':
      case 'SELL':
        return P2PActivityType.tradeInitiated;
      case 'TRADE_ACCEPTED':
        return P2PActivityType.tradeAccepted;
      case 'PAYMENT_SENT':
        return P2PActivityType.paymentSent;
      case 'PAYMENT_CONFIRMED':
        return P2PActivityType.paymentConfirmed;
      case 'ESCROW_RELEASED':
      case 'FUNDS_RELEASED':
        return P2PActivityType.escrowReleased;
      case 'TRADE_COMPLETED':
      case 'COMPLETED':
        return P2PActivityType.tradeCompleted;
      case 'TRADE_CANCELLED':
      case 'CANCELLED':
        return P2PActivityType.tradeCancelled;
      case 'TRADE_DISPUTED':
      case 'DISPUTE_CREATED':
      case 'DISPUTED':
        return P2PActivityType.tradeDisputed;
      case 'REVIEW_SUBMITTED':
        return P2PActivityType.reviewSubmitted;
      case 'REVIEW_RECEIVED':
        return P2PActivityType.reviewReceived;
      case 'PAYMENT_METHOD_ADDED':
        return P2PActivityType.paymentMethodAdded;
      case 'PAYMENT_METHOD_UPDATED':
        return P2PActivityType.paymentMethodUpdated;
      case 'PAYMENT_METHOD_REMOVED':
        return P2PActivityType.paymentMethodRemoved;
      case 'SYSTEM_NOTIFICATION':
        return P2PActivityType.systemNotification;
      case 'WARNING_ISSUED':
        return P2PActivityType.warningIssued;
      case 'ACCOUNT_SUSPENDED':
        return P2PActivityType.accountSuspended;
      case 'ACCOUNT_REINSTATED':
        return P2PActivityType.accountReinstated;
      default:
        return P2PActivityType.other;
    }
  }

  P2PTradeStatus _parseTradeStatus(String? rawStatus) {
    final normalized = _normalizeToken(rawStatus);
    switch (normalized) {
      case 'PENDING':
      case 'PENDING_APPROVAL':
        return P2PTradeStatus.pending;
      case 'IN_PROGRESS':
      case 'ACTIVE':
        return P2PTradeStatus.inProgress;
      case 'PAYMENT_SENT':
        return P2PTradeStatus.paymentSent;
      case 'COMPLETED':
        return P2PTradeStatus.completed;
      case 'CANCELLED':
      case 'CANCELED':
        return P2PTradeStatus.cancelled;
      case 'DISPUTED':
        return P2PTradeStatus.disputed;
      case 'EXPIRED':
      case 'TIMEOUT':
        return P2PTradeStatus.expired;
      default:
        return P2PTradeStatus.pending;
    }
  }

  P2PTradeType _parseTradeType(String? rawType) {
    return _normalizeToken(rawType) == 'SELL'
        ? P2PTradeType.sell
        : P2PTradeType.buy;
  }

  String _normalizeToken(String? value) {
    final input = (value ?? '').trim();
    if (input.isEmpty) return '';
    return input.replaceAll(RegExp(r'[^A-Za-z0-9]+'), '_').toUpperCase();
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return value.cast<String, dynamic>();
    return const <String, dynamic>{};
  }

  Map<String, dynamic>? _asNullableMap(dynamic value) {
    if (value == null) return null;
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return value.cast<String, dynamic>();
    return null;
  }

  List<Map<String, dynamic>> _asListOfMap(dynamic value) {
    if (value is List) {
      return value
          .whereType<Map>()
          .map((item) => item.cast<String, dynamic>())
          .toList();
    }
    return const <Map<String, dynamic>>[];
  }

  int? _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) {
      final cleaned = value.replaceAll(RegExp(r'[^0-9\-]'), '');
      if (cleaned.isEmpty || cleaned == '-') return null;
      return int.tryParse(cleaned);
    }
    return null;
  }

  double? _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) {
      final cleaned = value.replaceAll(RegExp(r'[^0-9.\-]'), '');
      if (cleaned.isEmpty || cleaned == '-' || cleaned == '.') return null;
      return double.tryParse(cleaned);
    }
    return null;
  }

  DateTime? _parseDate(dynamic value) {
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }
}
