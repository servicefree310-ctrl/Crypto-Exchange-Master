import 'package:injectable/injectable.dart';

import '../../../../../../core/network/dio_client.dart';
import '../../../../../../core/constants/api_constants.dart';
import '../models/creator_token_model.dart';
import '../models/launch_plan_model.dart';
import '../models/investor_model.dart';
import '../models/creator_stats_model.dart';
import '../models/team_member_model.dart';
import '../models/roadmap_item_model.dart';
import '../models/chart_point_model.dart';

abstract class CreatorRemoteDataSource {
  Future<List<CreatorTokenModel>> getTokens();
  Future<CreatorTokenModel> getToken(String id);
  Future<void> launchToken(Map<String, dynamic> payload);
  Future<List<LaunchPlanModel>> getLaunchPlans();
  Future<List<InvestorModel>> getInvestors({int page = 1, int limit = 20});
  Future<CreatorStatsModel> getStats();
  Future<List<TeamMemberModel>> getTeamMembers(String tokenId);
  Future<void> addTeamMember(String tokenId, Map<String, dynamic> payload);
  Future<void> updateTeamMember(
      String tokenId, String memberId, Map<String, dynamic> payload);
  Future<void> deleteTeamMember(String tokenId, String memberId);
  Future<List<RoadmapItemModel>> getRoadmapItems(String tokenId);
  Future<void> addRoadmapItem(String tokenId, Map<String, dynamic> payload);
  Future<void> updateRoadmapItem(
      String tokenId, String roadmapId, Map<String, dynamic> payload);
  Future<void> deleteRoadmapItem(String tokenId, String roadmapId);
  Future<List<ChartPointModel>> getPerformance({String range = '30d'});
}

@Injectable(as: CreatorRemoteDataSource)
class CreatorRemoteDataSourceImpl implements CreatorRemoteDataSource {
  const CreatorRemoteDataSourceImpl(this._client);

  final DioClient _client;

  @override
  Future<List<CreatorTokenModel>> getTokens() async {
    final response = await _client.get(ApiConstants.icoCreatorTokens);

    // v5 returns grouped data: { active: [], pending: [], completed: [] }
    if (response.data is Map) {
      final active = (response.data['active'] as List?) ?? [];
      final pending = (response.data['pending'] as List?) ?? [];
      final completed = (response.data['completed'] as List?) ?? [];

      // Combine all lists
      final allTokens = [...active, ...pending, ...completed];

      return allTokens
          .map((e) => CreatorTokenModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    // Fallback for different response format
    return (response.data as List)
        .map((e) => CreatorTokenModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<CreatorTokenModel> getToken(String id) async {
    final response =
        await _client.get('${ApiConstants.icoCreatorTokenById}/$id');
    return CreatorTokenModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> launchToken(Map<String, dynamic> payload) async {
    await _client.post(ApiConstants.icoCreatorLaunch, data: payload);
  }

  @override
  Future<List<LaunchPlanModel>> getLaunchPlans() async {
    final response = await _client.get(ApiConstants.icoLaunchPlan);
    return (response.data as List)
        .map((e) => LaunchPlanModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<InvestorModel>> getInvestors(
      {int page = 1, int limit = 20}) async {
    final response = await _client.get(
      ApiConstants.icoCreatorInvestors,
      queryParameters: {
        'page': page,
        'limit': limit,
      },
    );
    final items = (response.data['items'] as List?) ?? [];
    return items
        .map((e) => InvestorModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<CreatorStatsModel> getStats() async {
    final response = await _client.get(ApiConstants.icoCreatorStats);
    return CreatorStatsModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<List<TeamMemberModel>> getTeamMembers(String tokenId) async {
    final response =
        await _client.get('${ApiConstants.icoCreatorTokenTeam}/$tokenId/team');
    return (response.data as List)
        .map((e) => TeamMemberModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> addTeamMember(
      String tokenId, Map<String, dynamic> payload) async {
    await _client.post('${ApiConstants.icoCreatorTokenTeam}/$tokenId/team',
        data: payload);
  }

  @override
  Future<void> updateTeamMember(
      String tokenId, String memberId, Map<String, dynamic> payload) async {
    await _client.put(
        '${ApiConstants.icoCreatorTokenTeam}/$tokenId/team/$memberId',
        data: payload);
  }

  @override
  Future<void> deleteTeamMember(String tokenId, String memberId) async {
    await _client
        .delete('${ApiConstants.icoCreatorTokenTeam}/$tokenId/team/$memberId');
  }

  @override
  Future<List<RoadmapItemModel>> getRoadmapItems(String tokenId) async {
    final response = await _client
        .get('${ApiConstants.icoCreatorTokenRoadmap}/$tokenId/roadmap');
    return (response.data as List)
        .map((e) => RoadmapItemModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> addRoadmapItem(
      String tokenId, Map<String, dynamic> payload) async {
    await _client.post(
        '${ApiConstants.icoCreatorTokenRoadmap}/$tokenId/roadmap',
        data: payload);
  }

  @override
  Future<void> updateRoadmapItem(
      String tokenId, String roadmapId, Map<String, dynamic> payload) async {
    await _client.put(
        '${ApiConstants.icoCreatorTokenRoadmap}/$tokenId/roadmap/$roadmapId',
        data: payload);
  }

  @override
  Future<void> deleteRoadmapItem(String tokenId, String roadmapId) async {
    await _client.delete(
        '${ApiConstants.icoCreatorTokenRoadmap}/$tokenId/roadmap/$roadmapId');
  }

  @override
  Future<List<ChartPointModel>> getPerformance({String range = '30d'}) async {
    final response = await _client.get(ApiConstants.icoCreatorPerformance,
        queryParameters: {'range': range});
    return (response.data as List)
        .map((e) => ChartPointModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
