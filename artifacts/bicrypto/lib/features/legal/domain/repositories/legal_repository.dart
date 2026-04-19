import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/legal_page_entity.dart';

abstract class LegalRepository {
  /// Get legal page content by pageId (privacy, terms, about, contact)
  Future<Either<Failure, LegalPageEntity>> getLegalPage(String pageId);
}
