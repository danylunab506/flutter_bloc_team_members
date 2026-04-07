import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_bloc_team_members/features/splash/presentation/pages/splash_page.dart';
import 'package:flutter_bloc_team_members/router/routes.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  GoRouter buildRouter({Widget teamMembersPage = const Placeholder()}) {
    return GoRouter(
      initialLocation: Routes.splash,
      routes: [
        GoRoute(
          path: Routes.splash,
          builder: (_, __) => const SplashPage(),
        ),
        GoRoute(
          path: Routes.teamMembers,
          builder: (_, __) => teamMembersPage,
        ),
      ],
    );
  }

  group('SplashPage', () {
    testWidgets('renders Scaffold with gradient container', (tester) async {
      await tester.pumpRouter(buildRouter());
      await tester.pump();

      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(Container), findsWidgets);

      // Drain the 3s timer to avoid "Timer still pending"
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
    });

    testWidgets('contains a Center widget wrapping the animation',
        (tester) async {
      await tester.pumpRouter(buildRouter());
      await tester.pump();

      expect(find.byType(Center), findsWidgets);

      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
    });

    testWidgets('navigates to team members route after 3 seconds',
        (tester) async {
      const destination = Key('team_members_placeholder');
      await tester.pumpRouter(
        buildRouter(
          teamMembersPage: const Scaffold(
            body: SizedBox(key: destination),
          ),
        ),
      );

      // Before the delay — still on splash
      await tester.pump();
      expect(find.byKey(destination), findsNothing);

      // Advance time past the 3-second delay
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      expect(find.byKey(destination), findsOneWidget);
    });
  });
}
