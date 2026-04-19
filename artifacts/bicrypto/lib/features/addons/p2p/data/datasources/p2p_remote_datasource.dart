import 'dart:convert';
import 'dart:developer' as dev;

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/constants/api_constants.dart';
import '../../../../../core/errors/exceptions.dart';
import '../../../../../core/network/api_client.dart';

abstract class P2PRemoteDataSource {
  // Offers
  Future<Map<String, dynamic>> getOffers({
    String? type,
    String? currency,
    String? walletType,
    double? amount,
    String? paymentMethod,
    String? location,
    String? sortField,
    String? sortOrder,
    int? page,
    int? perPage,
  });

  Future<Map<String, dynamic>> createOffer(Map<String, dynamic> offerData);
  Future<Map<String, dynamic>> getOfferById(String id);
  Future<Map<String, dynamic>> updateOffer(String id, Map<String, dynamic> data);
  Future<void> deleteOffer(String id);
  Future<List<Map<String, dynamic>>> getPopularOffers({String? currency});

  // Trades
  Future<Map<String, dynamic>> getTrades({
    String? status,
    String? type,
    int? page,
    int? perPage,
  });

  Future<Map<String, dynamic>> getTradeById(String id);
  Future<Map<String, dynamic>> createTrade({
    required String offerId,
    required double amount,
    required String paymentMethodId,
    String? notes,
  });
  Future<Map<String, dynamic>> confirmTrade(String tradeId);
  Future<Map<String, dynamic>> cancelTrade(String tradeId, String reason);
  Future<Map<String, dynamic>> releaseTrade(String tradeId);
  Future<Map<String, dynamic>> disputeTrade(
    String tradeId,
    String reason,
    String description,
  );
  Future<Map<String, dynamic>> reviewTrade(
    String id,
    Map<String, dynamic> review,
  );
  Future<List<Map<String, dynamic>>> getTradeMessages(String tradeId);
  Future<Map<String, dynamic>> sendTradeMessage(String tradeId, String message);

  // Payment Methods
  Future<List<Map<String, dynamic>>> getPaymentMethods();
  Future<Map<String, dynamic>> createPaymentMethod(Map<String, dynamic> data);
  Future<Map<String, dynamic>> updatePaymentMethod(
    String id,
    Map<String, dynamic> data,
  );
  Future<void> deletePaymentMethod(String id);

  // Market Data
  Future<Map<String, dynamic>> getMarketStats();
  Future<List<Map<String, dynamic>>> getTopMarkets();
  Future<List<Map<String, dynamic>>> getMarketHighlights();

  // Dashboard
  Future<Map<String, dynamic>> getDashboardData();
  Future<Map<String, dynamic>> getDashboardStats();
  Future<List<Map<String, dynamic>>> getTradingActivity({
    int limit = 10,
    int offset = 0,
    String? type,
  });
  Future<Map<String, dynamic>> getPortfolioData();

  // Reviews
  Future<Map<String, dynamic>> getReviews({
    String? reviewerId,
    String? revieweeId,
    String? tradeId,
    double? minRating,
    double? maxRating,
    int page = 1,
    int perPage = 20,
    String sortBy = 'createdAt',
    String sortOrder = 'desc',
  });

  Future<Map<String, dynamic>> getUserReviews({
    required String userId,
    bool includeGiven = true,
    bool includeReceived = true,
    int limit = 20,
  });

  // Guided Matching
  Future<Map<String, dynamic>> submitGuidedMatching(
    Map<String, dynamic> criteria,
  );
  Future<Map<String, dynamic>> findMatches(Map<String, dynamic> criteria);
  Future<Map<String, dynamic>> comparePrices(Map<String, dynamic> criteria);
}

@Injectable(as: P2PRemoteDataSource)
class P2PRemoteDataSourceImpl implements P2PRemoteDataSource {
  final ApiClient _apiClient;

  P2PRemoteDataSourceImpl(this._apiClient);

