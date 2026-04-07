import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../features/team_members/presentation/bloc/team_members_bloc.dart';
import '../../../../features/team_members/presentation/bloc/team_members_event.dart';
import '../../../../features/team_members/presentation/bloc/team_members_state.dart';
import '../../../../features/team_members/presentation/widgets/member_count_badge.dart';
import '../../../../features/team_members/presentation/widgets/member_count_header.dart';
import '../../../../features/team_members/presentation/widgets/members_error_consumer.dart';
import '../../../../features/team_members/presentation/widgets/removal_listener.dart';
import '../../../../features/team_members/presentation/widgets/empty_members_widget.dart';
import '../../../../features/team_members/presentation/widgets/team_member_item.dart';

class TeamMembersPage extends StatelessWidget {
  const TeamMembersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Team Members'),
        // BlocSelector: rebuilds only when the member count changes,
        // not on every BLoC state change.
        actions: const [
          MemberCountBadge(),
          SizedBox(width: 16),
        ],
      ),
      // BlocListener: listens for removals and shows a SnackBar.
      // Wraps the body without participating in UI construction.
      body: RemovalListener(
        // BlocConsumer: handles error state with SnackBar + error UI.
        // For any other state, renders the normal content.
        child: MembersErrorConsumer(
          child: BlocBuilder<TeamMembersBloc, TeamMembersState>(
            buildWhen: (previous, current) => current is! TeamMembersError,
            builder: (context, state) {
              return switch (state) {
                TeamMembersInitial() => const SizedBox.shrink(),
                TeamMembersLoading() => const LoadingWidget(),
                TeamMembersError() => const SizedBox.shrink(),
                TeamMembersEmpty() => RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: () async {
                      context
                          .read<TeamMembersBloc>()
                          .add(const TeamMembersLoadRequested());
                      await context.read<TeamMembersBloc>().stream.firstWhere(
                            (s) =>
                                s is TeamMembersLoaded ||
                                s is TeamMembersEmpty ||
                                s is TeamMembersError,
                          );
                    },
                    child: LayoutBuilder(
                      builder: (context, constraints) =>
                          SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: SizedBox(
                          height: constraints.maxHeight,
                          child: const EmptyMembersWidget(),
                        ),
                      ),
                    ),
                  ),
                TeamMembersLoaded() => RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: () async {
                      context
                          .read<TeamMembersBloc>()
                          .add(const TeamMembersLoadRequested());
                      await context.read<TeamMembersBloc>().stream.firstWhere(
                            (s) =>
                                s is TeamMembersLoaded ||
                                s is TeamMembersError,
                          );
                    },
                    child: CustomScrollView(
                      slivers: [
                        // BlocBuilder: rebuilds the header when the count changes.
                        const SliverToBoxAdapter(child: MemberCountHeader()),
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final member = state.members[index];
                              return TeamMemberItem(
                                member: member,
                                onRemove: () =>
                                    context.read<TeamMembersBloc>().add(
                                          TeamMemberRemoveRequested(member.id),
                                        ),
                              );
                            },
                            childCount: state.members.length,
                          ),
                        ),
                      ],
                    ),
                  ),
              };
            },
          ),
        ),
      ),
    );
  }
}
