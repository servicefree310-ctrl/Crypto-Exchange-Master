import 'dart:developer' as dev;

import 'package:injectable/injectable.dart';
import '../../../../../core/constants/api_constants.dart';
import '../../../../../core/network/dio_client.dart';
import '../models/ico_offering_model.dart';
import '../models/ico_portfolio_model.dart';
import '../models/ico_transaction_model.dart';
import '../models/portfolio_performance_point_model.dart';
import '../models/ico_blockchain_model.dart';
import '../models/ico_token_type_model.dart';
import '../models/ico_launch_plan_model.dart';
import '../models/ico_stats_model.dart';

abstract class IcoRemoteDataSource {
  Future<List<IcoOfferingModel>> getFeaturedOfferings();
  Future<List<IcoOfferingModel>> getOfferings({
    String? status,
    int? page,
    int? limit,
    String? search,
    String? sort,
    List<String>? blockchain,
    List<String>? tokenType,
  });
  Future<IcoOfferingModel> getOfferingById(String id);
  Future<IcoPortfolioModel> getPortfolio();
  Future<List<IcoTransactionModel>> getTransactions({
    int? limit,
    int? offset,
  });
  Future<IcoTransactionModel> createInvestment({
    required String offeringId,
    required double amount,
    required String walletAddress,
  });
  Future<List<PortfolioPerformancePointModel>> getPortfolioPerformance({
    String timeframe = '1M',
  });
  Future<List<IcoBlockchainModel>> getBlockchains();
  Future<List<IcoTokenTypeModel>> getTokenTypes();
  Future<List<IcoLaunchPlanModel>> getLaunchPlans();
  Future<IcoStatsModel> getIcoStats();
}

@Injectable(as: IcoRemoteDataSource)
class IcoRemoteDataSourceImpl implements IcoRemoteDataSource {
  const IcoRemoteDataSourceImpl(this._dioClient);

  final DioClient _dioClient;

  /// Helper method to safely extract list from API response
  List<dynamic> _extractList(dynamic responseData, String? key) {
    if (responseData is List) {
      return responseData;
    } else if (responseData is Map<String, dynamic>) {
      if (key != null && responseData.containsKey(key)) {
        final data = responseData[key];
        if (data is List) {
          return data;
        } else if (data != null) {
          return [data];
        }
      }
      // If no specific key or key not found, check for common keys
      for (final commonKey in ['data', 'items', 'results']) {
        if (responseData.containsKey(commonKey)) {
          final data = responseData[commonKey];
          if (data is List) {
            return data;
          }
        }
      }
      // Return the whole object as single item
      return [responseData];
    }
    return [];
  }

  @override
  Future<List<IcoOfferingModel>> getFeaturedOfferings() async {
    dev.log('💎 ICO_REMOTE_DS: getFeaturedOfferings() called');
    final response = await _dioClient.get(ApiConstants.icoFeaturedOffers);

    dev.log('💎 ICO_REMOTE_DS: Response data type: ${response.data.runtimeType}');
    final dataList = _extractList(response.data, 'projects');
    dev.log('💎 ICO_REMOTE_DS: Parsing ${dataList.length} featured offerings');

    final offerings = <IcoOfferingModel>[];
    for (var i = 0; i < dataList.length; i++) {
      try {
        final offering = IcoOfferingModel.fromJson(dataList[i] as Map<String, dynamic>);
        offerings.add(offering);
      } catch (e) {
        dev.log('🔴 ICO_REMOTE_DS: Error parsing featured offering at index $i: $e');
        dev.log('🔴 ICO_REMOTE_DS: Offering data: ${dataList[i]}');
      }
    }
    dev.log('💎 ICO_REMOTE_DS: Successfully parsed ${offerings.length} of ${dataList.length} featured offerings');
    return offerings;
  }

