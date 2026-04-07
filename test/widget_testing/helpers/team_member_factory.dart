import 'package:flutter_bloc_team_members/features/team_members/domain/entities/team_member.dart';

const tMember = TeamMember(
  id: '1',
  firstName: 'Ana',
  lastName: 'Smith',
  title: 'Engineer',
  avatar: 'https://example.com/a.jpg',
  bio: 'Short bio for testing.',
);

const tMemberLongBio = TeamMember(
  id: '2',
  firstName: 'Luis',
  lastName: 'Johnson',
  title: 'Designer',
  avatar: 'https://example.com/b.jpg',
  bio:
      'This is a very long biography that exceeds one hundred characters and should be truncated with ellipsis at the end.',
);

const tMemberNoBio = TeamMember(
  id: '3',
  firstName: 'Sofia',
  lastName: 'Lopez',
  title: 'PM',
  avatar: 'https://example.com/c.jpg',
  bio: '',
);

const tMembers = [tMember, tMemberLongBio];
