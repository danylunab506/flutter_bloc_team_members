import '../datasources/team_member_local_datasource.dart';
import '../../domain/entities/team_member.dart';
import '../../domain/repositories/team_member_repository.dart';

class TeamMemberRepositoryImpl implements TeamMemberRepository {
  final TeamMemberLocalDatasource datasource;

  // In-memory cache so removals persist across calls without reloading the JSON
  List<TeamMember>? _cache;

  TeamMemberRepositoryImpl(this.datasource);

  @override
  Future<List<TeamMember>> getTeamMembers() async {
    _cache = await datasource.getTeamMembers();
    return _cache!;
  }

  @override
  Future<List<TeamMember>> removeTeamMember(String id) async {
    _cache = (_cache ?? []).where((m) => m.id != id).toList();
    return _cache!;
  }
}
