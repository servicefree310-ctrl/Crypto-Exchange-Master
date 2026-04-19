import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/notification_repository.dart';

@injectable
class DeleteNotificationUseCase
    implements UseCase<void, DeleteNotificationParams> {
  final NotificationRepository repository;

  const DeleteNotificationUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteNotificationParams params) async {
    if (params.notificationId.isEmpty) {
      return Left(ValidationFailure('Notification ID cannot be empty'));
    }

    return await repository.deleteNotification(params.notificationId);
  }
}

class DeleteNotificationParams extends Equatable {
  final String notificationId;

  const DeleteNotificationParams({required this.notificationId});

  @override
  List<Object> get props => [notificationId];
}
