import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/repositories/currency_price_repository.dart';
import '../datasources/currency_price_remote_datasource.dart';

@Injectable(as: CurrencyPriceRepository)
class CurrencyPriceRepositoryImpl implements CurrencyPriceRepository {
  final CurrencyPriceRemoteDataSource _remoteDataSource;

  const CurrencyPriceRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, double>> getCurrencyPrice({
    required String currency,
    required String walletType,
  }) async {
    try {
      final price = await _remoteDataSource.getCurrencyPrice(
        currency: currency,
        walletType: walletType,
      );
      return Right(price);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, double>> getWalletBalance({
    required String currency,
    required String walletType,
  }) async {
    try {
      final balance = await _remoteDataSource.getWalletBalance(
        currency: currency,
        walletType: walletType,
      );
      return Right(balance);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
