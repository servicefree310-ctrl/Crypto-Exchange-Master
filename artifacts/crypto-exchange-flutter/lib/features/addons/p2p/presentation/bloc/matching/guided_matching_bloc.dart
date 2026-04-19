import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'dart:async';

import 'guided_matching_event.dart';
import 'guided_matching_state.dart';
import '../../../domain/usecases/matching/guided_matching_usecase.dart';
import '../../../domain/usecases/matching/compare_prices_usecase.dart';
import '../../../../../../../core/errors/failures.dart';

@injectable
class GuidedMatchingBloc
    extends Bloc<GuidedMatchingEvent, GuidedMatchingState> {
  GuidedMatchingBloc(this._guidedMatching, this._comparePrices)
      : super(const GuidedMatchingInitial()) {
    on<GuidedMatchingFieldUpdated>(_onFieldUpdated);
    on<GuidedMatchingRequested>(_onRequested);
    on<GuidedMatchingRetryRequested>(_onRetry);
  }

  final GuidedMatchingUseCase _guidedMatching;
  final ComparePricesUseCase _comparePrices;

  final Map<String, dynamic> _formData = {};

  Future<void> _onFieldUpdated(
    GuidedMatchingFieldUpdated event,
    Emitter<GuidedMatchingState> emit,
  ) async {
    _formData[event.field] = event.value;
    emit(GuidedMatchingEditing(formData: Map.from(_formData)));
  }

  Future<void> _onRequested(
    GuidedMatchingRequested event,
    Emitter<GuidedMatchingState> emit,
  ) async {
    // Validate required fields are present before calling use case
    final requiredFields = [
      'tradeType',
      'cryptocurrency',
      'amount',
      'paymentMethods',
      'pricePreference',
      'traderPreference',
      'location',
    ];
    for (final f in requiredFields) {
      if (!_formData.containsKey(f) ||
          _formData[f] == null ||
          _formData[f].toString().isEmpty) {
        emit(GuidedMatchingError(
          ValidationFailure('Missing required field: $f'),
          formData: Map.from(_formData),
        ));
        return;
      }
    }

    emit(GuidedMatchingLoading(formData: Map.from(_formData)));

    final params = GuidedMatchingParams(
      tradeType: _formData['tradeType'],
      cryptocurrency: _formData['cryptocurrency'],
      amount: _formData['amount'],
      paymentMethods: List<String>.from(_formData['paymentMethods']),
      pricePreference: _formData['pricePreference'],
      traderPreference: _formData['traderPreference'],
      location: _formData['location'],
      maxResults: _formData['maxResults'] ?? 30,
    );

    final result = await _guidedMatching(params);
    await result.fold<FutureOr<void>>(
      (Failure failure) async =>
          emit(GuidedMatchingError(failure, formData: Map.from(_formData))),
      (GuidedMatchingResponse response) async {
        // After getting matches, run price comparison on the best match (optional)
        PriceComparisonResponse? priceComparison;
        if (response.matches.isNotEmpty) {
          final best = response.matches.first;
          final compareParams = ComparePricesParams(
            cryptocurrency: params.cryptocurrency,
            tradeType: params.tradeType,
            amount: params.amount,
            p2pPrice: best.price,
          );
          final compareResult = await _comparePrices(compareParams);
          compareResult.fold((_) {}, (pc) => priceComparison = pc);
        }
        emit(GuidedMatchingLoaded(
            response: response, priceComparison: priceComparison));
      },
    );
  }

  Future<void> _onRetry(
    GuidedMatchingRetryRequested event,
    Emitter<GuidedMatchingState> emit,
  ) async {
    add(GuidedMatchingRequested());
  }
}
