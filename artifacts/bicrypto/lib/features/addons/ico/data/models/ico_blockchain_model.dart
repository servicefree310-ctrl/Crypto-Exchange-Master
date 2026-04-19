import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/ico_blockchain_entity.dart';

part 'ico_blockchain_model.freezed.dart';
part 'ico_blockchain_model.g.dart';

@freezed
class IcoBlockchainModel with _$IcoBlockchainModel {
  const IcoBlockchainModel._();

  const factory IcoBlockchainModel({
    required String id,
    required String name,
    required String symbol,
    required String chainId,
    String? icon,
    @Default(true) bool isActive,
    String? explorerUrl,
    String? rpcUrl,
  }) = _IcoBlockchainModel;

  factory IcoBlockchainModel.fromJson(Map<String, dynamic> json) =>
      _$IcoBlockchainModelFromJson(json);

  IcoBlockchainEntity toEntity() {
    return IcoBlockchainEntity(
      id: id,
      name: name,
      symbol: symbol,
      chainId: chainId,
      icon: icon,
      isActive: isActive,
      explorerUrl: explorerUrl,
      rpcUrl: rpcUrl,
    );
  }
}
