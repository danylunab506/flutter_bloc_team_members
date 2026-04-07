import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_bloc_team_members/features/team_members/presentation/bloc/team_members_state.dart';
import 'package:flutter_bloc_team_members/features/team_members/presentation/widgets/members_error_consumer.dart';

import '../../../../helpers/mock_bloc.dart';
import '../../../../helpers/pump_app.dart';

void main() {
  late MockTeamMembersBloc bloc;

  setUpAll(registerFallbacks);

  setUp(() => bloc = MockTeamMembersBloc());

  group('MembersErrorConsumer', () {
    testWidgets('renderiza el child cuando el estado no es error',
        (tester) async {
      when(() => bloc.state).thenReturn(const TeamMembersLoading());

      const childKey = Key('child_widget');
      // pumpApp includes Scaffold, required for ScaffoldMessenger to work
      await tester.pumpApp(
        MembersErrorConsumer(child: const SizedBox(key: childKey)),
        bloc: bloc,
      );

      expect(find.byKey(childKey), findsOneWidget);
    });

    testWidgets('muestra la vista de error cuando el estado es TeamMembersError',
        (tester) async {
      const errorMessage = 'Network failure';
      when(() => bloc.state)
          .thenReturn(const TeamMembersError(errorMessage));
      whenListen(
        bloc,
        Stream.fromIterable([const TeamMembersError(errorMessage)]),
      );

      await tester.pumpApp(
        MembersErrorConsumer(child: const SizedBox()),
        bloc: bloc,
      );
      await tester.pump();

      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.text(errorMessage), findsWidgets);
      expect(find.text('Try again'), findsOneWidget);
    });

    testWidgets('muestra SnackBar con el mensaje de error', (tester) async {
      const errorMessage = 'Timeout error';
      when(() => bloc.state).thenReturn(const TeamMembersLoading());
      whenListen(
        bloc,
        Stream.fromIterable([const TeamMembersError(errorMessage)]),
      );

      await tester.pumpApp(
        MembersErrorConsumer(child: const SizedBox()),
        bloc: bloc,
      );
      await tester.pump();

      // El mensaje aparece tanto en el SnackBar como en la _ErrorView
      expect(find.text(errorMessage), findsWidgets);
    });

    testWidgets('"Try again" despacha TeamMembersLoadRequested', (tester) async {
      const errorMessage = 'Error';
      when(() => bloc.state)
          .thenReturn(const TeamMembersError(errorMessage));
      whenListen(
        bloc,
        Stream.fromIterable([const TeamMembersError(errorMessage)]),
      );

      await tester.pumpApp(
        MembersErrorConsumer(child: const SizedBox()),
        bloc: bloc,
      );
      await tester.pump();
      await tester.tap(find.text('Try again'));

      verify(() => bloc.add(any())).called(1);
    });
  });
}
