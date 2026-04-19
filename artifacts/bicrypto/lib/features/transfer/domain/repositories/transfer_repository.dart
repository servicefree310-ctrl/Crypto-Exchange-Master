import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/transfer_request_entity.dart';
import '../entities/transfer_response_entity.dart';
import '../entities/transfer_option_entity.dart';
import '../entities/currency_option_entity.dart';

abstract class TransferRepository {
  /// Get available wallet types for transfers
  Future<Either<Failure, List<TransferOptionEntity>>> getTransferOptions();

  /// Get currencies for specific wallet type and optional target wallet type
  Future<Either<Failure, List<CurrencyOptionEntity>>> getTransferCurrencies({
    required String walletType,
    String? targetWalletType,
  });

  /// Get wallet balance currencies for specific wallet type
  Future<Either<Failure, List<CurrencyOptionEntity>>> getWalletBalance({
    required String walletType,
  });

  /// Validate recipient UUID
  Future<Either<Failure, Map<String, dynamic>>> validateRecipient(String uuid);

  /// Create a transfer transaction
  Future<Either<Failure, TransferResponseEntity>> createTransfer(
    TransferRequestEntity request,
  );
}
