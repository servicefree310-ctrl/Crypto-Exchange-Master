import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failures.dart';
import '../entities/mlm_dashboard_entity.dart';
import '../entities/mlm_landing_entity.dart';
import '../entities/mlm_referral_entity.dart';
import '../entities/mlm_reward_entity.dart';
import '../entities/mlm_condition_entity.dart';
import '../entities/mlm_network_entity.dart';

abstract class MlmRepository {
  // Dashboard Operations
  Future<Either<Failure, MlmDashboardEntity>> getDashboard({
    String period = '6m',
  });

  // Referral Operations
  Future<Either<Failure, List<MlmReferralEntity>>> getReferrals({
    int page = 1,
    int perPage = 10,
  });

  Future<Either<Failure, MlmReferralEntity>> getReferralById(String id);

  Future<Either<Failure, Map<String, dynamic>>> analyzeReferral({
    required String referralId,
    required Map<String, dynamic> analysisData,
  });

  // Reward Operations
  Future<Either<Failure, List<MlmRewardEntity>>> getRewards({
    int page = 1,
    int perPage = 10,
    String? sortField,
    String? sortOrder,
  });

  Future<Either<Failure, MlmRewardEntity>> getRewardById(String id);

  Future<Either<Failure, Map<String, dynamic>>> claimReward(String rewardId);

  // Network Operations
  Future<Either<Failure, MlmNetworkEntity>> getNetwork();

  Future<Either<Failure, Map<String, dynamic>>> getNetworkNode();

  // Condition Operations
  Future<Either<Failure, List<MlmConditionEntity>>> getConditions();

  Future<Either<Failure, MlmConditionEntity>> getConditionById(String id);

  // Analytics & Performance Operations
  Future<Either<Failure, Map<String, dynamic>>> getAnalytics({
    String period = '6m',
  });

  Future<Either<Failure, Map<String, dynamic>>> getPerformanceMetrics();

  // Landing Page Operations
  Future<Either<Failure, MlmLandingEntity>> getLanding();
}