  @override
  Future<List<IcoOfferingModel>> getOfferings({
    String? status,
    int? page,
    int? limit,
    String? search,
    String? sort,
    List<String>? blockchain,
    List<String>? tokenType,
  }) async {
    final queryParams = <String, dynamic>{};

    if (status != null) queryParams['status'] = status;
    if (page != null) queryParams['page'] = page;
    if (limit != null) queryParams['limit'] = limit;
    if (search != null) queryParams['search'] = search;
    if (sort != null) queryParams['sort'] = sort;
    if (blockchain != null && blockchain.isNotEmpty) {
      queryParams['blockchain'] = blockchain;
    }
    if (tokenType != null && tokenType.isNotEmpty) {
      queryParams['tokenType'] = tokenType;
    }

    dev.log('💎 ICO_REMOTE_DS: getOfferings() called with params: $queryParams');
    final response = await _dioClient.get(
      ApiConstants.icoOffers,
      queryParameters: queryParams,
    );

    dev.log('💎 ICO_REMOTE_DS: Response data type: ${response.data.runtimeType}');
    final dataList = _extractList(response.data, 'offerings');
    dev.log('💎 ICO_REMOTE_DS: Parsing ${dataList.length} offerings');

    final offerings = <IcoOfferingModel>[];
    for (var i = 0; i < dataList.length; i++) {
      try {
        final offering = IcoOfferingModel.fromJson(dataList[i] as Map<String, dynamic>);
        offerings.add(offering);
      } catch (e) {
        dev.log('🔴 ICO_REMOTE_DS: Error parsing offering at index $i: $e');
        dev.log('🔴 ICO_REMOTE_DS: Offering data: ${dataList[i]}');
      }
    }
    dev.log('💎 ICO_REMOTE_DS: Successfully parsed ${offerings.length} of ${dataList.length} offerings');
    return offerings;
  }

