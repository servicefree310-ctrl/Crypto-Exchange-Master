import 'dart:developer' as dev;

import 'package:injectable/injectable.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/ai_investment_plan_model.dart';
import '../models/ai_investment_model.dart';

abstract class AiInvestmentRemoteDataSource {
  Future<List<AiInvestmentPlanModel>> getAiInvestmentPlans();
  Future<List<AiInvestmentModel>> getUserAiInvestments({
    String? status,
    String? type,
    int? limit,
    int? offset,
  });
  Future<AiInvestmentModel> getAiInvestmentById(String id);
  Future<AiInvestmentModel> createAiInvestment({
    required String planId,
    required String durationId,
    required String symbol,
    required double amount,
    required String walletType,
  });
  Future<void> cancelAiInvestment(String id);
}

@Injectable(as: AiInvestmentRemoteDataSource)
class AiInvestmentRemoteDataSourceImpl implements AiInvestmentRemoteDataSource {
  const AiInvestmentRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<AiInvestmentPlanModel>> getAiInvestmentPlans() async {
    try {
      final response = await _apiClient.get(ApiConstants.aiInvestmentPlans);

      // v5 backend returns array directly, not wrapped in data object
      final List<dynamic> data = response.data is List
          ? response.data as List<dynamic>
          : response.data['data'] as List<dynamic>? ?? [];

      if (data.isEmpty) {
        return []; // Return empty list instead of throwing error
      }

      return data.map((json) => AiInvestmentPlanModel.fromJson(json)).toList();
    } catch (e) {
      dev.log('Error fetching AI investment plans: $e');
      return []; // Return empty list on error
    }
  }

  @override
  Future<List<AiInvestmentModel>> getUserAiInvestments({
    String? status,
    String? type,
    int? limit,
    int? offset,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (status != null) queryParams['status'] = status;
      if (type != null) queryParams['type'] = type;
      if (limit != null) queryParams['limit'] = limit;
      if (offset != null) queryParams['offset'] = offset;

      final response = await _apiClient.get(
        ApiConstants.aiInvestmentOperations,
        queryParameters: queryParams,
      );

      // v5 backend returns array directly for user investments
      final List<dynamic> data = response.data is List
          ? response.data as List<dynamic>
          : response.data['data'] as List<dynamic>? ?? [];

      return data.map((json) => AiInvestmentModel.fromJson(json)).toList();
    } catch (e) {
      dev.log('Error fetching user AI investments: $e');
      return [];
    }
  }

  @override
  Future<AiInvestmentModel> getAiInvestmentById(String id) async {
    final response =
        await _apiClient.get('${ApiConstants.aiInvestmentById}/$id');

    // v5 backend returns object directly
    final Map<String, dynamic> data = response.data is Map<String, dynamic>
        ? response.data as Map<String, dynamic>
        : response.data['data'] as Map<String, dynamic>;

    return AiInvestmentModel.fromJson(data);
  }

  @override
  Future<AiInvestmentModel> createAiInvestment({
    required String planId,
    required String durationId,
    required String symbol,
    required double amount,
    required String walletType,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.createAiInvestment,
      data: {
        'planId': planId,
        'durationId': durationId,
        'symbol': symbol,
        'amount': amount,
        'walletType': walletType,
      },
    );

    // v5 backend returns object directly
    final Map<String, dynamic> data = response.data is Map<String, dynamic>
        ? response.data as Map<String, dynamic>
        : response.data['data'] as Map<String, dynamic>;

    return AiInvestmentModel.fromJson(data);
  }

  @override
  Future<void> cancelAiInvestment(String id) async {
    await _apiClient.delete('${ApiConstants.aiInvestmentById}/$id');
  }
}
