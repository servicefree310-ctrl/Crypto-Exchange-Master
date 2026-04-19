import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/support_ticket_entity.dart';
import '../../domain/entities/create_ticket_params.dart';
import '../models/support_ticket_model.dart';
import 'dart:convert';

abstract class SupportRemoteDataSource {
  Future<List<SupportTicketModel>> getSupportTickets({
    int page = 1,
    int perPage = 20,
    String? search,
    TicketStatus? status,
    TicketImportance? importance,
  });

  Future<SupportTicketModel> getSupportTicketById(String id);

  Future<SupportTicketModel> createSupportTicket(CreateTicketParams params);

  Future<SupportTicketModel> replyToTicket(ReplyTicketParams params);

  Future<SupportTicketModel> closeTicket(CloseTicketParams params);

  Future<SupportTicketModel> rateTicket(RateTicketParams params);

  Future<SupportTicketModel> getOrCreateLiveChat();

  Future<void> sendLiveChatMessage(SendLiveChatMessageParams params);

  Future<void> endLiveChat(String sessionId);
}

@Injectable(as: SupportRemoteDataSource)
class SupportRemoteDataSourceImpl implements SupportRemoteDataSource {
  const SupportRemoteDataSourceImpl(this._dioClient);

  final DioClient _dioClient;

  @override
  Future<List<SupportTicketModel>> getSupportTickets({
    int page = 1,
    int perPage = 20,
    String? search,
    TicketStatus? status,
    TicketImportance? importance,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'perPage': perPage,
      };

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      // Build advanced filter JSON expected by v5 backend
      final filter = <String, dynamic>{};
      if (status != null) {
        filter['status'] = status.name.toUpperCase();
      }
      if (importance != null) {
        filter['importance'] = importance.name.toUpperCase();
      }

      // Attach filter only when at least one criterion is provided
      if (filter.isNotEmpty) {
        queryParams['filter'] = jsonEncode(filter);
      }

      final response = await _dioClient.get(
        ApiConstants.supportTickets,
        queryParameters: queryParams,
      );

      if (response.data['items'] != null) {
        final List<dynamic> ticketList = response.data['items'];
        return ticketList
            .map((ticket) => SupportTicketModel.fromJson(ticket))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw ServerException(e.response?.data['message'] ?? 'Failed to load tickets');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<SupportTicketModel> getSupportTicketById(String id) async {
    try {
      final response = await _dioClient.get(
        '${ApiConstants.supportTicketDetail}/$id',
      );

      return SupportTicketModel.fromJson(response.data);
    } on DioException catch (e) {
      throw ServerException(e.response?.data['message'] ?? 'Failed to load ticket');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<SupportTicketModel> createSupportTicket(
    CreateTicketParams params,
  ) async {
    try {
      final response = await _dioClient.post(
        ApiConstants.supportTickets,
        data: {
          'subject': params.subject,
          'message': params.message,
          'importance': params.importance.name.toUpperCase(),
          'tags': params.tags,
        },
      );

      return SupportTicketModel.fromJson(response.data);
    } on DioException catch (e) {
      throw ServerException(e.response?.data['message'] ?? 'Failed to create ticket');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<SupportTicketModel> replyToTicket(ReplyTicketParams params) async {
    try {
      final response = await _dioClient.post(
        '${ApiConstants.supportTicketReply}/${params.ticketId}',
        data: {
          'type': params.type,
          'time': DateTime.now().toUtc().toIso8601String(),
          'userId': params.userId,
          'text': params.text,
          if (params.attachment != null && params.attachment!.isNotEmpty)
            'attachment': params.attachment,
        },
      );

      return SupportTicketModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw ServerException(e.response?.data['message'] ?? 'Failed to send reply');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<SupportTicketModel> closeTicket(CloseTicketParams params) async {
    try {
      final response = await _dioClient.put(
        '${ApiConstants.supportTicketClose}/${params.ticketId}/close',
      );

      return SupportTicketModel.fromJson(response.data);
    } on DioException catch (e) {
      throw ServerException(e.response?.data['message'] ?? 'Failed to close ticket');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<SupportTicketModel> rateTicket(RateTicketParams params) async {
    try {
      final response = await _dioClient.put(
        '${ApiConstants.supportTicketReview}/${params.ticketId}/review',
        data: {
          'satisfaction': params.satisfaction,
        },
      );

      return SupportTicketModel.fromJson(response.data);
    } on DioException catch (e) {
      throw ServerException(e.response?.data['message'] ?? 'Failed to rate ticket');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<SupportTicketModel> getOrCreateLiveChat() async {
    try {
      final response = await _dioClient.get(ApiConstants.supportLiveChat);

      return SupportTicketModel.fromJson(response.data);
    } on DioException catch (e) {
      throw ServerException(e.response?.data['message'] ?? 'Failed to start live chat');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> sendLiveChatMessage(SendLiveChatMessageParams params) async {
    try {
      await _dioClient.post(
        ApiConstants.supportLiveChat,
        data: {
          'sessionId': params.sessionId,
          'content': params.content,
          'sender': params.sender,
        },
      );
    } on DioException catch (e) {
      throw ServerException(e.response?.data['message'] ?? 'Failed to send message');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> endLiveChat(String sessionId) async {
    try {
      await _dioClient.delete(
        ApiConstants.supportLiveChat,
        data: {'sessionId': sessionId},
      );
    } on DioException catch (e) {
      throw ServerException(e.response?.data['message'] ?? 'Failed to end chat');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
