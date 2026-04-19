import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/wallet_entity.dart';
import '../repositories/wallet_repository.dart';

class GetWalletsUseCase implements UseCase<Map<WalletType, List<WalletEntity>>, NoParams> {
  final WalletRepository repository;

  GetWalletsUseCase(this.repository);

  @override
  Future<Either<Failure, Map<WalletType, List<WalletEntity>>>> call(NoParams params) async {
    return await repository.getWallets();
  }
}

// These classes have been moved to their own files to avoid ambiguous imports

class RefreshWalletsUseCase implements UseCase<Map<WalletType, List<WalletEntity>>, NoParams> {
  final WalletRepository repository;

  RefreshWalletsUseCase(this.repository);

  @override
  Future<Either<Failure, Map<WalletType, List<WalletEntity>>>> call(NoParams params) async {
    return await repository.refreshWallets();
  }
} 