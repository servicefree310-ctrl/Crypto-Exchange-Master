import 'package:equatable/equatable.dart';

class TransferOptionEntity extends Equatable {
  const TransferOptionEntity({
    required this.id,
    required this.name,
  });

  final String id; // FIAT, SPOT, ECO, FUTURES
  final String name; // Display name

  @override
  List<Object?> get props => [id, name];

  TransferOptionEntity copyWith({
    String? id,
    String? name,
  }) {
    return TransferOptionEntity(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }
}
