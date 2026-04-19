import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/kyc_repository.dart';

@injectable
class UploadKycDocumentUseCase
    implements UseCase<String, UploadKycDocumentParams> {
  final KycRepository repository;

  const UploadKycDocumentUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(UploadKycDocumentParams params) async {
    return await repository.uploadKycDocument(
      filePath: params.filePath,
      oldPath: params.oldPath,
    );
  }
}

class UploadKycDocumentParams extends Equatable {
  final String filePath;
  final String? oldPath;

  const UploadKycDocumentParams({
    required this.filePath,
    this.oldPath,
  });

  @override
  List<Object?> get props => [filePath, oldPath];
}
