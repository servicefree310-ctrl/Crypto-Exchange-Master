import 'dart:developer' as dev;

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/transaction_remote_datasource.dart';

@Injectable(as: TransactionRepository)
class TransactionRepositoryImpl implements TransactionRepository {
  const TransactionRepositoryImpl(this._remoteDataSource);

  final TransactionRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, TransactionListEntity>> getTransactions({
    TransactionFilterEntity? filter,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      dev.log(
          '🔄 TRANSACTION_REPO: Getting transactions - page: $page, pageSize: $pageSize');

      final transactionListModel = await _remoteDataSource.getTransactions(
        filter: filter,
        page: page,
        pageSize: pageSize,
      );

      final transactionListEntity = transactionListModel.toEntity();

      dev.log(
          '✅ TRANSACTION_REPO: Successfully retrieved ${transactionListEntity.transactions.length} transactions');

      return Right(transactionListEntity);
    } on NetworkException catch (e) {
      dev.log('❌ TRANSACTION_REPO: Network error - ${e.message}');
      return Left(NetworkFailure(e.message ?? 'Network error occurred'));
    } on AuthException catch (e) {
      dev.log('❌ TRANSACTION_REPO: Auth error - ${e.message}');
      return Left(AuthFailure(e.message ?? 'Authentication failed'));
    } on NotFoundException catch (e) {
      dev.log('❌ TRANSACTION_REPO: Not found error - ${e.message}');
      return Left(NotFoundFailure(e.message ?? 'Transactions not found'));
    } on ServerException catch (e) {
      dev.log('❌ TRANSACTION_REPO: Server error - ${e.message}');
      return Left(ServerFailure(e.message ?? 'Server error occurred'));
    } catch (e) {
      dev.log('❌ TRANSACTION_REPO: Unexpected error - $e');
      return Left(UnknownFailure('An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, TransactionEntity>> getTransactionById(
      String id) async {
    try {
      dev.log('🔄 TRANSACTION_REPO: Getting transaction by ID - $id');

      final transactionModel = await _remoteDataSource.getTransactionById(id);
      final transactionEntity = transactionModel.toEntity();

      dev.log(
          '✅ TRANSACTION_REPO: Successfully retrieved transaction - ${transactionEntity.id}');

      return Right(transactionEntity);
    } on NetworkException catch (e) {
      dev.log('❌ TRANSACTION_REPO: Network error - ${e.message}');
      return Left(NetworkFailure(e.message ?? 'Network error occurred'));
    } on AuthException catch (e) {
      dev.log('❌ TRANSACTION_REPO: Auth error - ${e.message}');
      return Left(AuthFailure(e.message ?? 'Authentication failed'));
    } on NotFoundException catch (e) {
      dev.log('❌ TRANSACTION_REPO: Not found error - ${e.message}');
      return Left(NotFoundFailure(e.message ?? 'Transaction not found'));
    } on ServerException catch (e) {
      dev.log('❌ TRANSACTION_REPO: Server error - ${e.message}');
      return Left(ServerFailure(e.message ?? 'Server error occurred'));
    } catch (e) {
      dev.log('❌ TRANSACTION_REPO: Unexpected error - $e');
      return Left(UnknownFailure('An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, TransactionListEntity>> getTransactionsByWallet({
    required String walletId,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      dev.log('🔄 TRANSACTION_REPO: Getting transactions for wallet - $walletId');

      final filter = TransactionFilterEntity(walletType: walletId);

      return await getTransactions(
        filter: filter,
        page: page,
        pageSize: pageSize,
      );
    } catch (e) {
      dev.log('❌ TRANSACTION_REPO: Error getting wallet transactions - $e');
      return Left(UnknownFailure('Failed to get wallet transactions: $e'));
    }
  }

  @override
  Future<Either<Failure, TransactionListEntity>> getTransactionsByType({
    required TransactionType type,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      dev.log('🔄 TRANSACTION_REPO: Getting transactions by type - ${type.name}');

      final filter = TransactionFilterEntity(type: type);

      return await getTransactions(
        filter: filter,
        page: page,
        pageSize: pageSize,
      );
    } catch (e) {
      dev.log('❌ TRANSACTION_REPO: Error getting transactions by type - $e');
      return Left(UnknownFailure('Failed to get transactions by type: $e'));
    }
  }

  @override
  Future<Either<Failure, TransactionListEntity>> getTransactionsByStatus({
    required TransactionStatus status,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      dev.log(
          '🔄 TRANSACTION_REPO: Getting transactions by status - ${status.name}');

      final filter = TransactionFilterEntity(status: status);

      return await getTransactions(
        filter: filter,
        page: page,
        pageSize: pageSize,
      );
    } catch (e) {
      dev.log('❌ TRANSACTION_REPO: Error getting transactions by status - $e');
      return Left(UnknownFailure('Failed to get transactions by status: $e'));
    }
  }

  @override
  Future<Either<Failure, TransactionListEntity>> searchTransactions({
    required String query,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      dev.log('🔄 TRANSACTION_REPO: Searching transactions - query: $query');

      final transactionListModel = await _remoteDataSource.searchTransactions(
        query: query,
        page: page,
        pageSize: pageSize,
      );

      final transactionListEntity = transactionListModel.toEntity();

      dev.log(
          '✅ TRANSACTION_REPO: Successfully searched ${transactionListEntity.transactions.length} transactions');

      return Right(transactionListEntity);
    } on NetworkException catch (e) {
      dev.log('❌ TRANSACTION_REPO: Network error - ${e.message}');
      return Left(NetworkFailure(e.message ?? 'Network error occurred'));
    } on AuthException catch (e) {
      dev.log('❌ TRANSACTION_REPO: Auth error - ${e.message}');
      return Left(AuthFailure(e.message ?? 'Authentication failed'));
    } on NotFoundException catch (e) {
      dev.log('❌ TRANSACTION_REPO: Not found error - ${e.message}');
      return Left(NotFoundFailure(e.message ?? 'No transactions found'));
    } on ServerException catch (e) {
      dev.log('❌ TRANSACTION_REPO: Server error - ${e.message}');
      return Left(ServerFailure(e.message ?? 'Server error occurred'));
    } catch (e) {
      dev.log('❌ TRANSACTION_REPO: Unexpected error - $e');
      return Left(UnknownFailure('An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getTransactionStats() async {
    try {
      dev.log('🔄 TRANSACTION_REPO: Getting transaction stats');

      final stats = await _remoteDataSource.getTransactionStats();

      dev.log('✅ TRANSACTION_REPO: Successfully retrieved transaction stats');

      return Right(stats);
    } on NetworkException catch (e) {
      dev.log('❌ TRANSACTION_REPO: Network error - ${e.message}');
      return Left(NetworkFailure(e.message ?? 'Network error occurred'));
    } on AuthException catch (e) {
      dev.log('❌ TRANSACTION_REPO: Auth error - ${e.message}');
      return Left(AuthFailure(e.message ?? 'Authentication failed'));
    } on NotFoundException catch (e) {
      dev.log('❌ TRANSACTION_REPO: Not found error - ${e.message}');
      return Left(NotFoundFailure(e.message ?? 'Stats not found'));
    } on ServerException catch (e) {
      dev.log('❌ TRANSACTION_REPO: Server error - ${e.message}');
      return Left(ServerFailure(e.message ?? 'Server error occurred'));
    } catch (e) {
      dev.log('❌ TRANSACTION_REPO: Unexpected error - $e');
      return Left(UnknownFailure('An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, TransactionListEntity>> refreshTransactions({
    TransactionFilterEntity? filter,
    int page = 1,
    int pageSize = 20,
  }) async {
    // For now, refresh is the same as get
    // In the future, this could implement cache invalidation
    return await getTransactions(
      filter: filter,
      page: page,
      pageSize: pageSize,
    );
  }
}
