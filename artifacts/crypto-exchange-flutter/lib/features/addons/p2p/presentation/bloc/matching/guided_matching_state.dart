import 'package:equatable/equatable.dart';
import '../../../domain/usecases/matching/guided_matching_usecase.dart';
import '../../../domain/usecases/matching/compare_prices_usecase.dart';
import '../../../../../../../core/errors/failures.dart';

/// Wizard steps enumeration, optional if UI multi-step
enum MatchingStep { criteria, reviewing, results }

abstract class GuidedMatchingState extends Equatable {
  const GuidedMatchingState();
  @override
  List<Object?> get props => [];
}

class GuidedMatchingInitial extends GuidedMatchingState {
  const GuidedMatchingInitial({this.formData = const {}});
  final Map<String, dynamic> formData;
  @override
  List<Object?> get props => [formData];
}

class GuidedMatchingEditing extends GuidedMatchingState {
  const GuidedMatchingEditing({required this.formData});
  final Map<String, dynamic> formData;
  @override
  List<Object?> get props => [formData];
}

class GuidedMatchingLoading extends GuidedMatchingState {
  const GuidedMatchingLoading({required this.formData});
  final Map<String, dynamic> formData;
  @override
  List<Object?> get props => [formData];
}

class GuidedMatchingLoaded extends GuidedMatchingState {
  const GuidedMatchingLoaded({required this.response, this.priceComparison});
  final GuidedMatchingResponse response;
  final PriceComparisonResponse? priceComparison;
  @override
  List<Object?> get props => [response, priceComparison];
}

class GuidedMatchingError extends GuidedMatchingState {
  const GuidedMatchingError(this.failure, {required this.formData});
  final Failure failure;
  final Map<String, dynamic> formData;
  @override
  List<Object?> get props => [failure, formData];
}
