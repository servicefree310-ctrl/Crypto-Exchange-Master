import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../entities/support_ticket_entity.dart';
import '../entities/create_ticket_params.dart';
import '../repositories/support_repository.dart';

@injectable
class CreateSupportTicketUseCase {
  const CreateSupportTicketUseCase(this._repository);

  final SupportRepository _repository;

  Future<Either<Failure, SupportTicketEntity>> call(
    CreateTicketParams params,
  ) async {
    return await _repository.createSupportTicket(params);
  }
}
