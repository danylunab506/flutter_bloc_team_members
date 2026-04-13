// BlocSelector<Bloc, State, SelectedValue>
//
// A specialized BlocBuilder that extracts a single value from the state
// using a `selector` function. The widget only rebuilds when that extracted
// value changes, regardless of how often the BLoC emits.
//
// Use it when: you only care about one piece of the state and want to avoid
// rebuilds caused by unrelated state changes.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../features/team_members/presentation/bloc/team_members_bloc.dart';
import '../../../../features/team_members/presentation/bloc/team_members_state.dart';

class MemberCountBadge extends StatelessWidget {
  const MemberCountBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<TeamMembersBloc, TeamMembersState, int>(
      selector: (state) => state is TeamMembersLoaded ? state.members.length : 0,
      builder: (context, count) {
        if (count == 0) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '$count',
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        );
      },
    );
  }
}
