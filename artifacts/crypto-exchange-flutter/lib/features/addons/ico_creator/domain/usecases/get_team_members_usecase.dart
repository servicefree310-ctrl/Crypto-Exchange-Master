import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';

import '../../../../../../core/errors/failures.dart';
import '../repositories/creator_repository.dart';
import '../entities/team_member_entity.dart';

@injectable
class GetTeamMembersUseCase {
  const GetTeamMembersUseCase(this._repository);

  final CreatorRepository _repository;

  Future<Either<Failure, List<TeamMemberEntity>>> call(String tokenId) async {
    return _repository.getTeamMembers(tokenId);
  }
}
