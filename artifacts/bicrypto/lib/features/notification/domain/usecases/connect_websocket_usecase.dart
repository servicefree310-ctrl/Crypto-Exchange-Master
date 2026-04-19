import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/notification_repository.dart';

@injectable
class ConnectWebSocketUseCase implements UseCase<void, ConnectWebSocketParams> {
  final NotificationRepository repository;

  const ConnectWebSocketUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(ConnectWebSocketParams params) async {
    if (params.userId.isEmpty) {
      return Left(ValidationFailure('User ID cannot be empty'));
    }

    return await repository.connectWebSocket(params.userId);
  }
}

class ConnectWebSocketParams extends Equatable {
  final String userId;

  const ConnectWebSocketParams({required this.userId});

  @override
  List<Object> get props => [userId];
}
