import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/notification_repository.dart';

@injectable
class MarkAllNotificationsReadUseCase implements UseCase<void, NoParams> {
  final NotificationRepository repository;

  const MarkAllNotificationsReadUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await repository.markAllNotificationsAsRead();
  }
}
