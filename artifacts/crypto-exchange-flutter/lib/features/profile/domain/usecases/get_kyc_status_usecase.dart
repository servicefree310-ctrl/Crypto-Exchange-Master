import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:mobile/core/errors/failures.dart';
import 'package:mobile/core/usecases/usecase.dart';
import 'package:mobile/features/profile/data/services/profile_service.dart';

/// Use case to check if the user has completed KYC
@injectable
class GetKycStatusUseCase implements UseCase<bool, NoParams> {
  final ProfileService _profileService;

  const GetKycStatusUseCase(this._profileService);

  @override
  Future<Either<Failure, bool>> call(NoParams params) async {
    try {
      final profile = _profileService.currentProfile;
      // Assuming profile.status indicates KYC status, e.g., 'VERIFIED'
      final isKycVerified = profile?.status == 'VERIFIED';
      return Right(isKycVerified);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
