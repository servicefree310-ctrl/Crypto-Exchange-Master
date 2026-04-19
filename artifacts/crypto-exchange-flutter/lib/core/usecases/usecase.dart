import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../errors/failures.dart';

/// Base use case class following Clean Architecture principles
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// Use case for operations that don't require parameters
class NoParams extends Equatable {
  const NoParams();

  @override
  List<Object> get props => [];
}
