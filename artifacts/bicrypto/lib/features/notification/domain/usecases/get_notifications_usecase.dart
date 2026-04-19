import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/notification_repository.dart';

@injectable
class GetNotificationsUseCase
    implements UseCase<NotificationsWithStats, NoParams> {
  final NotificationRepository repository;

  const GetNotificationsUseCase(this.repository);

  @override
  Future<Either<Failure, NotificationsWithStats>> call(NoParams params) async {
    return await repository.getNotifications();
  }
}
