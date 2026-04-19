import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../../../../core/errors/failures.dart';
import '../../../../../../../core/usecases/usecase.dart';
import '../../entities/p2p_offer_entity.dart';
import '../../entities/p2p_params.dart';
import '../../repositories/p2p_offers_repository.dart';

@injectable
class GetOfferByIdUseCase
    implements UseCase<P2POfferEntity, GetOfferByIdParams> {
  final P2POffersRepository _repository;

  const GetOfferByIdUseCase(this._repository);

  @override
  Future<Either<Failure, P2POfferEntity>> call(
      GetOfferByIdParams params) async {
    // Input validation
    final validation = _validateParams(params);
    if (validation != null) return Left(validation);

    return await _repository.getOfferById(params.offerId);
  }

  ValidationFailure? _validateParams(GetOfferByIdParams params) {
    // Validate offer ID
    if (params.offerId.isEmpty) {
      return const ValidationFailure('Offer ID is required');
    }

    // Basic UUID format validation (optional, backend will validate)
    if (params.offerId.length < 10) {
      return const ValidationFailure('Invalid offer ID format');
    }

    return null;
  }
}