  @override
  Future<IcoOfferingModel> getOfferingById(String id) async {
    final response = await _dioClient.get('${ApiConstants.icoOfferById}/$id');
    return IcoOfferingModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<IcoPortfolioModel> getPortfolio() async {
    final response = await _dioClient.get(ApiConstants.icoPortfolio);
    return IcoPortfolioModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<List<IcoTransactionModel>> getTransactions({
    int? limit,
    int? offset,
  }) async {
    dev.log('💎 ICO_REMOTE_DS: getTransactions() called');
    final queryParams = <String, dynamic>{};
    if (limit != null) queryParams['limit'] = limit;
    if (offset != null) queryParams['page'] = offset ~/ (limit ?? 10) + 1;
    final response = await _dioClient.get(
      ApiConstants.icoTransactions,
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    dev.log('💎 ICO_REMOTE_DS: Response data type: ${response.data.runtimeType}');
    final dataList = _extractList(response.data, 'data');
    dev.log('💎 ICO_REMOTE_DS: Parsing ${dataList.length} transactions');

    final transactions = <IcoTransactionModel>[];
    for (var i = 0; i < dataList.length; i++) {
      try {
        final transaction = IcoTransactionModel.fromJson(dataList[i] as Map<String, dynamic>);
        transactions.add(transaction);
      } catch (e) {
        dev.log('🔴 ICO_REMOTE_DS: Error parsing transaction at index $i: $e');
        dev.log('🔴 ICO_REMOTE_DS: Transaction data: ${dataList[i]}');
      }
    }
    dev.log('💎 ICO_REMOTE_DS: Successfully parsed ${transactions.length} of ${dataList.length} transactions');
    return transactions;
  }

  @override
  Future<IcoTransactionModel> createInvestment({
    required String offeringId,
    required double amount,
    required String walletAddress,
  }) async {
    final response = await _dioClient.post(
      ApiConstants.icoCreateInvestment,
      data: {
        'offeringId': offeringId,
        'amount': amount,
        'walletAddress': walletAddress,
      },
    );

    return IcoTransactionModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<List<PortfolioPerformancePointModel>> getPortfolioPerformance({
    String timeframe = '1M',
  }) async {
    dev.log('💎 ICO_REMOTE_DS: getPortfolioPerformance() called with timeframe: $timeframe');
    final response = await _dioClient.get(
      ApiConstants.icoPortfolioPerformance,
      queryParameters: {'timeframe': timeframe},
    );

    dev.log('💎 ICO_REMOTE_DS: Response data type: ${response.data.runtimeType}');
    final dataList = _extractList(response.data, 'performanceData');
    dev.log('💎 ICO_REMOTE_DS: Parsing ${dataList.length} performance points');

    final points = <PortfolioPerformancePointModel>[];
    for (var i = 0; i < dataList.length; i++) {
      try {
        final point = PortfolioPerformancePointModel.fromJson(dataList[i] as Map<String, dynamic>);
        points.add(point);
      } catch (e) {
        dev.log('🔴 ICO_REMOTE_DS: Error parsing performance point at index $i: $e');
        dev.log('🔴 ICO_REMOTE_DS: Point data: ${dataList[i]}');
      }
    }
    dev.log('💎 ICO_REMOTE_DS: Successfully parsed ${points.length} of ${dataList.length} performance points');
    return points;
  }

  @override
  Future<List<IcoBlockchainModel>> getBlockchains() async {
    dev.log('💎 ICO_REMOTE_DS: getBlockchains() called');
    final response = await _dioClient.get(ApiConstants.icoBlockchains);

    dev.log('💎 ICO_REMOTE_DS: Response data type: ${response.data.runtimeType}');
    final dataList = _extractList(response.data, 'blockchains');
    dev.log('💎 ICO_REMOTE_DS: Parsing ${dataList.length} blockchains');

    final blockchains = <IcoBlockchainModel>[];
    for (var i = 0; i < dataList.length; i++) {
      try {
        final blockchain = IcoBlockchainModel.fromJson(dataList[i] as Map<String, dynamic>);
        blockchains.add(blockchain);
      } catch (e) {
        dev.log('🔴 ICO_REMOTE_DS: Error parsing blockchain at index $i: $e');
        dev.log('🔴 ICO_REMOTE_DS: Blockchain data: ${dataList[i]}');
      }
    }
    dev.log('💎 ICO_REMOTE_DS: Successfully parsed ${blockchains.length} of ${dataList.length} blockchains');
    return blockchains;
  }

  @override
  Future<List<IcoTokenTypeModel>> getTokenTypes() async {
    dev.log('💎 ICO_REMOTE_DS: getTokenTypes() called');
    final response = await _dioClient.get(ApiConstants.icoTokenTypes);

    dev.log('💎 ICO_REMOTE_DS: Response data type: ${response.data.runtimeType}');
    final dataList = _extractList(response.data, 'tokenTypes');
    dev.log('💎 ICO_REMOTE_DS: Parsing ${dataList.length} token types');

    final tokenTypes = <IcoTokenTypeModel>[];
    for (var i = 0; i < dataList.length; i++) {
      try {
        final tokenType = IcoTokenTypeModel.fromJson(dataList[i] as Map<String, dynamic>);
        tokenTypes.add(tokenType);
      } catch (e) {
        dev.log('🔴 ICO_REMOTE_DS: Error parsing token type at index $i: $e');
        dev.log('🔴 ICO_REMOTE_DS: Token type data: ${dataList[i]}');
      }
    }
    dev.log('💎 ICO_REMOTE_DS: Successfully parsed ${tokenTypes.length} of ${dataList.length} token types');
    return tokenTypes;
  }

  @override
  Future<List<IcoLaunchPlanModel>> getLaunchPlans() async {
    dev.log('💎 ICO_REMOTE_DS: getLaunchPlans() called');
    final response = await _dioClient.get(ApiConstants.icoLaunchPlans);

    dev.log('💎 ICO_REMOTE_DS: Response data type: ${response.data.runtimeType}');
    final dataList = _extractList(response.data, 'plans');
    dev.log('💎 ICO_REMOTE_DS: Parsing ${dataList.length} launch plans');

    final plans = <IcoLaunchPlanModel>[];
    for (var i = 0; i < dataList.length; i++) {
      try {
        final plan = IcoLaunchPlanModel.fromJson(dataList[i] as Map<String, dynamic>);
        plans.add(plan);
      } catch (e) {
        dev.log('🔴 ICO_REMOTE_DS: Error parsing launch plan at index $i: $e');
        dev.log('🔴 ICO_REMOTE_DS: Launch plan data: ${dataList[i]}');
      }
    }
    dev.log('💎 ICO_REMOTE_DS: Successfully parsed ${plans.length} of ${dataList.length} launch plans');
    return plans;
  }

  @override
  Future<IcoStatsModel> getIcoStats() async {
    final response = await _dioClient.get(ApiConstants.icoStats);

    return IcoStatsModel.fromJson(response.data as Map<String, dynamic>);
  }
}
