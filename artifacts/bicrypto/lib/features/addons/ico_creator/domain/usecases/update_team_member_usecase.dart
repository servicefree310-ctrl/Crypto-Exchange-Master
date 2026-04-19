import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';

import '../../../../../../core/errors/failures.dart';
import '../repositories/creator_repository.dart';
import '../entities/team_member_entity.dart';

@injectable
class UpdateTeamMemberUseCase {
  const UpdateTeamMemberUseCase(this._repo);

  final CreatorRepository _repo;

  Future<Either<Failure, void>> call(
      String tokenId, TeamMemberEntity member) async {
    return _repo.updateTeamMember(tokenId, member);
  }
}
