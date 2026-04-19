import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';

@injectable
class ManageFullscreenStateUseCase
    implements UseCase<FullscreenState, ManageFullscreenParams> {
  const ManageFullscreenStateUseCase();

  @override
  Future<Either<Failure, FullscreenState>> call(
      ManageFullscreenParams params) async {
    try {
      // Business logic for managing fullscreen state
      final newState = params.currentState.copyWith(
        showTradingPanel:
            params.showTradingPanel ?? params.currentState.showTradingPanel,
        showOrderBook:
            params.showOrderBook ?? params.currentState.showOrderBook,
        showTradingInfo:
            params.showTradingInfo ?? params.currentState.showTradingInfo,
      );

      // Ensure only one panel is shown at a time
      if (newState.showOrderBook && newState.showTradingInfo) {
        return Right(newState.copyWith(
          showTradingInfo: false, // Prioritize order book
        ));
      }

      return Right(newState);
    } catch (e) {
      return Left(FormatFailure('Failed to manage fullscreen state: $e'));
    }
  }
}

class ManageFullscreenParams {
  const ManageFullscreenParams({
    required this.currentState,
    this.showTradingPanel,
    this.showOrderBook,
    this.showTradingInfo,
  });

  final FullscreenState currentState;
  final bool? showTradingPanel;
  final bool? showOrderBook;
  final bool? showTradingInfo;
}

class FullscreenState {
  const FullscreenState({
    this.showTradingPanel = true,
    this.showOrderBook = false,
    this.showTradingInfo = false,
  });

  final bool showTradingPanel;
  final bool showOrderBook;
  final bool showTradingInfo;

  FullscreenState copyWith({
    bool? showTradingPanel,
    bool? showOrderBook,
    bool? showTradingInfo,
  }) {
    return FullscreenState(
      showTradingPanel: showTradingPanel ?? this.showTradingPanel,
      showOrderBook: showOrderBook ?? this.showOrderBook,
      showTradingInfo: showTradingInfo ?? this.showTradingInfo,
    );
  }
}
