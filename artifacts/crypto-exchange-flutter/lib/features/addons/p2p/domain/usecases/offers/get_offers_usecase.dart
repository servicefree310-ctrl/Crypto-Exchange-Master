import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../../../core/errors/failures.dart';
import '../../../../../../core/usecases/usecase.dart';
import '../../entities/p2p_offers_response.dart';
import '../../entities/p2p_params.dart';
import '../../repositories/p2p_offers_repository.dart';

@injectable
class GetOffersUseCase implements UseCase<P2POffersResponse, GetOffersParams> {
  final P2POffersRepository _repository;

  const GetOffersUseCase(this._repository);

  @override
  Future<Either<Failure, P2POffersResponse>> call(
      GetOffersParams params) async {
    // Input validation
    final validation = _validateParams(params);
    if (validation != null) return Left(validation);

    return await _repository.getOffers(params);
  }

  ValidationFailure? _validateParams(GetOffersParams params) {
    // Validate page and perPage
    if (params.page != null && params.page! < 1) {
      return const ValidationFailure('Page must be greater than 0');
    }

    if (params.perPage != null &&
        (params.perPage! < 1 || params.perPage! > 100)) {
      return const ValidationFailure('PerPage must be between 1 and 100');
    }

    // Validate amount range
    if (params.minAmount != null && params.maxAmount != null) {
      if (params.minAmount! > params.maxAmount!) {
        return const ValidationFailure(
            'Min amount cannot be greater than max amount');
      }
    }

    // Validate price range
    if (params.minPrice != null && params.maxPrice != null) {
      if (params.minPrice! > params.maxPrice!) {
        return const ValidationFailure(
            'Min price cannot be greater than max price');
      }
    }

    // Validate sort field
    if (params.sortField != null) {
      final validSortFields = [
        'createdAt',
        'updatedAt',
        'priceConfig.finalPrice',
        'amountConfig.total',
        'views',
        'user.completionRate'
      ];
      if (!validSortFields.contains(params.sortField)) {
        return const ValidationFailure('Invalid sort field');
      }
    }

    return null;
  }
}
