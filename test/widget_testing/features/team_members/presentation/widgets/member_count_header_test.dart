import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_bloc_team_members/features/team_members/domain/entities/team_member.dart';
import 'package:flutter_bloc_team_members/features/team_members/presentation/bloc/team_members_state.dart';
import 'package:flutter_bloc_team_members/features/team_members/presentation/widgets/member_count_header.dart';

import '../../../../helpers/mock_bloc.dart';
import '../../../../helpers/pump_app.dart';
import '../../../../helpers/team_member_factory.dart';

void main() {
  late MockTeamMembersBloc bloc;

  setUpAll(registerFallbacks);

  setUp(() => bloc = MockTeamMembersBloc());

  group('MemberCountHeader', () {
    testWidgets('does not render text when state is not Loaded',
        (tester) async {
      when(() => bloc.state).thenReturn(const TeamMembersLoading());

      await tester.pumpApp(const MemberCountHeader(), bloc: bloc);

      expect(find.text('Showing '), findsNothing);
    });

    testWidgets('shows "1 member" in singular with a single member',
        (tester) async {
      when(() => bloc.state)
          .thenReturn(const TeamMembersLoaded([tMember]));

      await tester.pumpApp(const MemberCountHeader(), bloc: bloc);

      // RichText requires findRichText: true for textContaining to find it
      expect(
        find.textContaining('1 member', findRichText: true),
        findsOneWidget,
      );
      expect(
        find.textContaining('members', findRichText: true),
        findsNothing,
      );
    });

    testWidgets('shows "N members" in plural with multiple members',
        (tester) async {
      when(() => bloc.state)
          .thenReturn(const TeamMembersLoaded(tMembers));

      await tester.pumpApp(const MemberCountHeader(), bloc: bloc);

      expect(
        find.textContaining('${tMembers.length} members', findRichText: true),
        findsOneWidget,
      );
    });

    testWidgets('updates the header when the member count changes',
        (tester) async {
      const threeMembers = [
        tMember,
        tMemberLongBio,
        TeamMember(
          id: '99',
          firstName: 'Extra',
          lastName: 'Member',
          title: 'Dev',
          avatar: '',
          bio: '',
        ),
      ];
      when(() => bloc.state)
          .thenReturn(const TeamMembersLoaded(threeMembers));
      whenListen(
        bloc,
        Stream.fromIterable([
          const TeamMembersLoaded(threeMembers),
          const TeamMembersLoaded([tMember]),
        ]),
      );

      await tester.pumpApp(const MemberCountHeader(), bloc: bloc);
      await tester.pump();

      expect(
        find.textContaining('1 member', findRichText: true),
        findsOneWidget,
      );
    });
  });
}
