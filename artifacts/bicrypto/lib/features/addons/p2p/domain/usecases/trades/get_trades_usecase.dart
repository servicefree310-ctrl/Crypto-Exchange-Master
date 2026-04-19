import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../../../../../../core/usecases/usecase.dart';
import '../../../../../../../../../core/errors/failures.dart';
import '../../entities/p2p_trade_entity.dart';
import '../../repositories/p2p_trades_repository.dart';

/// Use case for retrieving user's P2P trades with dashboard data
///
/// Matches v5 backend: GET /api/ext/p2p/trade
/// - Returns trade stats (active, completed, total volume, success rate)
/// - Provides recent activity logs
/// - Categorizes trades (active, pending, completed, disputed)
/// - Calculates completion metrics and average response time
@injectable
class GetTradesUseCase implements UseCase<P2PTradesResponse, GetTradesParams> {
  const GetTradesUseCase(this._repository);

  final P2PTradesRepository _repository;

  @override
  Future<Either<Failure, P2PTradesResponse>> call(
      GetTradesParams params) async {
    // 1. Validate input parameters
    final validation = _validateParams(params);
    if (validation != null) return Left(validation);

    // 2. Execute repository call
    return await _repository.getTrades(
      status: params.status,
      limit: params.limit,
      offset: params.offset,
      sortBy: params.sortBy,
      sortDirection: params.sortDirection,
      includeStats: params.includeStats,
      includeActivity: params.includeActivity,
      dateFrom: params.dateFrom,
      dateTo: params.dateTo,
    );
  }

  ValidationFailure? _validateParams(GetTradesParams params) {
    // Validate limit
    if (params.limit != null && (params.limit! < 1 || params.limit! > 100)) {
      return ValidationFailure('Limit must be between 1 and 100');
    }

    // Validate offset
    if (params.offset != null && params.offset! < 0) {
      return ValidationFailure('Offset must be non-negative');
    }

    // Validate sort by field
    if (params.sortBy != null && !_isValidSortField(params.sortBy!)) {
      return ValidationFailure('Invalid sort field: ${params.sortBy}');
    }

    // Validate sort direction
    if (params.sortDirection != null &&
        !['ASC', 'DESC'].contains(params.sortDirection!.toUpperCase())) {
      return ValidationFailure('Sort direction must be ASC or DESC');
    }

    // Validate status filter
    if (params.status != null && !_isValidStatus(params.status!)) {
      return ValidationFailure('Invalid trade status: ${params.status}');
    }

    // Validate date range
    if (params.dateFrom != null && params.dateTo != null) {
      if (params.dateFrom!.isAfter(params.dateTo!)) {
        return ValidationFailure('Date from must be before date to');
      }
    }

    return null;
  }

  bool _isValidSortField(String field) {
    const validFields = [
      'createdAt',
      'updatedAt',
      'amount',
      'fiatAmount',
      'price',
      'status',
    ];
    return validFields.contains(field);
  }

  bool _isValidStatus(String status) {
    const validStatuses = [
      'PENDING',
      'IN_PROGRESS',
      'PAYMENT_SENT',
      'COMPLETED',
      'CANCELLED',
      'DISPUTED',
      'TIMEOUT',
    ];
    return validStatuses.contains(status);
  }
}

/// Parameters for getting user's trades
class GetTradesParams {
  const GetTradesParams({
    this.status,
    this.limit,
    this.offset,
    this.sortBy,
    this.sortDirection,
    this.includeStats = true,
    this.includeActivity = true,
    this.dateFrom,
    this.dateTo,
  });

  /// Filter by trade status
  final String? status;

  /// Maximum number of trades to return (default: 20)
  final int? limit;

  /// Number of trades to skip (for pagination)
  final int? offset;

  /// Field to sort by (default: 'updatedAt')
  final String? sortBy;

  /// Sort direction: 'ASC' or 'DESC' (default: 'DESC')
  final String? sortDirection;

  /// Include trade statistics
  final bool includeStats;

  /// Include recent activity logs
  final bool includeActivity;

  /// Filter trades from this date
  final DateTime? dateFrom;

  /// Filter trades to this date
  final DateTime? dateTo;
}

/// Response containing user's trade data and dashboard metrics
class P2PTradesResponse {
  const P2PTradesResponse({
    required this.tradeStats,
    required this.recentActivity,
    required this.activeTrades,
    required this.pendingTrades,
    required this.completedTrades,
    required this.disputedTrades,
  });

  /// Trade statistics and metrics
  final P2PTradeStats tradeStats;

  /// Recent activity logs
  final List<P2PActivityLog> recentActivity;

  /// Currently active trades
  final List<P2PTradeEntity> activeTrades;

  /// Pending trades awaiting action
  final List<P2PTradeEntity> pendingTrades;

  /// Completed trades
  final List<P2PTradeEntity> completedTrades;

  /// Disputed trades
  final List<P2PTradeEntity> disputedTrades;
}

/// Trade statistics for dashboard
class P2PTradeStats {
  const P2PTradeStats({
    required this.activeCount,
    required this.completedCount,
    required this.totalVolume,
    this.avgCompletionTime,
    required this.successRate,
  });

  /// Number of active trades
  final int activeCount;

  /// Number of completed trades
  final int completedCount;

  /// Total trading volume
  final double totalVolume;

  /// Average completion time (formatted string like "2h 30m")
  final String? avgCompletionTime;

  /// Success rate percentage (0-100)
  final int successRate;
}

/// Activity log entry
class P2PActivityLog {
  const P2PActivityLog({
    required this.id,
    required this.type,
    this.tradeId,
    required this.message,
    required this.time,
  });

  /// Activity log ID
  final String id;

  /// Activity type
  final String type;

  /// Related trade ID (if applicable)
  final String? tradeId;

  /// Activity message
  final String message;

  /// Activity timestamp
  final DateTime time;
}
