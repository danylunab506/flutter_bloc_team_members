import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_bloc_team_members/features/team_members/presentation/bloc/team_members_state.dart';
import 'package:flutter_bloc_team_members/features/team_members/presentation/widgets/removal_listener.dart';

import '../../../../helpers/mock_bloc.dart';
import '../../../../helpers/pump_app.dart';
import '../../../../helpers/team_member_factory.dart';

void main() {
  late MockTeamMembersBloc bloc;

  setUpAll(registerFallbacks);

  setUp(() => bloc = MockTeamMembersBloc());

  group('RemovalListener', () {
    testWidgets('renders the child correctly', (tester) async {
      when(() => bloc.state).thenReturn(const TeamMembersLoaded(tMembers));

      const childKey = Key('child');
      // pumpApp includes Scaffold, required for ScaffoldMessenger to work
      await tester.pumpApp(
        RemovalListener(child: const SizedBox(key: childKey)),
        bloc: bloc,
      );

      expect(find.byKey(childKey), findsOneWidget);
    });

    testWidgets('shows SnackBar when a member is removed', (tester) async {
      when(() => bloc.state)
          .thenReturn(const TeamMembersLoaded(tMembers));
      whenListen(
        bloc,
        Stream.fromIterable([
          const TeamMembersLoaded(tMembers),
          const TeamMembersLoaded([tMember]),
        ]),
      );

      await tester.pumpApp(
        RemovalListener(child: const SizedBox()),
        bloc: bloc,
      );
      await tester.pump();

      expect(find.text('Member removed from the team'), findsOneWidget);
    });

    testWidgets(
        'does NOT show SnackBar when the state change is not a removal',
        (tester) async {
      when(() => bloc.state).thenReturn(const TeamMembersLoading());
      whenListen(
        bloc,
        Stream.fromIterable([
          const TeamMembersLoading(),
          const TeamMembersLoaded(tMembers),
        ]),
      );

      await tester.pumpApp(
        RemovalListener(child: const SizedBox()),
        bloc: bloc,
      );
      await tester.pump();

      expect(find.text('Member removed from the team'), findsNothing);
    });

    testWidgets(
        'does NOT show SnackBar when Loaded → Empty (last member removed)',
        (tester) async {
      // RemovalListener only listens for Loaded → Loaded with fewer members.
      // When 0 remain, the bloc emits Empty, not Loaded — the listener does not fire.
      when(() => bloc.state)
          .thenReturn(const TeamMembersLoaded([tMember]));
      whenListen(
        bloc,
        Stream.fromIterable([
          const TeamMembersLoaded([tMember]),
          const TeamMembersEmpty(),
        ]),
      );

      await tester.pumpApp(
        RemovalListener(child: const SizedBox()),
        bloc: bloc,
      );
      await tester.pump();

      expect(find.text('Member removed from the team'), findsNothing);
    });
  });
}
