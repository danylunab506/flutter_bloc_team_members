import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../core/di/dependency_injection.dart';
import 'routes.dart';
import '../features/splash/presentation/pages/splash_page.dart';
import '../features/team_members/presentation/bloc/team_members_bloc.dart';
import '../features/team_members/presentation/bloc/team_members_event.dart';
import '../features/team_members/presentation/pages/team_members_page.dart';

class AppRouter {
  final GoRouter router = GoRouter(
    initialLocation: Routes.splash,
    routes: [
      GoRoute(
        path: Routes.splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: Routes.teamMembers,
        builder: (context, state) => BlocProvider(
          create: (_) =>
              getIt<TeamMembersBloc>()..add(const TeamMembersLoadRequested()),
          child: const TeamMembersPage(),
        ),
      ),
    ],
  );
}
