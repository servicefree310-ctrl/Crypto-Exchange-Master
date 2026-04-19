import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../../../core/errors/failures.dart';
import '../../../../../../core/usecases/usecase.dart';
import '../repositories/ecommerce_repository.dart';

@injectable
class TrackOrderUseCase implements UseCase<dynamic, String> {
  final EcommerceRepository repository;

  const TrackOrderUseCase(this.repository);

  @override
  Future<Either<Failure, dynamic>> call(String orderId) async {
    return await repository.trackOrder(orderId);
  }
}
