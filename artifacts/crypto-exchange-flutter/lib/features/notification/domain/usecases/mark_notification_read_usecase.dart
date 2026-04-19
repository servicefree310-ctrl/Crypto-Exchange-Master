import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/notification_repository.dart';

@injectable
class MarkNotificationReadUseCase
    implements UseCase<void, MarkNotificationReadParams> {
  final NotificationRepository repository;

  const MarkNotificationReadUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(MarkNotificationReadParams params) async {
    if (params.notificationId.isEmpty) {
      return Left(ValidationFailure('Notification ID cannot be empty'));
    }

    return await repository.markNotificationAsRead(params.notificationId);
  }
}

class MarkNotificationReadParams extends Equatable {
  final String notificationId;

  const MarkNotificationReadParams({required this.notificationId});

  @override
  List<Object> get props => [notificationId];
}
