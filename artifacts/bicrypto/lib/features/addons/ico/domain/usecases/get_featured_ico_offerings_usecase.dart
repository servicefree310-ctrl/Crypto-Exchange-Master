import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/errors/failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../entities/ico_offering_entity.dart';
import '../repositories/ico_repository.dart';

@injectable
class GetFeaturedIcoOfferingsUseCase
    implements UseCase<List<IcoOfferingEntity>, NoParams> {
  const GetFeaturedIcoOfferingsUseCase(this._repository);

  final IcoRepository _repository;

  @override
  Future<Either<Failure, List<IcoOfferingEntity>>> call(NoParams params) {
    return _repository.getFeaturedOfferings();
  }
}
