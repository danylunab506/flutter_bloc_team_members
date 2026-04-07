import '../entities/team_member.dart';

abstract class TeamMemberRepository {
  Future<List<TeamMember>> getTeamMembers();
}
