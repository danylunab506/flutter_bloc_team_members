import '../entities/team_member.dart';
import '../repositories/team_member_repository.dart';

class GetTeamMembers {
  final TeamMemberRepository repository;

  const GetTeamMembers(this.repository);

  Future<List<TeamMember>> call() => repository.getTeamMembers();
}
