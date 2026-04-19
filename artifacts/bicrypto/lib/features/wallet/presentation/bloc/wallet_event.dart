part of 'wallet_bloc.dart';

abstract class WalletEvent extends Equatable {
  const WalletEvent();

  @override
  List<Object?> get props => [];
}

// Get all wallets
class GetWalletsEvent extends WalletEvent {
  const GetWalletsEvent();
}

// Get wallets by type
class GetWalletsByTypeEvent extends WalletEvent {
  final WalletType type;

  const GetWalletsByTypeEvent(this.type);

  @override
  List<Object> get props => [type];
}

// Get specific wallet
class GetWalletEvent extends WalletEvent {
  final WalletType type;
  final String currency;

  const GetWalletEvent({
    required this.type,
    required this.currency,
  });

  @override
  List<Object> get props => [type, currency];
}

// Get wallet by ID
class GetWalletByIdEvent extends WalletEvent {
  final String walletId;

  const GetWalletByIdEvent(this.walletId);

  @override
  List<Object> get props => [walletId];
}

// Get wallet performance data
class GetWalletPerformanceEvent extends WalletEvent {
  const GetWalletPerformanceEvent();
}

// Refresh wallets
class RefreshWalletsEvent extends WalletEvent {
  const RefreshWalletsEvent();
}

// Clear error state
class ClearWalletErrorEvent extends WalletEvent {
  const ClearWalletErrorEvent();
}

// Aliases for backward compatibility
typedef LoadWalletsEvent = GetWalletsEvent;
