import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/transaction_entity.dart';

abstract class TransactionRepository {
  /// Get transactions with optional filtering and pagination
  Future<Either<Failure, TransactionListEntity>> getTransactions({
    TransactionFilterEntity? filter,
    int page = 1,
    int pageSize = 20,
  });

  /// Get a specific transaction by ID
  Future<Either<Failure, TransactionEntity>> getTransactionById(String id);

  /// Get transactions for a specific wallet
  Future<Either<Failure, TransactionListEntity>> getTransactionsByWallet({
    required String walletId,
    int page = 1,
    int pageSize = 20,
  });

  /// Get transactions by type
  Future<Either<Failure, TransactionListEntity>> getTransactionsByType({
    required TransactionType type,
    int page = 1,
    int pageSize = 20,
  });

  /// Get transactions by status
  Future<Either<Failure, TransactionListEntity>> getTransactionsByStatus({
    required TransactionStatus status,
    int page = 1,
    int pageSize = 20,
  });

  /// Search transactions
  Future<Either<Failure, TransactionListEntity>> searchTransactions({
    required String query,
    int page = 1,
    int pageSize = 20,
  });

  /// Get transaction statistics
  Future<Either<Failure, Map<String, dynamic>>> getTransactionStats();

  /// Refresh transactions from server
  Future<Either<Failure, TransactionListEntity>> refreshTransactions({
    TransactionFilterEntity? filter,
    int page = 1,
    int pageSize = 20,
  });
}
