import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_bloc_team_members/features/team_members/domain/entities/team_member.dart';
import 'package:flutter_bloc_team_members/features/team_members/domain/usecases/get_team_members.dart';
import 'package:flutter_bloc_team_members/features/team_members/presentation/bloc/team_members_bloc.dart';
import 'package:flutter_bloc_team_members/features/team_members/presentation/bloc/team_members_event.dart';
import 'package:flutter_bloc_team_members/features/team_members/presentation/bloc/team_members_state.dart';

class MockGetTeamMembers extends Mock implements GetTeamMembers {}

const _memberA = TeamMember(
  id: '1',
  firstName: 'Ana',
  lastName: 'Smith',
  title: 'Engineer',
  avatar: 'https://example.com/a.jpg',
  bio: 'Short bio',
);

const _memberB = TeamMember(
  id: '2',
  firstName: 'Luis',
  lastName: 'Johnson',
  title: 'Designer',
  avatar: 'https://example.com/b.jpg',
  bio: 'Another bio',
);

void main() {
  late MockGetTeamMembers mockGetTeamMembers;

  setUp(() {
    mockGetTeamMembers = MockGetTeamMembers();
  });

  TeamMembersBloc buildBloc() =>
      TeamMembersBloc(getTeamMembers: mockGetTeamMembers);

  group('TeamMembersLoadRequested', () {
    blocTest<TeamMembersBloc, TeamMembersState>(
      'emits [Loading, Loaded] when the use case returns members',
      build: buildBloc,
      setUp: () {
        when(() => mockGetTeamMembers()).thenAnswer(
          (_) async => [_memberA, _memberB],
        );
      },
      act: (bloc) => bloc.add(const TeamMembersLoadRequested()),
      expect: () => [
        const TeamMembersLoading(),
        const TeamMembersLoaded([_memberA, _memberB]),
      ],
      verify: (_) => verify(() => mockGetTeamMembers()).called(1),
    );

    blocTest<TeamMembersBloc, TeamMembersState>(
      'emits [Loading, Empty] when the use case returns an empty list',
      build: buildBloc,
      setUp: () {
        when(() => mockGetTeamMembers()).thenAnswer((_) async => []);
      },
      act: (bloc) => bloc.add(const TeamMembersLoadRequested()),
      expect: () => [
        const TeamMembersLoading(),
        const TeamMembersEmpty(),
      ],
    );

    blocTest<TeamMembersBloc, TeamMembersState>(
      'emits [Loading, Error] when the use case throws an exception',
      build: buildBloc,
      setUp: () {
        when(() => mockGetTeamMembers()).thenThrow(Exception('Network error'));
      },
      act: (bloc) => bloc.add(const TeamMembersLoadRequested()),
      expect: () => [
        const TeamMembersLoading(),
        isA<TeamMembersError>(),
      ],
    );

    blocTest<TeamMembersBloc, TeamMembersState>(
      'error message reflects the thrown exception',
      build: buildBloc,
      setUp: () {
        when(() => mockGetTeamMembers())
            .thenThrow(Exception('Network error'));
      },
      act: (bloc) => bloc.add(const TeamMembersLoadRequested()),
      expect: () => [
        const TeamMembersLoading(),
        isA<TeamMembersError>().having(
          (s) => s.message,
          'message',
          contains('Network error'),
        ),
      ],
    );
  });

  group('TeamMemberRemoveRequested', () {
    blocTest<TeamMembersBloc, TeamMembersState>(
      'emits [Loaded] without the removed member',
      build: buildBloc,
      seed: () => const TeamMembersLoaded([_memberA, _memberB]),
      act: (bloc) => bloc.add(const TeamMemberRemoveRequested('1')),
      expect: () => [
        const TeamMembersLoaded([_memberB]),
      ],
    );

    blocTest<TeamMembersBloc, TeamMembersState>(
      'emits [Empty] when the last member is removed',
      build: buildBloc,
      seed: () => const TeamMembersLoaded([_memberA]),
      act: (bloc) => bloc.add(const TeamMemberRemoveRequested('1')),
      expect: () => [
        const TeamMembersEmpty(),
      ],
    );

    blocTest<TeamMembersBloc, TeamMembersState>(
      'emits nothing when the current state is not Loaded',
      build: buildBloc,
      seed: () => const TeamMembersLoading(),
      act: (bloc) => bloc.add(const TeamMemberRemoveRequested('1')),
      expect: () => [],
    );

    blocTest<TeamMembersBloc, TeamMembersState>(
      'emits nothing when the id does not exist in the list',
      build: buildBloc,
      seed: () => const TeamMembersLoaded([_memberA, _memberB]),
      act: (bloc) =>
          bloc.add(const TeamMemberRemoveRequested('id-inexistente')),
      // BLoC discards the emission because the resulting state is identical to the current one (Equatable)
      expect: () => [],
    );
  });
}
