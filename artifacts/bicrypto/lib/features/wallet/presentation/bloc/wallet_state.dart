part of 'wallet_bloc.dart';

abstract class WalletState extends Equatable {
  const WalletState();

  @override
  List<Object?> get props => [];
}

// Initial state
class WalletInitial extends WalletState {
  const WalletInitial();
}

// Loading state
class WalletLoading extends WalletState {
  const WalletLoading();
}

// Loaded state with wallets and performance data
class WalletLoaded extends WalletState {
  final Map<WalletType, List<WalletEntity>> wallets;
  final Map<String, dynamic>? performance;
  final WalletType? selectedType;

  const WalletLoaded({
    required this.wallets,
    this.performance,
    this.selectedType,
  });

  @override
  List<Object?> get props => [wallets, performance, selectedType];

  WalletLoaded copyWith({
    Map<WalletType, List<WalletEntity>>? wallets,
    Map<String, dynamic>? performance,
    WalletType? selectedType,
  }) {
    return WalletLoaded(
      wallets: wallets ?? this.wallets,
      performance: performance ?? this.performance,
      selectedType: selectedType ?? this.selectedType,
    );
  }

  // Helper getters
  List<WalletEntity> get allWallets =>
      wallets.values.expand((list) => list).toList();

  List<WalletEntity> getWalletsByType(WalletType type) => wallets[type] ?? [];

  WalletEntity? getWallet(WalletType type, String currency) {
    final typeWallets = wallets[type] ?? [];
    try {
      return typeWallets.firstWhere((wallet) => wallet.currency == currency);
    } catch (e) {
      return null;
    }
  }

  WalletEntity? getWalletById(String walletId) {
    try {
      return allWallets.firstWhere((wallet) => wallet.id == walletId);
    } catch (e) {
      return null;
    }
  }

  double get totalBalanceUSD {
    if (performance == null) {
      // If no performance data, calculate from wallet balances
      return totalAvailableBalance;
    }
    // Use 'today' value from PnL data which represents total balance in USD
    return (performance!['today'] as num?)?.toDouble() ?? totalAvailableBalance;
  }

  // Alias for totalBalanceUSD
  double get totalBalance => totalBalanceUSD;

  double get totalAvailableBalance {
    double total = 0.0;
    for (final walletList in wallets.values) {
      for (final wallet in walletList) {
        total += wallet.balance;
      }
    }
    return total;
  }

  double get totalInOrder {
    double total = 0.0;
    for (final walletList in wallets.values) {
      for (final wallet in walletList) {
        total += wallet.inOrder;
      }
    }
    return total;
  }

  double get totalPnL {
    if (performance == null) return 0.0;
    return (performance!['pnl'] as num?)?.toDouble() ?? 0.0;
  }

  double get totalPnLPercentage {
    if (performance == null) return 0.0;

    // Calculate percentage from today and yesterday values
    final today = (performance!['today'] as num?)?.toDouble() ?? 0.0;
    final yesterday = (performance!['yesterday'] as num?)?.toDouble() ?? 1.0;

    if (yesterday > 0) {
      return ((today - yesterday) / yesterday) * 100;
    }
    return 0.0;
  }
}

// Single wallet loaded state
class WalletSingleLoaded extends WalletState {
  final WalletEntity wallet;

  const WalletSingleLoaded(this.wallet);

  @override
  List<Object> get props => [wallet];
}

// Error state
class WalletError extends WalletState {
  final String message;

  const WalletError(this.message);

  @override
  List<Object> get props => [message];
}

// Aliases for backward compatibility
typedef WalletLoadingState = WalletLoading;
typedef WalletLoadedState = WalletLoaded;
typedef WalletErrorState = WalletError;
