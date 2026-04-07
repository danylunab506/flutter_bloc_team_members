import 'package:equatable/equatable.dart';

import '../../domain/entities/team_member.dart';

sealed class TeamMembersState extends Equatable {
  const TeamMembersState();

  @override
  List<Object> get props => [];
}

class TeamMembersInitial extends TeamMembersState {
  const TeamMembersInitial();
}

class TeamMembersLoading extends TeamMembersState {
  const TeamMembersLoading();
}

class TeamMembersLoaded extends TeamMembersState {
  final List<TeamMember> members;

  const TeamMembersLoaded(this.members);

  @override
  List<Object> get props => [members];
}

class TeamMembersEmpty extends TeamMembersState {
  const TeamMembersEmpty();
}

class TeamMembersError extends TeamMembersState {
  final String message;

  const TeamMembersError(this.message);

  @override
  List<Object> get props => [message];
}
