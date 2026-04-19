import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/repositories/creator_repository.dart';
import '../../domain/usecases/launch_token_usecase.dart';
import '../../domain/entities/launch_token_entity.dart';
import '../../domain/entities/launch_plan_entity.dart';
import 'creator_event.dart';
import 'creator_state.dart';

@Injectable()
class CreatorBloc extends Bloc<CreatorEvent, CreatorState> {
  CreatorBloc(this._repository, this._launchTokenUseCase)
      : super(const CreatorInitial()) {
    on<CreatorLoadDashboardRequested>(_onLoadDashboard);
    on<CreatorLaunchTokenRequested>(_onLaunchToken);
  }

  final CreatorRepository _repository;
  final LaunchTokenUseCase _launchTokenUseCase;

  Future<void> _onLoadDashboard(
    CreatorLoadDashboardRequested event,
    Emitter<CreatorState> emit,
  ) async {
    emit(const CreatorLoading());
    final result = await _repository.getTokens();
    result.fold(
      (failure) => emit(CreatorError(failure.message)),
      (tokens) => emit(CreatorDashboardLoaded(tokens: tokens)),
    );
  }

  Future<void> _onLaunchToken(
    CreatorLaunchTokenRequested event,
    Emitter<CreatorState> emit,
  ) async {
    emit(const CreatorLaunching());

    try {
      // Parse the payload to create LaunchTokenEntity
      final payload = event.payload;
      final selectedPlan = payload['selectedPlan'] as LaunchPlanEntity?;

      if (selectedPlan == null) {
        emit(const CreatorError('Launch plan is required'));
        return;
      }

      // Parse description (ensure it exists and is a string)
      final description = payload['description'] as String? ?? '';

      // Parse token details
      final tokenDetailsMap = payload['tokenDetails'] as Map<String, dynamic>;
      final tokenDetails = TokenDetailsEntity(
        whitepaper: tokenDetailsMap['whitepaper'] as String? ?? '',
        github: tokenDetailsMap['github'] as String? ?? '',
        twitter: tokenDetailsMap['twitter'] as String? ?? '',
        telegram: tokenDetailsMap['telegram'] as String? ?? '',
        useOfFunds: List<String>.from(tokenDetailsMap['useOfFunds'] ?? []),
      );

      // Parse team members
      final teamMembers = (payload['teamMembers'] as List<dynamic>? ?? [])
          .map((member) => TeamMemberEntity(
                id: member['id'] as String,
                name: member['name'] as String,
                role: member['role'] as String,
                bio: member['bio'] as String,
                linkedin: member['linkedin'] as String?,
                twitter: member['twitter'] as String?,
                github: member['github'] as String?,
                website: member['website'] as String?,
                avatar: member['avatar'] as String?,
              ))
          .toList();

      // Parse roadmap
      final roadmap = (payload['roadmap'] as List<dynamic>? ?? [])
          .map((item) => RoadmapItemEntity(
                id: item['id'] as String,
                title: item['title'] as String,
                description: item['description'] as String,
                date: item['date'] is DateTime
                    ? item['date'] as DateTime
                    : DateTime.parse(item['date'] as String),
                completed: item['completed'] as bool? ?? false,
              ))
          .toList();

      // Parse phases
      final phases = (payload['phases'] as List<dynamic>? ?? [])
          .map((phase) => PhaseEntity(
                id: phase['id'] as String,
                name: phase['name'] as String,
                tokenPrice: (phase['tokenPrice'] as num).toDouble(),
                allocation: (phase['allocation'] as num).toDouble(),
                durationDays: phase['durationDays'] as int,
              ))
          .toList();

      // Create LaunchTokenEntity
      final launchToken = LaunchTokenEntity(
        name: payload['name'] as String? ?? '',
        symbol: payload['symbol'] as String? ?? '',
        icon: payload['icon'] as String? ?? '',
        tokenType: payload['tokenType'] as String? ?? 'Utility',
        blockchain: payload['blockchain'] as String? ?? 'Ethereum',
        totalSupply: (payload['totalSupply'] as num?)?.toDouble() ?? 0,
        description: description,
        tokenDetails: tokenDetails,
        teamMembers: teamMembers,
        roadmap: roadmap,
        website: payload['website'] as String? ?? '',
        targetAmount: (payload['targetAmount'] as num?)?.toDouble() ?? 0,
        startDate: payload['startDate'] as DateTime? ?? DateTime.now(),
        phases: phases,
        termsAccepted: payload['termsAccepted'] as bool? ?? false,
        selectedPlanId: selectedPlan.id,
        paymentComplete: payload['paymentComplete'] as bool? ?? false,
      );

      final result = await _launchTokenUseCase(
        LaunchTokenParams(
          launchToken: launchToken,
          plan: selectedPlan,
        ),
      );

      result.fold(
        (failure) => emit(CreatorError(failure.message)),
        (_) => emit(const CreatorLaunchSuccess()),
      );
    } catch (e) {
      emit(CreatorError('Failed to parse launch data: $e'));
    }
  }
}
