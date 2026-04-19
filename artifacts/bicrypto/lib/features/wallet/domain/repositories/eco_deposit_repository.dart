import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/eco_token_entity.dart';
import '../entities/eco_deposit_address_entity.dart';
import '../entities/eco_deposit_verification_entity.dart';

abstract class EcoDepositRepository {
  // Currency & Token Management
  Future<Either<Failure, List<String>>> getEcoCurrencies();
  Future<Either<Failure, List<EcoTokenEntity>>> getEcoTokens(String currency);

  // Address Generation by Contract Type
  Future<Either<Failure, EcoDepositAddressEntity>> generatePermitAddress(
    String currency,
    String chain,
  );
  Future<Either<Failure, EcoDepositAddressEntity>> generateNoPermitAddress(
    String currency,
    String chain,
  );
  Future<Either<Failure, EcoDepositAddressEntity>> generateNativeAddress(
    String currency,
    String chain,
  );

  // Address Management
  Future<Either<Failure, void>> unlockAddress(String address);

  // Real-time Monitoring
  Stream<EcoDepositVerificationEntity> monitorEcoDeposit();
  void startMonitoring({
    required String currency,
    required String chain,
    String? address,
  });
  void stopMonitoring();
}
