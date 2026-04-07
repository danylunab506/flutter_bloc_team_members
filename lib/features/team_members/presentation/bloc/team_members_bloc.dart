import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_team_members.dart';
import '../bloc/team_members_event.dart';
import '../bloc/team_members_state.dart';

class TeamMembersBloc extends Bloc<TeamMembersEvent, TeamMembersState> {
  final GetTeamMembers getTeamMembers;

  TeamMembersBloc({required this.getTeamMembers})
      : super(const TeamMembersInitial()) {
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

  void _onRemoveRequested(
    TeamMemberRemoveRequested event,
    Emitter<TeamMembersState> emit,
  ) {
    if (state is! TeamMembersLoaded) return;

    final current = (state as TeamMembersLoaded).members;
    final updated = current.where((m) => m.id != event.memberId).toList();
    if (updated.isEmpty) {
      emit(const TeamMembersEmpty());
    } else {
      emit(TeamMembersLoaded(updated));
    }
  }
}
