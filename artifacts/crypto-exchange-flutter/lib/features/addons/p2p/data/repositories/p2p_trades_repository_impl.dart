import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/errors/failures.dart';
import '../../../../../core/network/network_info.dart';
import '../../domain/entities/p2p_dispute_entity.dart';
import '../../domain/entities/p2p_review_entity.dart';
import '../../domain/entities/p2p_trade_entity.dart';
import '../../domain/repositories/p2p_trades_repository.dart';
import '../../domain/usecases/trades/get_trades_usecase.dart';
import '../datasources/p2p_local_datasource.dart';
import '../datasources/p2p_remote_datasource.dart';

@Injectable(as: P2PTradesRepository)
class P2PTradesRepositoryImpl implements P2PTradesRepository {
  final P2PRemoteDataSource _remoteDataSource;
  final P2PLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;

  const P2PTradesRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
    this._networkInfo,
  );

  @override
  Future<Either<Failure, P2PTradesResponse>> getTrades({
    String? status,
    int? limit,
    int? offset,
    String? sortBy,
    String? sortDirection,
    bool includeStats = true,
    bool includeActivity = true,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    try {
      if (await _networkInfo.isConnected) {
        final result = await _remoteDataSource.getTrades(
          status: status,
          type: null,
          page: offset != null ? (offset / (limit ?? 10)).floor() + 1 : 1,
          perPage: limit ?? 10,
        );

        await _localDataSource.cacheTradesList(result);
        return Right(_mapTradesDashboard(result));
      }

      final cachedData = await _localDataSource.getCachedTradesList();
      if (cachedData != null) {
        return Right(_mapTradesDashboard(cachedData));
      }
      return Left(NetworkFailure('No internet connection'));
    } catch (e) {
      try {
        final cachedData = await _localDataSource.getCachedTradesList();
        if (cachedData != null) {
          return Right(_mapTradesDashboard(cachedData));
        }
      } catch (_) {}

      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, P2PTradeEntity>> getTradeById(
    String tradeId, {
    bool includeCounterparty = true,
    bool includeDispute = true,
    bool includeTimeline = true,
  }) async {
    if (!await _networkInfo.isConnected) {
      return Left(NetworkFailure('No internet connection'));
    }

    try {
      final result = await _remoteDataSource.getTradeById(tradeId);
      final trade = _mapTrade(_extractTradePayload(result));
      return Right(trade);
    } catch (e) {
      try {
        final cachedTrade = await _localDataSource.getCachedTrade(tradeId);
        if (cachedTrade is Map<String, dynamic>) {
          return Right(_mapTrade(cachedTrade));
        }
      } catch (_) {}

      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, P2PTradeEntity>> initiateTrade({
    required String offerId,
    required double amount,
    double? fiatAmount,
    required String paymentMethodId,
    String? message,
    int? autoAcceptTime,
  }) async {
    if (!await _networkInfo.isConnected) {
      return Left(NetworkFailure('No internet connection'));
    }

    try {
      final result = await _remoteDataSource.createTrade(
        offerId: offerId,
        amount: amount,
        paymentMethodId: paymentMethodId,
        notes: message,
      );

      final tradePayload = _extractTradePayload(result);
      final createdTradeId = (tradePayload['id'] ?? '').toString();

      if (createdTradeId.isNotEmpty) {
        try {
          final fullTrade =
              await _remoteDataSource.getTradeById(createdTradeId);
          return Right(_mapTrade(fullTrade));
        } catch (_) {
          // Fall back to partial payload when detail endpoint temporarily fails.
        }
      }

      return Right(_mapTrade(
        tradePayload,
        fallbackOfferId: offerId,
        fallbackAmount: amount,
      ));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> confirmTrade({
    required String tradeId,
    String? paymentReference,
    String? paymentProof,
    String? notes,
  }) async {
    if (!await _networkInfo.isConnected) {
      return Left(NetworkFailure('No internet connection'));
    }

    try {
      await _remoteDataSource.confirmTrade(tradeId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> cancelTrade({
    required String tradeId,
    required String reason,
    bool forceCancel = false,
  }) async {
    if (!await _networkInfo.isConnected) {
      return Left(NetworkFailure('No internet connection'));
    }

    try {
      await _remoteDataSource.cancelTrade(tradeId, reason);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, P2PDisputeEntity>> disputeTrade({
    required String tradeId,
    required String reason,
    required String description,
    List<String>? evidence,
    String? priority,
  }) async {
    if (!await _networkInfo.isConnected) {
      return Left(NetworkFailure('No internet connection'));
    }

    try {
      final result = await _remoteDataSource.disputeTrade(
        tradeId,
        reason,
        description,
      );

      final payload = _asMap(result['dispute'] ?? result['data'] ?? result);
      final now = DateTime.now();

      final entity = P2PDisputeEntity(
        id: (payload['id'] ?? 'dispute_${now.millisecondsSinceEpoch}')
            .toString(),
        tradeId: (payload['tradeId'] ?? tradeId).toString(),
        reportedById:
            (payload['reportedById'] ?? payload['userId'] ?? '').toString(),
        againstId:
            (payload['againstId'] ?? payload['againstUserId'] ?? '').toString(),
        reason: (payload['reason'] ?? reason).toString(),
        details: (payload['description'] ?? description).toString(),
        status: _mapDisputeStatus(payload['status']),
        priority: _mapDisputePriority(payload['priority'] ?? priority),
        filedAt: _parseDate(payload['createdAt']) ?? now,
        updatedAt: _parseDate(payload['updatedAt']) ?? now,
      );

      return Right(entity);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> releaseEscrow({
    required String tradeId,
    String? releaseReason,
    bool partialRelease = false,
    double? releaseAmount,
  }) async {
    if (!await _networkInfo.isConnected) {
      return Left(NetworkFailure('No internet connection'));
    }

    try {
      await _remoteDataSource.releaseTrade(tradeId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, P2PReviewEntity>> reviewTrade({
    required String tradeId,
    required int communicationRating,
    required int speedRating,
    required int trustRating,
    required String comment,
    bool? isPositive,
  }) async {
    if (!await _networkInfo.isConnected) {
      return Left(NetworkFailure('No internet connection'));
    }

    try {
      final overallRating =
          (communicationRating + speedRating + trustRating) / 3.0;

      final reviewData = {
        'rating': overallRating,
        'feedback': comment,
      };

      final result = await _remoteDataSource.reviewTrade(tradeId, reviewData);
      final payload = _asMap(result['review'] ?? result['data'] ?? result);
      final now = DateTime.now();

      final review = P2PReviewEntity(
        id: (payload['id'] ?? 'review_${now.millisecondsSinceEpoch}')
            .toString(),
        tradeId: (payload['tradeId'] ?? tradeId).toString(),
        reviewerId:
            (payload['reviewerId'] ?? payload['userId'] ?? '').toString(),
        revieweeId:
            (payload['revieweeId'] ?? payload['targetUserId'] ?? '').toString(),
        rating: _toDouble(payload['rating']) ?? overallRating,
        communicationRating: communicationRating.toDouble(),
        speedRating: speedRating.toDouble(),
        trustRating: trustRating.toDouble(),
        comment:
            (payload['feedback'] ?? payload['comment'] ?? comment).toString(),
        createdAt: _parseDate(payload['createdAt']) ?? now,
        updatedAt: _parseDate(payload['updatedAt']),
      );

      return Right(review);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getTradeMessages(
    String tradeId,
  ) async {
    if (!await _networkInfo.isConnected) {
      return Left(NetworkFailure('No internet connection'));
    }

    try {
      final messages = await _remoteDataSource.getTradeMessages(tradeId);
      return Right(messages);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> sendTradeMessage({
    required String tradeId,
    required String message,
  }) async {
    if (!await _networkInfo.isConnected) {
      return Left(NetworkFailure('No internet connection'));
    }

    try {
      await _remoteDataSource.sendTradeMessage(tradeId, message);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  P2PTradesResponse _mapTradesDashboard(Map<String, dynamic> result) {
    final activeTrades = _mapTradeList(result['activeTrades']);
    final pendingTrades = _mapTradeList(result['pendingTrades']);
    final completedTrades = _mapTradeList(result['completedTrades']);
    final disputedTrades = _mapTradeList(result['disputedTrades']);
    final cancelledTrades = _mapTradeList(result['cancelledTrades']);

    // Fallback for legacy payloads that returned flat list in `data`.
    final flatTrades = _mapTradeList(result['data']);

    final allTrades = <P2PTradeEntity>[
      ...activeTrades,
      ...pendingTrades,
      ...completedTrades,
      ...disputedTrades,
      ...cancelledTrades,
      ...flatTrades,
    ];

    final mappedPending = pendingTrades.isNotEmpty
        ? pendingTrades
        : allTrades
            .where((trade) => trade.status == P2PTradeStatus.pending)
            .toList();
    final mappedActive = activeTrades.isNotEmpty
        ? activeTrades
        : allTrades
            .where((trade) =>
                trade.status == P2PTradeStatus.inProgress ||
                trade.status == P2PTradeStatus.paymentSent)
            .toList();
    final mappedCompleted = completedTrades.isNotEmpty
        ? completedTrades
        : allTrades
            .where((trade) => trade.status == P2PTradeStatus.completed)
            .toList();
    final mappedDisputed = disputedTrades.isNotEmpty
        ? disputedTrades
        : allTrades
            .where((trade) => trade.status == P2PTradeStatus.disputed)
            .toList();

    final stats = _asMap(result['tradeStats'] ?? result['stats']);
    final activityRaw = result['recentActivity'] ?? result['tradingActivity'];

    return P2PTradesResponse(
      tradeStats: P2PTradeStats(
        activeCount: _toInt(stats['activeCount']) ?? mappedActive.length,
        completedCount:
            _toInt(stats['completedCount']) ?? mappedCompleted.length,
        totalVolume: _toDouble(stats['totalVolume']) ?? 0.0,
        avgCompletionTime: stats['avgCompletionTime']?.toString(),
        successRate: _toInt(stats['successRate']) ?? 0,
      ),
      recentActivity: _mapActivityList(activityRaw),
      activeTrades: mappedActive,
      pendingTrades: mappedPending,
      completedTrades: mappedCompleted,
      disputedTrades: mappedDisputed,
    );
  }

  List<P2PTradeEntity> _mapTradeList(dynamic rawList) {
    if (rawList is! List) return const <P2PTradeEntity>[];

    final mapped = <P2PTradeEntity>[];
    for (final item in rawList) {
      if (item is Map) {
        try {
          mapped.add(_mapTrade(item.cast<String, dynamic>()));
        } catch (_) {
          // Skip malformed trade entry instead of failing full response.
        }
      }
    }
    return mapped;
  }

  P2PTradeEntity _mapTrade(
    Map<String, dynamic> json, {
    String? fallbackOfferId,
    double? fallbackAmount,
  }) {
    final now = DateTime.now();

    final offer = _asNullableMap(json['offer']);
    final buyer = _asNullableMap(json['buyer']);
    final seller = _asNullableMap(json['seller']);
    final dispute = _asNullableMap(json['dispute']);
    final paymentMethodDetails = _asNullableMap(json['paymentMethodDetails']);

    final parsedTimeline = _parseTimeline(json['timeline']);

    final amount = _toDouble(json['amount']) ?? fallbackAmount ?? 0.0;
    final total = _toDouble(json['total']) ??
        _toDouble(json['fiatAmount']) ??
        _toDouble(json['fiat_amount']) ??
        0.0;

    final price =
        _toDouble(json['price']) ?? (amount > 0 ? total / amount : 0.0);

    final createdAt = _parseDate(json['createdAt'] ?? json['date']) ?? now;
    final updatedAt =
        _parseDate(json['updatedAt'] ?? json['date']) ?? createdAt;

    return P2PTradeEntity(
      id: (json['id'] ?? '').toString(),
      offerId:
          (json['offerId'] ?? offer?['id'] ?? fallbackOfferId ?? '').toString(),
      buyerId: (json['buyerId'] ?? json['buyerUserId'] ?? buyer?['id'] ?? '')
          .toString(),
      sellerId:
          (json['sellerId'] ?? json['sellerUserId'] ?? seller?['id'] ?? '')
              .toString(),
      type: _mapTradeType(json['type'] ?? json['tradeType']),
      currency:
          (json['currency'] ?? json['coin'] ?? offer?['currency'] ?? 'BTC')
              .toString(),
      amount: amount,
      price: price,
      fiatAmount: total,
      status: _mapTradeStatus(json['status']),
      paymentMethod:
          (paymentMethodDetails?['name'] ?? json['paymentMethod'])?.toString(),
      paymentDetails: _asNullableMap(json['paymentDetails']),
      disputeReason: json['disputeReason']?.toString(),
      disputeDetails: json['disputeDetails']?.toString(),
      completedAt: _parseDate(json['completedAt']),
      cancelledAt: _parseDate(json['cancelledAt']),
      disputedAt: _parseDate(json['disputedAt']),
      expiresAt: _parseDate(json['expiresAt']),
      buyer: buyer,
      seller: seller,
      offer: offer,
      dispute: dispute,
      messages: _parseMessages(json['messages']),
      timeline: parsedTimeline,
      escrowAmount: _toDouble(json['escrowAmount']),
      escrowFee: _toDouble(json['escrowFee']),
      paymentReference: json['paymentReference']?.toString(),
      paymentProof: _toStringList(json['paymentProof']),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  Map<String, dynamic> _extractTradePayload(Map<String, dynamic> response) {
    return _asMap(response['trade'] ?? response['data'] ?? response);
  }

  List<P2PActivityLog> _mapActivityList(dynamic raw) {
    if (raw is! List) return const <P2PActivityLog>[];

    return raw.whereType<Map>().map((item) {
      final json = item.cast<String, dynamic>();
      final timestamp = _parseDate(json['time'] ?? json['createdAt']);
      return P2PActivityLog(
        id: (json['id'] ?? '').toString(),
        type: (json['type'] ?? 'TRADE_UPDATE').toString(),
        tradeId: json['tradeId']?.toString(),
        message: (json['message'] ?? '').toString(),
        time: timestamp ?? DateTime.now(),
      );
    }).toList();
  }

  P2PTradeStatus _mapTradeStatus(dynamic status) {
    final normalized = _normalizeToken(status);
    switch (normalized) {
      case 'PENDING':
      case 'PENDING_APPROVAL':
        return P2PTradeStatus.pending;
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
      case 'IN_PROGRESS':
      case 'ACTIVE':
        return P2PTradeStatus.inProgress;
      default:
        return P2PTradeStatus.pending;
    }
  }

  P2PTradeType _mapTradeType(dynamic type) {
    final normalized = _normalizeToken(type);
    return normalized == 'SELL' ? P2PTradeType.sell : P2PTradeType.buy;
  }

  P2PDisputeStatus _mapDisputeStatus(dynamic status) {
    final normalized = _normalizeToken(status);
    switch (normalized) {
      case 'IN_PROGRESS':
        return P2PDisputeStatus.inProgress;
      case 'RESOLVED':
        return P2PDisputeStatus.resolved;
      case 'CLOSED':
        return P2PDisputeStatus.closed;
      case 'ESCALATED':
        return P2PDisputeStatus.escalated;
      case 'PENDING':
      default:
        return P2PDisputeStatus.pending;
    }
  }

  P2PDisputePriority _mapDisputePriority(dynamic priority) {
    final normalized = _normalizeToken(priority);
    switch (normalized) {
      case 'LOW':
        return P2PDisputePriority.low;
      case 'HIGH':
        return P2PDisputePriority.high;
      case 'URGENT':
        return P2PDisputePriority.urgent;
      case 'MEDIUM':
      default:
        return P2PDisputePriority.medium;
    }
  }

  DateTime? _parseDate(dynamic value) {
    if (value is DateTime) return value;
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
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

  List<String>? _toStringList(dynamic value) {
    if (value is List) {
      return value.map((item) => item.toString()).toList();
    }
    return null;
  }

  List<Map<String, dynamic>>? _parseMessages(dynamic value) {
    if (value is List) {
      return value
          .whereType<Map>()
          .map((item) => item.cast<String, dynamic>())
          .toList();
    }
    return null;
  }

  List<Map<String, dynamic>>? _parseTimeline(dynamic value) {
    if (value == null) return null;

    if (value is String && value.isNotEmpty) {
      try {
        final decoded = jsonDecode(value);
        if (decoded is List) {
          return decoded
              .whereType<Map>()
              .map((item) => item.cast<String, dynamic>())
              .toList();
        }
      } catch (_) {
        return null;
      }
    }

    if (value is List) {
      return value
          .whereType<Map>()
          .map((item) => item.cast<String, dynamic>())
          .toList();
    }

    return null;
  }

  String _normalizeToken(dynamic value) {
    final input = (value ?? '').toString().trim();
    if (input.isEmpty) return '';
    return input.replaceAll(RegExp(r'[^A-Za-z0-9]+'), '_').toUpperCase();
  }
}
