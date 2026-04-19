import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failures.dart';
import '../entities/creator_token_entity.dart';
import '../entities/launch_plan_entity.dart';
import '../entities/investor_entity.dart';
import '../entities/creator_stats_entity.dart';
import '../entities/team_member_entity.dart';
import '../entities/roadmap_item_entity.dart';
import '../entities/chart_point_entity.dart';

abstract class CreatorRepository {
  Future<Either<Failure, List<CreatorTokenEntity>>> getTokens();
  Future<Either<Failure, CreatorTokenEntity>> getToken(String id);
  Future<Either<Failure, void>> launchToken(Map<String, dynamic> payload);
  Future<Either<Failure, List<LaunchPlanEntity>>> getLaunchPlans();
  Future<Either<Failure, List<InvestorEntity>>> getInvestors();
  Future<Either<Failure, CreatorStatsEntity>> getStats();
  Future<Either<Failure, List<TeamMemberEntity>>> getTeamMembers(
      String tokenId);
  Future<Either<Failure, void>> addTeamMember(
      String tokenId, TeamMemberEntity member);
  Future<Either<Failure, void>> updateTeamMember(
      String tokenId, TeamMemberEntity member);
  Future<Either<Failure, void>> deleteTeamMember(
      String tokenId, String memberId);
  Future<Either<Failure, List<RoadmapItemEntity>>> getRoadmapItems(
      String tokenId);
  Future<Either<Failure, void>> addRoadmapItem(
      String tokenId, RoadmapItemEntity item);
  Future<Either<Failure, void>> updateRoadmapItem(
      String tokenId, RoadmapItemEntity item);
  Future<Either<Failure, void>> deleteRoadmapItem(
      String tokenId, String roadmapId);
  Future<Either<Failure, List<ChartPointEntity>>> getPerformance(String range);
}
