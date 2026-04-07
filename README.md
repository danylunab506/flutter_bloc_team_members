# Flutter BLoC Team Members

A Flutter application that displays a list of team members loaded from a local JSON asset. Users can remove members from the list with a confirmation dialog. The app demonstrates a clean, scalable architecture using the BLoC pattern.

## Features

- Team member list with avatar, name, title, and bio
- Remove a member with a confirmation dialog
- Pull-to-refresh to reload the full list
- Empty state with Lottie animation
- Error state with retry option
- Real-time member count in the app bar

## Architecture

The project follows **Clean Architecture** organized by feature:

```
lib/
├── core/
│   ├── di/                 # Dependency injection (get_it)
│   ├── theme/              # App colors and Material 3 theme
│   └── widgets/            # Shared widgets
├── features/
│   ├── splash/
│   │   └── presentation/
│   │       └── pages/          # Splash screen
│   └── team_members/
│       ├── data/
│       │   ├── datasources/    # Local JSON datasource
│       │   ├── models/         # Data models (fromJson)
│       │   └── repositories/   # Repository implementation
│       ├── domain/
│       │   ├── entities/       # Core business entities
│       │   ├── repositories/   # Abstract repository contracts
│       │   └── usecases/       # Business logic
│       └── presentation/
│           ├── bloc/           # BLoC: events, states, logic
│           ├── pages/          # Screens
│           └── widgets/        # Feature-specific widgets
├── router/                 # go_router setup and route constants
└── main.dart               # Entry point
```

## BLoC Widgets Usage

Each BLoC widget is used intentionally based on what the UI needs:

| Widget | Where | Why |
|---|---|---|
| `BlocBuilder` | `MemberCountHeader` | Rebuilds the header text when the member count changes |
| `BlocSelector` | `MemberCountBadge` | Extracts only the count from the state to avoid unnecessary rebuilds |
| `BlocListener` | `RemovalListener` | Shows a confirmation snackbar on member removal without rebuilding the UI |
| `BlocConsumer` | `MembersErrorConsumer` | Handles error state by showing a snackbar and replacing the UI with an error view |

## Tech Stack

| Package | Purpose |
|---|---|
| `flutter_bloc` | State management using the BLoC pattern |
| `equatable` | Value equality for entities and states |
| `get_it` | Dependency injection and service locator |
| `go_router` | Declarative navigation with deep linking |
| `lottie` | JSON animations for loading and empty states |

## Setup

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) >= 3.0.0
- Xcode (for iOS simulator) or Android Studio (for Android emulator)

### Clone the repository

```bash
git clone https://github.com/danylunab506/flutter_bloc_team_members.git
cd flutter_bloc_team_members
```

### Make scripts executable

Before running any shell script for the first time, grant them execution permissions:

```bash
chmod +x install.sh run.sh run_unit_tests.sh run_widget_tests.sh
```

### Install dependencies

```bash
./install.sh
```

Or manually:

```bash
flutter pub get
```

### Run the app

```bash
./run.sh
```

This will automatically detect the first available device or simulator and launch the app. You can also run it manually:

```bash
flutter devices          # list available devices
flutter run -d <device>  # run on a specific device
```

## Testing

The project includes two levels of automated testing.

### Unit tests

Located in `test/unit_testing/`. They test the `TeamMembersBloc` in isolation using `bloc_test` and `mocktail` to mock the `GetTeamMembers` use case. The covered scenarios are:

- `TeamMembersLoadRequested` — emits `Loading → Loaded`, `Loading → Empty`, and `Loading → Error` depending on the use case result
- `TeamMemberRemoveRequested` — filters the member from the list, emits `Empty` when the last one is removed, and ignores the event when the state is not `Loaded`

```bash
./run_unit_tests.sh
```

### Widget tests

Located in `test/widget_testing/`. They test each widget and page in isolation using a `MockTeamMembersBloc` and a set of shared helpers:

- `pump_app.dart` — wraps a widget in `MaterialApp` with the app theme and an optional `BlocProvider`
- `mock_bloc.dart` — provides the `MockTeamMembersBloc` used across all widget tests
- `team_member_factory.dart` — predefined `TeamMember` fixtures for consistent test data

Covered widgets and pages: `SplashPage`, `TeamMembersPage`, `EmptyMembersWidget`, `MemberCountBadge`, `MemberCountHeader`, `MembersErrorConsumer`, `RemovalListener`, and `TeamMemberItem`.

```bash
./run_widget_tests.sh
```
