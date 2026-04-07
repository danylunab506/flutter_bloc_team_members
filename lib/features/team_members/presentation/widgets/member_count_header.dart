import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../features/team_members/presentation/bloc/team_members_bloc.dart';
import '../../../../features/team_members/presentation/bloc/team_members_state.dart';

class MemberCountHeader extends StatelessWidget {
  const MemberCountHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TeamMembersBloc, TeamMembersState>(
      buildWhen: (previous, current) => current is TeamMembersLoaded,
      builder: (context, state) {
        if (state is! TeamMembersLoaded) return const SizedBox.shrink();

        final count = state.members.length;

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: RichText(
            text: TextSpan(
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
              children: [
                const TextSpan(text: 'Showing '),
                TextSpan(
                  text: '$count ${count == 1 ? 'member' : 'members'}',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const TextSpan(text: ' in your team'),
              ],
            ),
          ),
        );
      },
    );
  }
}
