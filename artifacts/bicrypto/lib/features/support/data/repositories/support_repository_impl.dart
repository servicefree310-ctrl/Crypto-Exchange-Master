import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/support_ticket_entity.dart';
import '../../domain/entities/create_ticket_params.dart';
import '../../domain/repositories/support_repository.dart';
import '../datasources/support_remote_datasource.dart';
import '../datasources/support_websocket_datasource.dart';

@Injectable(as: SupportRepository)
class SupportRepositoryImpl implements SupportRepository {
  const SupportRepositoryImpl(
    this._remoteDataSource,
    this._webSocketDataSource,
  );

  final SupportRemoteDataSource _remoteDataSource;
  final SupportWebSocketDataSource _webSocketDataSource;

  @override
  Future<Either<Failure, List<SupportTicketEntity>>> getSupportTickets({
    int page = 1,
    int perPage = 20,
    String? search,
    TicketStatus? status,
    TicketImportance? importance,
  }) async {
    try {
      final tickets = await _remoteDataSource.getSupportTickets(
        page: page,
        perPage: perPage,
        search: search,
        status: status,
        importance: importance,
      );
      return Right(tickets);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Server error'));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message ?? 'Network error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, SupportTicketEntity>> createSupportTicket(
      CreateTicketParams params) async {
    try {
      final ticket = await _remoteDataSource.createSupportTicket(params);
      return Right(ticket);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Server error'));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message ?? 'Network error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> replyToTicket(ReplyTicketParams params) async {
    try {
      await _remoteDataSource.replyToTicket(params);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Server error'));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message ?? 'Network error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, SupportTicketEntity>> getSupportTicket(
      String ticketId) async {
    try {
      final ticket = await _remoteDataSource.getSupportTicketById(ticketId);
      return Right(ticket);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Server error'));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message ?? 'Network error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, SupportTicketEntity>> getSupportTicketById(
      String ticketId) async {
    try {
      final ticket = await _remoteDataSource.getSupportTicketById(ticketId);
      return Right(ticket);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Server error'));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message ?? 'Network error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // Live Chat Implementation - matching v5 API exactly
  @override
  Future<Either<Failure, SupportTicketEntity>> getOrCreateLiveChat() async {
    try {
      // GET /api/user/support/chat
      final ticket = await _remoteDataSource.getOrCreateLiveChat();
      return Right(ticket);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Server error'));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message ?? 'Network error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> sendLiveChatMessage(
      SendLiveChatMessageParams params) async {
    try {
      // POST /api/user/support/chat
      await _remoteDataSource.sendLiveChatMessage(params);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Server error'));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message ?? 'Network error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> endLiveChat(String sessionId) async {
    try {
      // DELETE /api/user/support/chat
      await _remoteDataSource.endLiveChat(sessionId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Server error'));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message ?? 'Network error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<SupportTicketEntity> watchSupportTicket(String ticketId) {
    return _webSocketDataSource.watchTicket(ticketId);
  }
}
