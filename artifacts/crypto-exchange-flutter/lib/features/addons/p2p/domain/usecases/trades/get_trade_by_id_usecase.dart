import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../../../../../../core/usecases/usecase.dart';
import '../../../../../../../../../core/errors/failures.dart';
import '../../entities/p2p_trade_entity.dart';
import '../../repositories/p2p_trades_repository.dart';

/// Use case for retrieving a specific P2P trade by ID
///
/// Matches v5 backend: GET /api/ext/p2p/trade/{id}
/// - Returns detailed trade data with buyer/seller info
/// - Includes dispute information if applicable
/// - Validates user has access to the trade (buyer or seller)
/// - Provides timeline/message history
@injectable
class GetTradeByIdUseCase
    implements UseCase<P2PTradeEntity, GetTradeByIdParams> {
  const GetTradeByIdUseCase(this._repository);

  final P2PTradesRepository _repository;

  @override
  Future<Either<Failure, P2PTradeEntity>> call(
      GetTradeByIdParams params) async {
    // 1. Validate input parameters
    final validation = _validateParams(params);
    if (validation != null) return Left(validation);

    // 2. Execute repository call
    return await _repository.getTradeById(
      params.tradeId,
      includeCounterparty: params.includeCounterparty,
      includeDispute: params.includeDispute,
      includeTimeline: params.includeTimeline,
    );
  }

  ValidationFailure? _validateParams(GetTradeByIdParams params) {
    // Validate trade ID format (assuming UUID)
    if (params.tradeId.isEmpty) {
      return ValidationFailure('Trade ID cannot be empty');
    }

    // Basic UUID format validation
    final uuidRegex = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
      caseSensitive: false,
    );

    if (!uuidRegex.hasMatch(params.tradeId)) {
      return ValidationFailure('Invalid trade ID format');
    }

    return null;
  }
}

/// Parameters for getting a trade by ID
class GetTradeByIdParams {
  const GetTradeByIdParams({
    required this.tradeId,
    this.includeCounterparty = true,
    this.includeDispute = true,
    this.includeTimeline = true,
  });

  /// Trade ID to retrieve
  final String tradeId;

  /// Include buyer/seller details
  final bool includeCounterparty;

  /// Include dispute information if exists
  final bool includeDispute;

  /// Include trade timeline/messages
  final bool includeTimeline;
}
