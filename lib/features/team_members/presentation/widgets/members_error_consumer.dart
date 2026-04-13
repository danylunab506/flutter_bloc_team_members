// BlocConsumer<Bloc, State>
//
// Combines BlocBuilder and BlocListener in a single widget.
// The `listener` handles side effects and the `builder` rebuilds the UI,
// both in response to the same state change.
// Accepts `listenWhen` and `buildWhen` to control each independently.
//
// Use it when: a state change requires both a side effect AND a UI rebuild.
// If you only need one of the two, prefer BlocListener or BlocBuilder instead.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../features/team_members/presentation/bloc/team_members_bloc.dart';
import '../../../../features/team_members/presentation/bloc/team_members_event.dart';
import '../../../../features/team_members/presentation/bloc/team_members_state.dart';

class MembersErrorConsumer extends StatelessWidget {
  final Widget child;

  const MembersErrorConsumer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TeamMembersBloc, TeamMembersState>(
      listenWhen: (previous, current) => current is TeamMembersError,
      listener: (context, state) {
        final message = (state as TeamMembersError).message;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline_rounded,
                    color: AppColors.surface),
                const SizedBox(width: 10),
                Expanded(child: Text(message)),
              ],
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      },
      builder: (context, state) {
        if (state is TeamMembersError) {
          return _ErrorView(
            message: state.message,
            onRetry: () => context
                .read<TeamMembersBloc>()
                .add(const TeamMembersLoadRequested()),
          );
        }
        return child;
      },
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.wifi_off_rounded,
                color: AppColors.error,
                size: 34,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Something went wrong',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 17,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Try again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.surface,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
