// BlocListener<Bloc, State>
//
// Listens to state changes and runs a side effect in the `listener` callback.
// It does NOT build any widget of its own — it wraps a child transparently.
// Accepts an optional `listenWhen` to control which transitions trigger the listener.
//
// Use it when: you need a one-time side effect (SnackBar, navigation, dialog)
// in response to a state change, without rebuilding any UI.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../features/team_members/presentation/bloc/team_members_bloc.dart';
import '../../../../features/team_members/presentation/bloc/team_members_state.dart';

class RemovalListener extends StatelessWidget {
  final Widget child;

  const RemovalListener({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocListener<TeamMembersBloc, TeamMembersState>(
      listenWhen: (previous, current) =>
          previous is TeamMembersLoaded &&
          current is TeamMembersLoaded &&
          current.members.length < previous.members.length,
      listener: (context, state) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle_rounded, color: AppColors.surface),
                  SizedBox(width: 10),
                  Text('Member removed from the team'),
                ],
              ),
              backgroundColor: AppColors.primaryDark,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              duration: const Duration(seconds: 2),
            ),
          );
      },
      child: child,
    );
  }
}
