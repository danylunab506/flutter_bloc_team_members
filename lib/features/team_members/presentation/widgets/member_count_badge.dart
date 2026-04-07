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
