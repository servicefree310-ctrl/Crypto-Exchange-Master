import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../entities/spot_deposit_verification_result.dart';
import '../repositories/spot_deposit_repository.dart';

class VerifySpotDepositParams extends Equatable {
  const VerifySpotDepositParams({required this.transactionId});

  final String transactionId;

  @override
  List<Object> get props => [transactionId];
}

@injectable
class VerifySpotDepositUseCase {
  const VerifySpotDepositUseCase(this._repository);

  final SpotDepositRepository _repository;

  Stream<SpotDepositVerificationResult> call(VerifySpotDepositParams params) {
    return _repository.verifySpotDeposit(params.transactionId);
  }
}