  Map<String, dynamic> _asMap(dynamic data, {String fallbackKey = 'data'}) {
    if (data is Map<String, dynamic>) {
      return data;
    }
    if (data is Map) {
      return data.cast<String, dynamic>();
    }
    return {fallbackKey: data};
  }

  List<Map<String, dynamic>> _asListOfMap(dynamic data) {
    if (data is List) {
      return data
          .whereType<Map>()
          .map((item) => item.cast<String, dynamic>())
          .toList();
    }
    return const <Map<String, dynamic>>[];
  }

  @override
  Future<Map<String, dynamic>> getOffers({
    String? type,
    String? currency,
    String? walletType,
    double? amount,
    String? paymentMethod,
    String? location,
    String? sortField,
    String? sortOrder,
    int? page,
    int? perPage,
  }) async {
    try {
      final queryParams = <String, dynamic>{};

      if (type != null) queryParams['type'] = type;
      if (currency != null) queryParams['currency'] = currency;
      if (walletType != null) queryParams['walletType'] = walletType;
      if (amount != null) queryParams['amount'] = amount.toString();
      if (paymentMethod != null) queryParams['paymentMethod'] = paymentMethod;
      if (location != null) queryParams['location'] = location;
      if (sortField != null) queryParams['sortField'] = sortField;
      if (sortOrder != null) queryParams['sortOrder'] = sortOrder;
      if (page != null) queryParams['page'] = page.toString();
      if (perPage != null) queryParams['perPage'] = perPage.toString();

      final response = await _apiClient.get(
        ApiConstants.p2pOffers,
        queryParameters: queryParams,
      );

      return _asMap(response.data);
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?['message'] ?? 'Failed to get offers',
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> createOffer(Map<String, dynamic> offerData) async {
    try {
      dev.log('🌐 REMOTE DATA SOURCE: createOffer called');
      dev.log('🎯 REMOTE DATA SOURCE: Endpoint: ${ApiConstants.p2pCreateOffer}');
      dev.log('📦 REMOTE DATA SOURCE: Payload being sent:');
      dev.log(JsonEncoder.withIndent('  ').convert(offerData));

      final response = await _apiClient.post(
        ApiConstants.p2pCreateOffer,
        data: offerData,
      );

      return _asMap(response.data);
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?['message'] ?? 'Failed to create offer',
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> getOfferById(String id) async {
    try {
      final response = await _apiClient.get('${ApiConstants.p2pOfferById}/$id');
      return _asMap(response.data);
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?['message'] ?? 'Failed to get offer',
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> updateOffer(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _apiClient.put(
        '${ApiConstants.p2pUpdateOffer}/$id',
        data: data,
      );
      return _asMap(response.data);
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?['message'] ?? 'Failed to update offer',
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> deleteOffer(String id) async {
    try {
      await _apiClient.delete('${ApiConstants.p2pDeleteOffer}/$id');
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?['message'] ?? 'Failed to delete offer',
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getPopularOffers({String? currency}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (currency != null) queryParams['currency'] = currency;

      final response = await _apiClient.get(
        ApiConstants.p2pPopularOffers,
        queryParameters: queryParams,
      );

      final data = response.data;
      if (data is Map && data['data'] is List) {
        return _asListOfMap(data['data']);
      }
      return _asListOfMap(data);
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?['message'] ?? 'Failed to get popular offers',
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> getTrades({
    String? status,
    String? type,
    int? page,
    int? perPage,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (status != null) queryParams['status'] = status;
      if (type != null) queryParams['type'] = type;
      if (page != null) queryParams['page'] = page.toString();
      if (perPage != null) queryParams['perPage'] = perPage.toString();

      final response = await _apiClient.get(
        ApiConstants.p2pTrades,
        queryParameters: queryParams,
      );

      return _asMap(response.data);
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?['message'] ?? 'Failed to get trades',
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> getTradeById(String id) async {
    try {
      final response = await _apiClient.get('${ApiConstants.p2pTradeById}/$id');
      return _asMap(response.data);
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?['message'] ?? 'Failed to get trade',
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> createTrade({
    required String offerId,
    required double amount,
    required String paymentMethodId,
    String? notes,
  }) async {
    try {
      final response = await _apiClient.post(
        '${ApiConstants.p2pOfferById}/$offerId/initiate-trade',
        data: {
          'amount': amount,
          'paymentMethodId': paymentMethodId,
          if (notes != null) 'message': notes,
        },
      );

      return _asMap(response.data);
    } catch (e) {
      throw ServerException('Failed to create trade: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> confirmTrade(String tradeId) async {
    try {
      final response = await _apiClient.post(
        '${ApiConstants.p2pConfirmTrade}/$tradeId/confirm',
      );
      return _asMap(response.data);
    } catch (e) {
      throw ServerException('Failed to confirm trade: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> cancelTrade(String tradeId, String reason) async {
    try {
      final response = await _apiClient.post(
        '${ApiConstants.p2pCancelTrade}/$tradeId/cancel',
        data: {'reason': reason},
      );
      return _asMap(response.data);
    } catch (e) {
      throw ServerException('Failed to cancel trade: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> releaseTrade(String tradeId) async {
    try {
      final response = await _apiClient.post(
        '${ApiConstants.p2pReleaseEscrow}/$tradeId/release',
      );
      return _asMap(response.data);
    } catch (e) {
      throw ServerException('Failed to release trade: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> disputeTrade(
    String tradeId,
    String reason,
    String description,
  ) async {
    try {
      final response = await _apiClient.post(
        '${ApiConstants.p2pDisputeTrade}/$tradeId/dispute',
        data: {
          'reason': reason,
          'description': description,
        },
      );
      return _asMap(response.data);
    } catch (e) {
      throw ServerException('Failed to dispute trade: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> reviewTrade(
    String id,
    Map<String, dynamic> review,
  ) async {
    try {
      final response = await _apiClient.post(
        '${ApiConstants.p2pReviewTrade}/$id/review',
        data: review,
      );
      return _asMap(response.data);
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?['message'] ?? 'Failed to review trade',
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getTradeMessages(String tradeId) async {
    try {
      final response = await _apiClient.get(
        '${ApiConstants.p2pTradeMessages}/$tradeId/message',
      );

      final data = response.data;
      if (data is Map && data['data'] is List) {
        return _asListOfMap(data['data']);
      }
      return _asListOfMap(data);
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?['message'] ?? 'Failed to fetch trade messages',
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> sendTradeMessage(
    String tradeId,
    String message,
  ) async {
    try {
      final response = await _apiClient.post(
        '${ApiConstants.p2pSendMessage}/$tradeId/message',
        data: {'message': message},
      );
      return _asMap(response.data);
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?['message'] ?? 'Failed to send trade message',
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getPaymentMethods() async {
    try {
      final response = await _apiClient.get(ApiConstants.p2pPaymentMethods);
      final data = response.data;

      if (data is Map && data['global'] is List) {
        final globalMethods = _asListOfMap(data['global']);
        final customMethods = _asListOfMap(data['custom']);
        return [...globalMethods, ...customMethods];
      }

      if (data is Map && data['data'] is List) {
        return _asListOfMap(data['data']);
      }

      return _asListOfMap(data);
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?['message'] ?? 'Failed to get payment methods',
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> createPaymentMethod(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.p2pCreatePaymentMethod,
        data: data,
      );
      return _asMap(response.data);
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?['message'] ?? 'Failed to create payment method',
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> updatePaymentMethod(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _apiClient.put(
        '${ApiConstants.p2pUpdatePaymentMethod}/$id',
        data: data,
      );
      return _asMap(response.data);
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?['message'] ?? 'Failed to update payment method',
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> deletePaymentMethod(String id) async {
    try {
      await _apiClient.delete('${ApiConstants.p2pDeletePaymentMethod}/$id');
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?['message'] ?? 'Failed to delete payment method',
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> getMarketStats() async {
    try {
      final response = await _apiClient.get(ApiConstants.p2pMarketStats);
      return _asMap(response.data);
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?['message'] ?? 'Failed to get market stats',
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getTopMarkets() async {
    try {
      final response = await _apiClient.get(ApiConstants.p2pMarketTop);
      final data = response.data;
      if (data is Map && data['data'] is List) {
        return _asListOfMap(data['data']);
      }
      return _asListOfMap(data);
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?['message'] ?? 'Failed to get top markets',
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getMarketHighlights() async {
    try {
      final response = await _apiClient.get(ApiConstants.p2pMarketHighlights);
      final data = response.data;
      if (data is Map && data['data'] is List) {
        return _asListOfMap(data['data']);
      }
      return _asListOfMap(data);
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?['message'] ?? 'Failed to get market highlights',
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> submitGuidedMatching(
    Map<String, dynamic> criteria,
  ) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.p2pGuidedMatching,
        data: criteria,
      );
      return _asMap(response.data);
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?['message'] ?? 'Failed to submit guided matching',
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> getDashboardData() async {
    try {
      final response = await _apiClient.get(ApiConstants.p2pDashboardData);
      return _asMap(response.data);
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?['message'] ?? 'Failed to get dashboard data',
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final response = await _apiClient.get(ApiConstants.p2pDashboardStats);
      return _asMap(response.data);
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?['message'] ?? 'Failed to get dashboard stats',
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getTradingActivity({
    int limit = 10,
    int offset = 0,
    String? type,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'limit': limit.toString(),
        'offset': offset.toString(),
      };
      if (type != null) queryParams['type'] = type;

      final response = await _apiClient.get(
        ApiConstants.p2pDashboardActivity,
        queryParameters: queryParams,
      );

      final data = response.data;
      if (data is Map && data['data'] is List) {
        return _asListOfMap(data['data']);
      }
      return _asListOfMap(data);
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?['message'] ?? 'Failed to get trading activity',
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> getPortfolioData() async {
    try {
      final response = await _apiClient.get(ApiConstants.p2pDashboardPortfolio);
      return _asMap(response.data);
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?['message'] ?? 'Failed to get portfolio data',
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> getReviews({
    String? reviewerId,
    String? revieweeId,
    String? tradeId,
    double? minRating,
    double? maxRating,
    int page = 1,
    int perPage = 20,
    String sortBy = 'createdAt',
    String sortOrder = 'desc',
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page.toString(),
        'perPage': perPage.toString(),
        'sortBy': sortBy,
        'sortOrder': sortOrder,
      };

      if (reviewerId != null) queryParams['reviewerId'] = reviewerId;
      if (revieweeId != null) queryParams['revieweeId'] = revieweeId;
      if (tradeId != null) queryParams['tradeId'] = tradeId;
      if (minRating != null) queryParams['minRating'] = minRating.toString();
      if (maxRating != null) queryParams['maxRating'] = maxRating.toString();

      final response = await _apiClient.get(
        ApiConstants.p2pReviews,
        queryParameters: queryParams,
      );

      return _asMap(response.data);
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?['message'] ?? 'Failed to get reviews',
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> getUserReviews({
    required String userId,
    bool includeGiven = true,
    bool includeReceived = true,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'userId': userId,
        'includeGiven': includeGiven.toString(),
        'includeReceived': includeReceived.toString(),
        'limit': limit.toString(),
      };

      final response = await _apiClient.get(
        ApiConstants.p2pUserReviews,
        queryParameters: queryParams,
      );

      return _asMap(response.data);
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?['message'] ?? 'Failed to get user reviews',
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> findMatches(Map<String, dynamic> criteria) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.p2pGuidedMatching,
        data: criteria,
      );
      return _asMap(response.data);
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?['message'] ?? 'Failed to find matches',
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> comparePrices(
    Map<String, dynamic> criteria,
  ) async {
    try {
      final response = await _apiClient.post(
        '${ApiConstants.p2pGuidedMatching}/compare-prices',
        data: criteria,
      );
      return _asMap(response.data);
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?['message'] ?? 'Failed to compare prices',
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
