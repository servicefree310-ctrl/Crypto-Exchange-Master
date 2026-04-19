import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failures.dart';
import '../../domain/entities/discount_entity.dart';
import '../../domain/repositories/discount_repository.dart';
import '../datasources/discount_remote_datasource.dart';
import '../models/discount_model.dart';

@Injectable(as: DiscountRepository)
class DiscountRepositoryImpl implements DiscountRepository {
  const DiscountRepositoryImpl(
    this._remoteDataSource,
  );

  final DiscountRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, DiscountEntity>> validateDiscount(String code) async {
    try {
      final discountModel = await _remoteDataSource.validateDiscount(code);
      final discountEntity = discountModel.toEntity();

      return Right(discountEntity);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
