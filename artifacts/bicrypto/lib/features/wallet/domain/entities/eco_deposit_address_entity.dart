import 'package:equatable/equatable.dart';

class EcoDepositAddressEntity extends Equatable {
  final String address;
  final String currency;
  final String chain;
  final String contractType;
  final String? network;
  final bool locked; // For NO_PERMIT tracking
  final String? id;
  final String? status;

  const EcoDepositAddressEntity({
    required this.address,
    required this.currency,
    required this.chain,
    required this.contractType,
    this.network,
    required this.locked,
    this.id,
    this.status,
  });

  bool get isPermitAddress => contractType == 'PERMIT';
  bool get isNoPermitAddress => contractType == 'NO_PERMIT';
  bool get isNativeAddress => contractType == 'NATIVE';

  bool get isLocked => locked && isNoPermitAddress;

  @override
  List<Object?> get props => [
        address,
        currency,
        chain,
        contractType,
        network,
        locked,
        id,
        status,
      ];

  EcoDepositAddressEntity copyWith({
    String? address,
    String? currency,
    String? chain,
    String? contractType,
    String? network,
    bool? locked,
    String? id,
    String? status,
  }) {
    return EcoDepositAddressEntity(
      address: address ?? this.address,
      currency: currency ?? this.currency,
      chain: chain ?? this.chain,
      contractType: contractType ?? this.contractType,
      network: network ?? this.network,
      locked: locked ?? this.locked,
      id: id ?? this.id,
      status: status ?? this.status,
    );
  }
}
