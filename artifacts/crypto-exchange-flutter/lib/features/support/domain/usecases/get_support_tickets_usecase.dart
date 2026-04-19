import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../entities/support_ticket_entity.dart';
import '../repositories/support_repository.dart';

@injectable
class GetSupportTicketsUseCase {
  const GetSupportTicketsUseCase(this._repository);

  final SupportRepository _repository;

  Future<Either<Failure, List<SupportTicketEntity>>> call({
    int page = 1,
    int perPage = 20,
    String? search,
    TicketStatus? status,
    TicketImportance? importance,
  }) async {
    return await _repository.getSupportTickets(
      page: page,
      perPage: perPage,
      search: search,
      status: status,
      importance: importance,
    );
  }
}
