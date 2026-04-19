import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/wallet_entity.dart';
import '../repositories/wallet_repository.dart';

class GetWalletByIdUseCase implements UseCase<WalletEntity, String> {
  final WalletRepository repository;

  GetWalletByIdUseCase(this.repository);

  @override
  Future<Either<Failure, WalletEntity>> call(String walletId) async {
    return await repository.getWalletById(walletId);
  }
} 