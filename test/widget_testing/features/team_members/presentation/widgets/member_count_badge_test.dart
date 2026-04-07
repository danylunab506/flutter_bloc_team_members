import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_bloc_team_members/features/team_members/presentation/bloc/team_members_state.dart';
import 'package:flutter_bloc_team_members/features/team_members/presentation/widgets/member_count_badge.dart';

import '../../../../helpers/mock_bloc.dart';
import '../../../../helpers/pump_app.dart';
import '../../../../helpers/team_member_factory.dart';

void main() {
  late MockTeamMembersBloc bloc;

  setUpAll(registerFallbacks);

  setUp(() {
    bloc = MockTeamMembersBloc();
  });

  group('MemberCountBadge', () {
    testWidgets('does not render when state is Initial', (tester) async {
      when(() => bloc.state).thenReturn(const TeamMembersInitial());

      await tester.pumpApp(const MemberCountBadge(), bloc: bloc);

      // Badge returns SizedBox.shrink — no numeric text visible
      expect(find.text('0'), findsNothing);
      expect(find.text('1'), findsNothing);
    });

    testWidgets('does not render when state is Loading', (tester) async {
      when(() => bloc.state).thenReturn(const TeamMembersLoading());

      await tester.pumpApp(const MemberCountBadge(), bloc: bloc);

      expect(find.text('0'), findsNothing);
    });

    testWidgets('does not render when state is Empty', (tester) async {
      when(() => bloc.state).thenReturn(const TeamMembersEmpty());

      await tester.pumpApp(const MemberCountBadge(), bloc: bloc);

      expect(find.text('0'), findsNothing);
    });

    testWidgets('shows the member count when state is Loaded',
        (tester) async {
      when(() => bloc.state)
          .thenReturn(const TeamMembersLoaded(tMembers));

      await tester.pumpApp(const MemberCountBadge(), bloc: bloc);

      expect(find.text('${tMembers.length}'), findsOneWidget);
    });

    testWidgets('updates the count when state changes from Loaded to Loaded',
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

      await tester.pumpApp(const MemberCountBadge(), bloc: bloc);
      await tester.pump();

      expect(find.text('1'), findsOneWidget);
    });
  });
}
