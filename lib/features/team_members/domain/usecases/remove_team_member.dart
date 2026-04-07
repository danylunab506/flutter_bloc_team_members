import '../entities/team_member.dart';
import '../repositories/team_member_repository.dart';

class RemoveTeamMember {
  final TeamMemberRepository repository;

  const RemoveTeamMember(this.repository);

  Future<List<TeamMember>> call(String id) => repository.removeTeamMember(id);
}
