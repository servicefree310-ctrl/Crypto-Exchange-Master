import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:equatable/equatable.dart';
import '../../domain/usecases/get_currency_price_usecase.dart';
import '../../domain/usecases/get_wallet_balance_usecase.dart';

// Events
abstract class CurrencyPriceEvent extends Equatable {
  const CurrencyPriceEvent();

  @override
  List<Object?> get props => [];
}

class FetchCurrencyPrice extends CurrencyPriceEvent {
  final String currency;
  final String walletType;

  const FetchCurrencyPrice({
    required this.currency,
    required this.walletType,
  });

  @override
  List<Object?> get props => [currency, walletType];
}

class FetchWalletBalance extends CurrencyPriceEvent {
  final String currency;
  final String walletType;

  const FetchWalletBalance({
    required this.currency,
    required this.walletType,
  });

  @override
  List<Object?> get props => [currency, walletType];
}

class ResetCurrencyData extends CurrencyPriceEvent {
  const ResetCurrencyData();
}

// States
abstract class CurrencyPriceState extends Equatable {
  const CurrencyPriceState();

  @override
  List<Object?> get props => [];
}

class CurrencyPriceInitial extends CurrencyPriceState {
  const CurrencyPriceInitial();
}

class CurrencyPriceLoading extends CurrencyPriceState {
  const CurrencyPriceLoading();
}

class CurrencyPriceLoaded extends CurrencyPriceState {
  final double price;
  final double? balance;
  final String currency;
  final String walletType;

  const CurrencyPriceLoaded({
    required this.price,
    this.balance,
    required this.currency,
    required this.walletType,
  });

  @override
  List<Object?> get props => [price, balance, currency, walletType];

  CurrencyPriceLoaded copyWith({
    double? price,
    double? balance,
    String? currency,
    String? walletType,
  }) {
    return CurrencyPriceLoaded(
      price: price ?? this.price,
      balance: balance ?? this.balance,
      currency: currency ?? this.currency,
      walletType: walletType ?? this.walletType,
    );
  }
}

class CurrencyPriceError extends CurrencyPriceState {
  final String message;

  const CurrencyPriceError({required this.message});

  @override
  List<Object?> get props => [message];
}

// BLoC
@injectable
class CurrencyPriceBloc extends Bloc<CurrencyPriceEvent, CurrencyPriceState> {
  final GetCurrencyPriceUseCase _getCurrencyPriceUseCase;
  final GetCurrencyWalletBalanceUseCase _getWalletBalanceUseCase;

  CurrencyPriceBloc(
    this._getCurrencyPriceUseCase,
    GetCurrencyWalletBalanceUseCase getWalletBalanceUseCase,
  )   : _getWalletBalanceUseCase = getWalletBalanceUseCase,
        super(const CurrencyPriceInitial()) {
    on<FetchCurrencyPrice>(_onFetchCurrencyPrice);
    on<FetchWalletBalance>(_onFetchWalletBalance);
    on<ResetCurrencyData>(_onResetCurrencyData);
  }

  Future<void> _onFetchCurrencyPrice(
    FetchCurrencyPrice event,
    Emitter<CurrencyPriceState> emit,
  ) async {
    emit(const CurrencyPriceLoading());

    final result = await _getCurrencyPriceUseCase(GetCurrencyPriceParams(
      currency: event.currency,
      walletType: event.walletType,
    ));

    result.fold(
      (failure) => emit(CurrencyPriceError(message: failure.message)),
      (price) => emit(CurrencyPriceLoaded(
        price: price,
        currency: event.currency,
        walletType: event.walletType,
      )),
    );
  }

  Future<void> _onFetchWalletBalance(
    FetchWalletBalance event,
    Emitter<CurrencyPriceState> emit,
  ) async {
    // If we already have price data, preserve it while loading balance
    final currentState = state;
    if (currentState is CurrencyPriceLoaded) {
      emit(const CurrencyPriceLoading());
    } else {
      emit(const CurrencyPriceLoading());
    }

    final result = await _getWalletBalanceUseCase(GetWalletBalanceParams(
      currency: event.currency,
      walletType: event.walletType,
    ));

    result.fold(
      (failure) => emit(CurrencyPriceError(message: failure.message)),
      (balance) {
        if (currentState is CurrencyPriceLoaded &&
            currentState.currency == event.currency &&
            currentState.walletType == event.walletType) {
          // Preserve existing price, add balance
          emit(currentState.copyWith(balance: balance));
        } else {
          // No existing price data, just show balance with 0 price
          emit(CurrencyPriceLoaded(
            price: 0.0,
            balance: balance,
            currency: event.currency,
            walletType: event.walletType,
          ));
        }
      },
    );
  }

  Future<void> _onResetCurrencyData(
    ResetCurrencyData event,
    Emitter<CurrencyPriceState> emit,
  ) async {
    emit(const CurrencyPriceInitial());
  }
}
