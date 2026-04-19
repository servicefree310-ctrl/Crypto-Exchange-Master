import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/wallet_entity.dart';
import '../repositories/wallet_repository.dart';

class GetWalletParams extends Equatable {
  final WalletType type;
  final String currency;

  const GetWalletParams({
    required this.type,
    required this.currency,
  });

  @override
  List<Object> get props => [type, currency];
}

class GetWalletUseCase implements UseCase<WalletEntity, GetWalletParams> {
  final WalletRepository repository;

  GetWalletUseCase(this.repository);

  @override
  Future<Either<Failure, WalletEntity>> call(GetWalletParams params) async {
    return await repository.getWallet(params.type, params.currency);
  }
}
