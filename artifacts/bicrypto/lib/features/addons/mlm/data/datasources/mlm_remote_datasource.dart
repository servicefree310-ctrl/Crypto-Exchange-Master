import 'package:injectable/injectable.dart';
import '../../../../../core/constants/api_constants.dart';
import '../../../../../core/network/api_client.dart';
import '../models/mlm_dashboard_model.dart';
import '../models/mlm_landing_model.dart';

abstract class MlmRemoteDataSource {
  Future<MlmDashboardModel> getDashboard({String period = '6m'});
  Future<List<dynamic>> getReferrals({int page = 1, int perPage = 10});
  Future<Map<String, dynamic>> getReferralById(String id);
  Future<Map<String, dynamic>> analyzeReferral({
    required String referralId,
    required Map<String, dynamic> analysisData,
  });
  Future<List<dynamic>> getRewards({
    int page = 1,
    int perPage = 10,
    String? sortField,
    String? sortOrder,
  });
  Future<Map<String, dynamic>> getRewardById(String id);
  Future<Map<String, dynamic>> claimReward(String rewardId);
  Future<Map<String, dynamic>> getNetwork();
  Future<Map<String, dynamic>> getNetworkNode();
  Future<List<dynamic>> getConditions();
  Future<Map<String, dynamic>> getConditionById(String id);
  Future<Map<String, dynamic>> getAnalytics({String period = '6m'});
  Future<Map<String, dynamic>> getPerformanceMetrics();
  Future<MlmLandingModel> getLanding();
}

@Injectable(as: MlmRemoteDataSource)
class MlmRemoteDataSourceImpl implements MlmRemoteDataSource {
  const MlmRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<MlmDashboardModel> getDashboard({String period = '6m'}) async {
    final response = await _apiClient.get(
      ApiConstants.mlmDashboard,
      queryParameters: {'period': period},
    );
    return MlmDashboardModel.fromJson(response.data);
  }

  @override
  Future<List<dynamic>> getReferrals({int page = 1, int perPage = 10}) async {
    final response = await _apiClient.get(
      ApiConstants.mlmReferrals,
      queryParameters: {
        'page': page,
        'perPage': perPage,
      },
    );
    return response.data['referrals'] ?? [];
  }

  @override
  Future<Map<String, dynamic>> getReferralById(String id) async {
    final response =
        await _apiClient.get('${ApiConstants.mlmReferralById}/$id');
    return response.data;
  }

  @override
  Future<Map<String, dynamic>> analyzeReferral({
    required String referralId,
    required Map<String, dynamic> analysisData,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.mlmReferralAnalysis,
      data: {
        'referralId': referralId,
        ...analysisData,
      },
    );
    return response.data;
  }

  @override
  Future<List<dynamic>> getRewards({
    int page = 1,
    int perPage = 10,
    String? sortField,
    String? sortOrder,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'perPage': perPage,
    };

    if (sortField != null) queryParams['sortField'] = sortField;
    if (sortOrder != null) queryParams['sortOrder'] = sortOrder;

    final response = await _apiClient.get(
      ApiConstants.mlmRewards,
      queryParameters: queryParams,
    );
    return response.data['data'] ?? [];
  }

  @override
  Future<Map<String, dynamic>> getRewardById(String id) async {
    final response = await _apiClient.get('${ApiConstants.mlmRewardById}/$id');
    return response.data;
  }

  @override
  Future<Map<String, dynamic>> claimReward(String rewardId) async {
    final response =
        await _apiClient.post('${ApiConstants.mlmRewardClaim}/$rewardId/claim');
    return response.data;
  }

  @override
  Future<Map<String, dynamic>> getNetwork() async {
    final response = await _apiClient.get(ApiConstants.mlmNetwork);
    return response.data;
  }

  @override
  Future<Map<String, dynamic>> getNetworkNode() async {
    final response = await _apiClient.get(ApiConstants.mlmReferralNode);
    return response.data;
  }

  @override
  Future<List<dynamic>> getConditions() async {
    final response = await _apiClient.get(ApiConstants.mlmConditions);
    return response.data['data'] ?? [];
  }

  @override
  Future<Map<String, dynamic>> getConditionById(String id) async {
    final response =
        await _apiClient.get('${ApiConstants.mlmConditionById}/$id');
    return response.data;
  }

  @override
  Future<Map<String, dynamic>> getAnalytics({String period = '6m'}) async {
    final response = await _apiClient.get(
      ApiConstants.mlmAnalytics,
      queryParameters: {'period': period},
    );
    return response.data;
  }

  @override
  Future<Map<String, dynamic>> getPerformanceMetrics() async {
    final response = await _apiClient.get(ApiConstants.mlmPerformance);
    return response.data;
  }

  @override
  Future<MlmLandingModel> getLanding() async {
    final response = await _apiClient.get(ApiConstants.mlmLanding);
    return MlmLandingModel.fromJson(response.data);
  }
}
