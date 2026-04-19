import '../../../../../core/errors/failures.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../../core/usecases/usecase.dart';
import '../entities/launch_token_entity.dart';
import '../entities/launch_plan_entity.dart';
import '../repositories/creator_repository.dart';

@injectable
class LaunchTokenUseCase implements UseCase<void, LaunchTokenParams> {
  const LaunchTokenUseCase(this._repository);

  final CreatorRepository _repository;

  @override
  Future<Either<Failure, void>> call(LaunchTokenParams params) async {
    // Validate the entity
    final errors = LaunchTokenValidator.validate(params.launchToken);
    if (errors.isNotEmpty) {
      return Left(ValidationFailure(errors.join(', ')));
    }

    // Validate against plan limits
    final planErrors = _validateAgainstPlan(params.launchToken, params.plan);
    if (planErrors.isNotEmpty) {
      return Left(ValidationFailure(planErrors.join(', ')));
    }

    // Check payment completion
    if (!params.launchToken.paymentComplete) {
      return const Left(
          ValidationFailure('Payment must be completed before launching'));
    }

    // Convert entity to Map for API
    final payload = _entityToMap(params.launchToken);

    return await _repository.launchToken(payload);
  }

  List<String> _validateAgainstPlan(
      LaunchTokenEntity token, LaunchPlanEntity plan) {
    final errors = <String>[];

    // Extract max values from plan features
    final maxTeamMembers = plan.features['maxTeamMembers'] as int? ?? 0;
    final maxRoadmapItems = plan.features['maxRoadmapItems'] as int? ?? 0;
    final maxOfferingPhases = plan.features['maxOfferingPhases'] as int? ?? 0;

    if (token.teamMembers.length > maxTeamMembers) {
      errors.add('Maximum allowed team members is $maxTeamMembers');
    }

    if (token.roadmap.length > maxRoadmapItems) {
      errors.add('Maximum allowed roadmap items is $maxRoadmapItems');
    }

    if (token.phases.length > maxOfferingPhases) {
      errors.add('Maximum allowed offering phases is $maxOfferingPhases');
    }

    return errors;
  }

  Map<String, dynamic> _entityToMap(LaunchTokenEntity entity) {
    return {
      'name': entity.name,
      'symbol': entity.symbol,
      'icon': entity.icon,
      'tokenType': entity.tokenType,
      'blockchain': entity.blockchain,
      'totalSupply': entity.totalSupply,
      'description': entity.description,
      'tokenDetails': {
        'whitepaper': entity.tokenDetails.whitepaper,
        'github': entity.tokenDetails.github,
        'twitter': entity.tokenDetails.twitter,
        'telegram': entity.tokenDetails.telegram,
        'useOfFunds': entity.tokenDetails.useOfFunds,
      },
      'teamMembers': entity.teamMembers
          .map((member) => {
                'id': member.id,
                'name': member.name,
                'role': member.role,
                'bio': member.bio,
                'linkedin': member.linkedin,
                'twitter': member.twitter,
                'github': member.github,
                'website': member.website,
                'avatar': member.avatar,
              })
          .toList(),
      'roadmap': entity.roadmap
          .map((item) => {
                'id': item.id,
                'title': item.title,
                'description': item.description,
                'date': item.date.toIso8601String(),
                'completed': item.completed,
              })
          .toList(),
      'website': entity.website,
      'targetAmount': entity.targetAmount,
      'startDate': entity.startDate.toIso8601String(),
      'phases': entity.phases
          .map((phase) => {
                'id': phase.id,
                'name': phase.name,
                'tokenPrice': phase.tokenPrice,
                'allocation': phase.allocation,
                'durationDays': phase.durationDays,
              })
          .toList(),
      'termsAccepted': entity.termsAccepted,
      'selectedPlan': entity.selectedPlanId,
      'paymentComplete': entity.paymentComplete,
    };
  }
}

class LaunchTokenParams {
  const LaunchTokenParams({
    required this.launchToken,
    required this.plan,
  });

  final LaunchTokenEntity launchToken;
  final LaunchPlanEntity plan;
}
