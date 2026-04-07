import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_team_members.dart';
import '../../domain/usecases/remove_team_member.dart';
import 'team_members_event.dart';
import 'team_members_state.dart';

class TeamMembersBloc extends Bloc<TeamMembersEvent, TeamMembersState> {
  final GetTeamMembers getTeamMembers;
  final RemoveTeamMember removeTeamMember;

  TeamMembersBloc({
    required this.getTeamMembers,
    required this.removeTeamMember,
  }) : super(const TeamMembersInitial()) {
    on<TeamMembersLoadRequested>(_onLoadRequested);
    on<TeamMemberRemoveRequested>(_onRemoveRequested);
  }

  Future<void> _onLoadRequested(
    TeamMembersLoadRequested event,
    Emitter<TeamMembersState> emit,
  ) async {
    emit(const TeamMembersLoading());
    try {
      final members = await getTeamMembers();
      if (members.isEmpty) {
        emit(const TeamMembersEmpty());
      } else {
        emit(TeamMembersLoaded(members));
      }
    } catch (e) {
      emit(TeamMembersError(e.toString()));
    }
  }

  Future<void> _onRemoveRequested(
    TeamMemberRemoveRequested event,
    Emitter<TeamMembersState> emit,
  ) async {
    if (state is! TeamMembersLoaded) return;

    try {
      final updated = await removeTeamMember(event.memberId);
      if (updated.isEmpty) {
        emit(const TeamMembersEmpty());
      } else {
        emit(TeamMembersLoaded(updated));
      }
    } catch (e) {
      emit(TeamMembersError(e.toString()));
    }
  }
}
