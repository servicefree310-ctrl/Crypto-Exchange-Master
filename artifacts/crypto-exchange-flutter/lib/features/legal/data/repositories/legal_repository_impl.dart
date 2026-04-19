import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/legal_page_entity.dart';
import '../../domain/repositories/legal_repository.dart';
import '../datasources/legal_remote_datasource.dart';

@Injectable(as: LegalRepository)
class LegalRepositoryImpl implements LegalRepository {
  final LegalRemoteDataSource _remoteDataSource;

  const LegalRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, LegalPageEntity>> getLegalPage(String pageId) async {
    try {
      final legalPage = await _remoteDataSource.getLegalPage(pageId);
      return Right(legalPage);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
