import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class LoginWithGoogleUseCase implements UseCase<UserEntity, GoogleLoginParams> {
  final AuthRepository repository;

  LoginWithGoogleUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(GoogleLoginParams params) async {
    return await repository.googleSignIn(idToken: params.idToken);
  }
}

class GoogleLoginParams extends Equatable {
  final String idToken;

  const GoogleLoginParams({required this.idToken});

  @override
  List<Object?> get props => [idToken];
}
