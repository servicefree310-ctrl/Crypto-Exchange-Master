import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/wallet_repository.dart';

class GetWalletPerformanceUseCase implements UseCase<Map<String, dynamic>, NoParams> {
  final WalletRepository repository;

  GetWalletPerformanceUseCase(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(NoParams params) async {
    return await repository.getWalletPerformance();
  }
} 