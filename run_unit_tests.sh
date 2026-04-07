#!/bin/bash
set -e

echo "Running unit tests..."
flutter test test/unit_testing/features/team_members/presentation/bloc/team_members_bloc_test.dart --reporter expanded

echo "Done."
