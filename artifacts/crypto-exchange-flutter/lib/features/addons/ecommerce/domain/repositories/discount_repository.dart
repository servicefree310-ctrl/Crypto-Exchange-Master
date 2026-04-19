import 'package:dartz/dartz.dart';
import '../../../../../core/error/failures.dart';
import '../entities/discount_entity.dart';

/// Repository interface for discount/coupon operations
abstract class DiscountRepository {
  /// Validates a discount code and returns discount information
  Future<Either<Failure, DiscountEntity>> validateDiscount(String code);
}
