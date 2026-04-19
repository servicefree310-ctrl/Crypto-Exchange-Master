import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/transfer_option_entity.dart';
import '../repositories/transfer_repository.dart';

@injectable
class GetTransferOptionsUseCase
    implements UseCase<List<TransferOptionEntity>, NoParams> {
  final TransferRepository _repository;

  const GetTransferOptionsUseCase(this._repository);

  @override
  Future<Either<Failure, List<TransferOptionEntity>>> call(
      NoParams params) async {
    return await _repository.getTransferOptions();
  }
}
