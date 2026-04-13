import 'package:get_it/get_it.dart';

import '../../../features/team_members/data/datasources/team_member_local_datasource.dart';
import '../../../features/team_members/data/repositories/team_member_repository_impl.dart';
import '../../../features/team_members/domain/repositories/team_member_repository.dart';
import '../../../features/team_members/domain/usecases/get_team_members.dart';
import '../../../features/team_members/domain/usecases/remove_team_member.dart';
import '../../../features/team_members/presentation/bloc/team_members_bloc.dart';

void registerTeamMembersDependencies(GetIt getIt) {
  getIt.registerLazySingleton<TeamMemberLocalDatasource>(
    () => TeamMemberLocalDatasourceImpl(),
  );

  getIt.registerLazySingleton<TeamMemberRepository>(
    () => TeamMemberRepositoryImpl(getIt<TeamMemberLocalDatasource>()),
  );

  getIt.registerLazySingleton(() => GetTeamMembers(getIt<TeamMemberRepository>()));
  getIt.registerLazySingleton(() => RemoveTeamMember(getIt<TeamMemberRepository>()));

  getIt.registerFactory(() => TeamMembersBloc(
        getTeamMembers: getIt<GetTeamMembers>(),
        removeTeamMember: getIt<RemoveTeamMember>(),
      ));
}
