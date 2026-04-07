class TeamMembersEvent {
  const TeamMembersEvent();
}

class TeamMembersLoadRequested extends TeamMembersEvent {
  const TeamMembersLoadRequested();
}

class TeamMemberRemoveRequested extends TeamMembersEvent {
  final String memberId;

  const TeamMemberRemoveRequested(this.memberId);
}
