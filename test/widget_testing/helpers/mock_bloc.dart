import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_bloc_team_members/features/team_members/presentation/bloc/team_members_bloc.dart';
import 'package:flutter_bloc_team_members/features/team_members/presentation/bloc/team_members_event.dart';
import 'package:flutter_bloc_team_members/features/team_members/presentation/bloc/team_members_state.dart';

class MockTeamMembersBloc
    extends MockBloc<TeamMembersEvent, TeamMembersState>
    implements TeamMembersBloc {}

void registerFallbacks() {
  registerFallbackValue(const TeamMembersInitial());
  registerFallbackValue(const TeamMembersLoadRequested());
}
