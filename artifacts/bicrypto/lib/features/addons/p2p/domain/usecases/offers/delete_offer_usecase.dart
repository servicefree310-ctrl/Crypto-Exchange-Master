import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../../../../../../core/errors/failures.dart';
import '../../../../../../../../../core/usecases/usecase.dart';
import '../../repositories/p2p_offers_repository.dart';

@injectable
class DeleteOfferUseCase implements UseCase<void, DeleteOfferParams> {
  final P2POffersRepository _repository;

  const DeleteOfferUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(DeleteOfferParams params) async {
    // Input validation
    final validation = _validateParams(params);
    if (validation != null) return Left(validation);

    return await _repository.deleteOffer(params.offerId);
  }

  ValidationFailure? _validateParams(DeleteOfferParams params) {
    // Validate offer ID
    if (params.offerId.isEmpty) {
      return const ValidationFailure('Offer ID is required');
    }

    // Basic UUID format validation
    if (params.offerId.length < 10) {
      return const ValidationFailure('Invalid offer ID format');
    }

    // Validate reason if force delete
    if (params.forceDelete &&
        (params.reason == null || params.reason!.isEmpty)) {
      return const ValidationFailure(
          'Reason is required for permanent deletion');
    }

    return null;
  }
}

class DeleteOfferParams {
  final String offerId;
  final bool forceDelete; // Permanent delete vs soft delete/deactivate
  final String? reason; // Required for force delete, optional for soft delete
  final bool validateOwnership; // Check if user owns the offer

  const DeleteOfferParams({
    required this.offerId,
    this.forceDelete = false,
    this.reason,
    this.validateOwnership = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'offerId': offerId,
      'forceDelete': forceDelete,
      'reason': reason,
      'validateOwnership': validateOwnership,
    };
  }
}
