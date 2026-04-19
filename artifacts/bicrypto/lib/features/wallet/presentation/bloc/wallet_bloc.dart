import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/wallet_entity.dart';
import '../../domain/usecases/get_wallets_usecase.dart';
import '../../domain/usecases/get_wallets_by_type_usecase.dart';
import '../../domain/usecases/get_wallet_usecase.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_wallet_by_id_usecase.dart';
import '../../domain/usecases/get_wallet_performance_usecase.dart';
import '../../../../core/errors/failures.dart';

part 'wallet_event.dart';
part 'wallet_state.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final GetWalletsUseCase getWalletsUseCase;
  final GetWalletsByTypeUseCase getWalletsByTypeUseCase;
  final GetWalletUseCase getWalletUseCase;
  final GetWalletByIdUseCase getWalletByIdUseCase;
  final GetWalletPerformanceUseCase getWalletPerformanceUseCase;

  // Current state data
  Map<WalletType, List<WalletEntity>> _currentWallets = {};
  Map<String, dynamic>? _currentPerformance;

  WalletBloc({
    required this.getWalletsUseCase,
    required this.getWalletsByTypeUseCase,
    required this.getWalletUseCase,
    required this.getWalletByIdUseCase,
    required this.getWalletPerformanceUseCase,
  }) : super(WalletInitial()) {
    on<GetWalletsEvent>(_onGetWallets);
    on<GetWalletsByTypeEvent>(_onGetWalletsByType);
    on<GetWalletEvent>(_onGetWallet);
    on<GetWalletByIdEvent>(_onGetWalletById);
    on<GetWalletPerformanceEvent>(_onGetWalletPerformance);
    on<RefreshWalletsEvent>(_onRefreshWallets);
    on<ClearWalletErrorEvent>(_onClearWalletError);
  }

  Future<void> _onGetWallets(
    GetWalletsEvent event,
    Emitter<WalletState> emit,
  ) async {
    if (state is! WalletLoaded) {
      emit(WalletLoading());
    }

    final result = await getWalletsUseCase(NoParams());

    result.fold(
      (failure) {
        emit(WalletError(failure.message));
      },
      (wallets) {
        _currentWallets = wallets;

        emit(WalletLoaded(
          wallets: wallets,
          performance: _currentPerformance,
        ));

        // Load performance data if not already available
        if (_currentPerformance == null && !isClosed) {
          add(GetWalletPerformanceEvent());
        }
      },
    );
  }

  Future<void> _onGetWalletsByType(
    GetWalletsByTypeEvent event,
    Emitter<WalletState> emit,
  ) async {
    emit(WalletLoading());

    final result = await getWalletsByTypeUseCase(event.type);

    result.fold(
      (failure) {
        emit(WalletError(failure.message));
      },
      (wallets) {
        _currentWallets[event.type] = wallets;

        emit(WalletLoaded(
          wallets: _currentWallets,
          performance: _currentPerformance,
        ));
      },
    );
  }

  Future<void> _onGetWallet(
    GetWalletEvent event,
    Emitter<WalletState> emit,
  ) async {
    emit(WalletLoading());

    final result = await getWalletUseCase(
      GetWalletParams(type: event.type, currency: event.currency),
    );

    result.fold(
      (failure) {
        emit(WalletError(failure.message));
      },
      (wallet) {
        emit(WalletSingleLoaded(wallet));
      },
    );
  }

  Future<void> _onGetWalletById(
    GetWalletByIdEvent event,
    Emitter<WalletState> emit,
  ) async {
    emit(WalletLoading());

    final result = await getWalletByIdUseCase(event.walletId);

    result.fold(
      (failure) {
        emit(WalletError(failure.message));
      },
      (wallet) {
        emit(WalletSingleLoaded(wallet));
      },
    );
  }

  Future<void> _onGetWalletPerformance(
    GetWalletPerformanceEvent event,
    Emitter<WalletState> emit,
  ) async {
    // Don't show loading if wallets are already loaded
    final shouldShowLoading = state is! WalletLoaded;
    if (shouldShowLoading) {
      emit(WalletLoading());
    }

    final result = await getWalletPerformanceUseCase(NoParams());

    result.fold(
      (failure) {
        if (shouldShowLoading) {
          emit(WalletError(failure.message));
        }
      },
      (performance) {
        _currentPerformance = performance;

        emit(WalletLoaded(
          wallets: _currentWallets,
          performance: _currentPerformance,
        ));
      },
    );
  }

  Future<void> _onRefreshWallets(
    RefreshWalletsEvent event,
    Emitter<WalletState> emit,
  ) async {
    final result = await getWalletsUseCase(NoParams());

    result.fold(
      (failure) {},
      (wallets) {
        _currentWallets = wallets;

        emit(WalletLoaded(
          wallets: wallets,
          performance: _currentPerformance,
        ));
      },
    );
  }

  void _onClearWalletError(
    ClearWalletErrorEvent event,
    Emitter<WalletState> emit,
  ) {
    if (_currentWallets.isNotEmpty) {
      emit(WalletLoaded(
        wallets: _currentWallets,
        performance: _currentPerformance,
      ));
    } else {
      emit(WalletInitial());
    }
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure) {
      case ServerFailure():
        return 'Server error occurred. Please try again.';
      case NetworkFailure():
        return 'No internet connection. Please check your network.';
      case CacheFailure():
        return 'Cache error occurred. Please restart the app.';
      case ValidationFailure():
        return 'Invalid input. Please check your data.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }

  // Helper methods for public API
  void loadWalletsInitially() {
    add(GetWalletsEvent());
  }

  void refreshWalletsManually() {
    add(RefreshWalletsEvent());
  }

  void selectWalletType(WalletType type) {
    add(GetWalletsByTypeEvent(type));
  }
}
