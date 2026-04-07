import '../datasources/team_member_local_datasource.dart';
import '../../domain/entities/team_member.dart';
import '../../domain/repositories/team_member_repository.dart';

class TeamMemberRepositoryImpl implements TeamMemberRepository {
  final TeamMemberLocalDatasource datasource;

  const TeamMemberRepositoryImpl(this.datasource);

  @override
  Future<List<TeamMember>> getTeamMembers() => datasource.getTeamMembers();
}
