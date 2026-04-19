import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../../../core/errors/failures.dart';
import '../../../../../../core/usecases/usecase.dart';
import '../repositories/ecommerce_repository.dart';

@injectable
class DownloadDigitalProductUseCase implements UseCase<String, String> {
  final EcommerceRepository repository;

  const DownloadDigitalProductUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(String orderItemId) async {
    return await repository.downloadDigitalProduct(orderItemId);
  }
}
