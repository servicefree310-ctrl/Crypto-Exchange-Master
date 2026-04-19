import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/wallet_entity.dart';
import '../repositories/wallet_repository.dart';

class GetWalletsByTypeUseCase implements UseCase<List<WalletEntity>, WalletType> {
  final WalletRepository repository;

  GetWalletsByTypeUseCase(this.repository);

  @override
  Future<Either<Failure, List<WalletEntity>>> call(WalletType type) async {
    return await repository.getWalletsByType(type);
  }
} 