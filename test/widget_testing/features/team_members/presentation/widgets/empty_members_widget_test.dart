import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_bloc_team_members/features/team_members/presentation/widgets/empty_members_widget.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  group('EmptyMembersWidget', () {
    testWidgets('shows the empty list title', (tester) async {
      await tester.pumpApp(const EmptyMembersWidget());
      await tester.pump();

      expect(find.text('No team members found'), findsOneWidget);
    });

    testWidgets('shows the pull to refresh instruction', (tester) async {
      await tester.pumpApp(const EmptyMembersWidget());
      await tester.pump();

      expect(
        find.textContaining('Pull down to reload'),
        findsOneWidget,
      );
    });
  });
}
