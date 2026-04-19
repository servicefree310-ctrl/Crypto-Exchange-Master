import 'package:equatable/equatable.dart';

class IcoBlockchainEntity extends Equatable {
  const IcoBlockchainEntity({
    required this.id,
    required this.name,
    required this.symbol,
    required this.chainId,
    this.icon,
    this.isActive = true,
    this.explorerUrl,
    this.rpcUrl,
  });

  final String id;
  final String name;
  final String symbol;
  final String chainId;
  final String? icon;
  final bool isActive;
  final String? explorerUrl;
  final String? rpcUrl;

  @override
  List<Object?> get props => [
        id,
        name,
        symbol,
        chainId,
        icon,
        isActive,
        explorerUrl,
        rpcUrl,
      ];
}
