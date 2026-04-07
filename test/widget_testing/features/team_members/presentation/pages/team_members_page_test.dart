import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_bloc_team_members/core/widgets/loading_widget.dart';
import 'package:flutter_bloc_team_members/features/team_members/presentation/bloc/team_members_state.dart';
import 'package:flutter_bloc_team_members/features/team_members/presentation/pages/team_members_page.dart';
import 'package:flutter_bloc_team_members/features/team_members/presentation/widgets/empty_members_widget.dart';
import 'package:flutter_bloc_team_members/features/team_members/presentation/widgets/team_member_item.dart';

import '../../../../helpers/mock_bloc.dart';
import '../../../../helpers/pump_app.dart';
import '../../../../helpers/team_member_factory.dart';

void main() {
  late MockTeamMembersBloc bloc;

  setUpAll(registerFallbacks);

  setUp(() => bloc = MockTeamMembersBloc());

  group('TeamMembersPage', () {
    testWidgets('shows the AppBar with the correct title', (tester) async {
      when(() => bloc.state).thenReturn(const TeamMembersInitial());

      await tester.pumpPage(const TeamMembersPage(), bloc: bloc);

      expect(find.text('Team Members'), findsOneWidget);
    });

    testWidgets('shows LoadingWidget when state is Loading',
        (tester) async {
      when(() => bloc.state).thenReturn(const TeamMembersLoading());

      await tester.pumpPage(const TeamMembersPage(), bloc: bloc);
      await tester.pump();

      expect(find.byType(LoadingWidget), findsOneWidget);
    });

    testWidgets('shows the TeamMemberItem list when state is Loaded',
        (tester) async {
      when(() => bloc.state)
          .thenReturn(const TeamMembersLoaded(tMembers));

      await tester.pumpPage(const TeamMembersPage(), bloc: bloc);
      await tester.pump();

      expect(find.byType(TeamMemberItem), findsNWidgets(tMembers.length));
    });

    testWidgets('shows the name of each member in the list', (tester) async {
      when(() => bloc.state)
          .thenReturn(const TeamMembersLoaded(tMembers));

      await tester.pumpPage(const TeamMembersPage(), bloc: bloc);
      await tester.pump();

      for (final member in tMembers) {
        expect(
          find.text('${member.firstName} ${member.lastName}'),
          findsOneWidget,
        );
      }
    });

    testWidgets('shows MemberCountBadge with the count when state is Loaded',
        (tester) async {
      when(() => bloc.state)
          .thenReturn(const TeamMembersLoaded(tMembers));

      await tester.pumpPage(const TeamMembersPage(), bloc: bloc);
      await tester.pump();

      expect(find.text('${tMembers.length}'), findsOneWidget);
    });

    testWidgets('shows EmptyMembersWidget when state is Empty',
        (tester) async {
      when(() => bloc.state).thenReturn(const TeamMembersEmpty());

      await tester.pumpPage(const TeamMembersPage(), bloc: bloc);
      await tester.pump();

      expect(find.byType(EmptyMembersWidget), findsOneWidget);
      expect(find.text('No team members found'), findsOneWidget);
    });

    testWidgets('shows the error view when state is Error',
        (tester) async {
      const message = 'Connection failed';
      when(() => bloc.state)
          .thenReturn(const TeamMembersError(message));
      whenListen(
        bloc,
        Stream.fromIterable([const TeamMembersError(message)]),
      );

      await tester.pumpPage(const TeamMembersPage(), bloc: bloc);
      await tester.pump();

      expect(find.text('Something went wrong'), findsOneWidget);
      // The message appears in the _ErrorView and also in the SnackBar
      expect(find.text(message), findsWidgets);
    });

    testWidgets('shows error SnackBar when state changes to Error',
        (tester) async {
      const message = 'Timeout';
      when(() => bloc.state).thenReturn(const TeamMembersLoading());
      whenListen(
        bloc,
        Stream.fromIterable([const TeamMembersError(message)]),
      );

      await tester.pumpPage(const TeamMembersPage(), bloc: bloc);
      await tester.pump();

      expect(find.text(message), findsWidgets);
    });

    testWidgets('shows confirmation SnackBar when a member is removed',
        (tester) async {
      when(() => bloc.state)
          .thenReturn(const TeamMembersLoaded(tMembers));
      whenListen(
        bloc,
        Stream.fromIterable([
          const TeamMembersLoaded(tMembers),
          const TeamMembersLoaded([tMember]),
        ]),
      );

      await tester.pumpPage(const TeamMembersPage(), bloc: bloc);
      await tester.pump();

      expect(find.text('Member removed from the team'), findsOneWidget);
    });

    testWidgets(
        'tapping delete on an item dispatches TeamMemberRemoveRequested',
        (tester) async {
      when(() => bloc.state)
          .thenReturn(const TeamMembersLoaded([tMember]));

      await tester.pumpPage(const TeamMembersPage(), bloc: bloc);
      await tester.pump();

      await tester.tap(find.byIcon(Icons.delete_outline_rounded));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Yes, remove'));
      await tester.pumpAndSettle();

      verify(() => bloc.add(any())).called(1);
    });
  });
}
