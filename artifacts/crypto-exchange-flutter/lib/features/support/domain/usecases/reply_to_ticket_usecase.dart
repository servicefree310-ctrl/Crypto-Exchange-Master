import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../entities/create_ticket_params.dart';
import '../repositories/support_repository.dart';

@injectable
class ReplyToTicketUseCase {
  const ReplyToTicketUseCase(this._repository);

  final SupportRepository _repository;

  Future<Either<Failure, void>> call(ReplyTicketParams params) async {
    return await _repository.replyToTicket(params);
  }
}
