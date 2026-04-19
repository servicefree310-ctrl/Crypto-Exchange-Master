import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../../../../../core/errors/failures.dart';
import '../../../../../../../../core/usecases/usecase.dart';
import '../../entities/p2p_offer_entity.dart';
import '../../entities/p2p_params.dart';
import '../../repositories/p2p_offers_repository.dart';

@injectable
class GetPopularOffersUseCase
    implements UseCase<List<P2POfferEntity>, GetPopularOffersParams> {
  final P2POffersRepository _repository;

  const GetPopularOffersUseCase(this._repository);

  @override
  Future<Either<Failure, List<P2POfferEntity>>> call(
      GetPopularOffersParams params) async {
    // Input validation
    final validation = _validateParams(params);
    if (validation != null) return Left(validation);

    return await _repository.getPopularOffers(limit: params.limit);
  }

  ValidationFailure? _validateParams(GetPopularOffersParams params) {
    // Validate limit
    if (params.limit <= 0) {
      return const ValidationFailure('Limit must be greater than 0');
    }

    if (params.limit > 100) {
      return const ValidationFailure('Limit cannot exceed 100');
    }

    return null;
  }
}
