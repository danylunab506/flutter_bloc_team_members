import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_bloc_team_members/features/team_members/presentation/widgets/team_member_item.dart';

import '../../../../helpers/pump_app.dart';
import '../../../../helpers/team_member_factory.dart';

void main() {
  group('TeamMemberItem', () {
    testWidgets('muestra el nombre completo del miembro', (tester) async {
      await tester.pumpApp(
        TeamMemberItem(member: tMember, onRemove: () {}),
      );

      expect(find.text('Ana Smith'), findsOneWidget);
    });

    testWidgets('shows the member title', (tester) async {
      await tester.pumpApp(
        TeamMemberItem(member: tMember, onRemove: () {}),
      );

      expect(find.text('Engineer'), findsOneWidget);
    });

    testWidgets('muestra la bio cuando es corta (≤100 chars)', (tester) async {
      await tester.pumpApp(
        TeamMemberItem(member: tMember, onRemove: () {}),
      );

      expect(find.text(tMember.bio), findsOneWidget);
    });

    testWidgets('trunca la bio con "..." cuando supera 100 caracteres',
        (tester) async {
      await tester.pumpApp(
        TeamMemberItem(member: tMemberLongBio, onRemove: () {}),
      );

      final expectedText = '${tMemberLongBio.bio.substring(0, 100)}...';
      expect(find.text(expectedText), findsOneWidget);
    });

    testWidgets('does not render the bio section when it is empty',
        (tester) async {
      await tester.pumpApp(
        TeamMemberItem(member: tMemberNoBio, onRemove: () {}),
      );

      // Title only, no bio
      expect(find.text('PM'), findsOneWidget);
      expect(find.text(''), findsNothing);
    });

    testWidgets('shows the delete button', (tester) async {
      await tester.pumpApp(
        TeamMemberItem(member: tMember, onRemove: () {}),
      );

      expect(find.byIcon(Icons.delete_outline_rounded), findsOneWidget);
    });

    testWidgets('tapping delete opens the confirmation dialog',
        (tester) async {
      await tester.pumpApp(
        TeamMemberItem(member: tMember, onRemove: () {}),
      );

      await tester.tap(find.byIcon(Icons.delete_outline_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Remove member?'), findsOneWidget);
      expect(find.text('Keep them'), findsOneWidget);
      expect(find.text('Yes, remove'), findsOneWidget);
    });

    testWidgets('confirming removal calls onRemove', (tester) async {
      var removed = false;

      await tester.pumpApp(
        TeamMemberItem(member: tMember, onRemove: () => removed = true),
      );

      await tester.tap(find.byIcon(Icons.delete_outline_rounded));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Yes, remove'));
      await tester.pumpAndSettle();

      expect(removed, isTrue);
    });

    testWidgets('cancelling the dialog does NOT call onRemove', (tester) async {
      var removed = false;

      await tester.pumpApp(
        TeamMemberItem(member: tMember, onRemove: () => removed = true),
      );

      await tester.tap(find.byIcon(Icons.delete_outline_rounded));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Keep them'));
      await tester.pumpAndSettle();

      expect(removed, isFalse);
    });
  });
}
