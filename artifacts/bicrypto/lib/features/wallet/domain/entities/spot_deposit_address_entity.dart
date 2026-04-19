import 'package:equatable/equatable.dart';

class SpotDepositAddressEntity extends Equatable {
  const SpotDepositAddressEntity({
    required this.address,
    this.tag,
    required this.network,
    required this.currency,
    required this.trx,
  });

  final String address;
  final String? tag;
  final String network;
  final String currency;
  final bool trx;

  @override
  List<Object?> get props => [address, tag, network, currency, trx];

  SpotDepositAddressEntity copyWith({
    String? address,
    String? tag,
    String? network,
    String? currency,
    bool? trx,
  }) {
    return SpotDepositAddressEntity(
      address: address ?? this.address,
      tag: tag ?? this.tag,
      network: network ?? this.network,
      currency: currency ?? this.currency,
      trx: trx ?? this.trx,
    );
  }
}
