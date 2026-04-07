import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_bloc_team_members/core/theme/app_theme.dart';
import 'package:flutter_bloc_team_members/features/team_members/presentation/bloc/team_members_bloc.dart';

/// Pump a widget inside MaterialApp with theme and optional BlocProvider.
extension PumpApp on WidgetTester {
  Future<void> pumpApp(
    Widget widget, {
    TeamMembersBloc? bloc,
  }) async {
    await pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: bloc != null
            ? BlocProvider<TeamMembersBloc>.value(
                value: bloc,
                child: Scaffold(body: widget),
              )
            : Scaffold(body: widget),
      ),
    );
  }

  /// Pump a full page (already includes Scaffold) with BlocProvider + theme.
  Future<void> pumpPage(
    Widget page, {
    required TeamMembersBloc bloc,
  }) async {
    await pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: BlocProvider<TeamMembersBloc>.value(
          value: bloc,
          child: page,
        ),
      ),
    );
  }

  /// Pump a page that needs GoRouter (e.g. SplashPage, TeamMembersPage).
  Future<void> pumpRouter(
    GoRouter router, {
    TeamMembersBloc? bloc,
  }) async {
    await pumpWidget(
      bloc != null
          ? BlocProvider<TeamMembersBloc>.value(
              value: bloc,
              child: MaterialApp.router(
                theme: AppTheme.light,
                routerConfig: router,
              ),
            )
          : MaterialApp.router(
              theme: AppTheme.light,
              routerConfig: router,
            ),
    );
  }
}
