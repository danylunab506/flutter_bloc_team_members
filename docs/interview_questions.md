# Interview Questions — flutter_bloc_team_members

---

## Architecture

**1. Explain the architecture you used.**

> I used Clean Architecture organized by feature. Each feature has three layers: `data`, `domain`, and `presentation`. The `domain` layer is independent — it doesn't import anything from Flutter or external packages, it only defines entities, repository contracts, and use cases. The `data` layer implements those contracts with concrete datasources. The `presentation` layer consumes the domain through the BLoC. This allows changing the data source without touching the UI, and testing each layer in isolation.

---

**2. Why did you organize by feature and not by class type (data/domain/presentation at the root)?**

> Organizing by feature scales better. If the project grows and new features are added, each one is a self-contained module. You can work on `team_members` without touching `invoices` or `settings`. If you organize by type, a change in one feature means navigating between four different folders. Cohesion should be by feature, not by layer.

---

**3. Why does `TeamMemberScheme extends TeamMember` instead of mapping?**

> It's a valid simplification for this context. Since the datasource is local and there's no divergence between what the JSON returns and what the domain needs, the scheme can inherit directly from the entity. If tomorrow a remote API returned fields with different names or a different structure, I would separate the scheme from the entity and introduce a mapper. The scheme lives in `data/schemes/` (not `data/models/`) because its only responsibility is to map the raw shape of the source — local JSON or API — to an object the data layer can use.

---

**4. Why is there a `_cache` in the repository?**

> The JSON is the original, immutable source. Deletions are done in memory — we don't write back to the asset. Without the cache, every call to `removeTeamMember` would reload the JSON and lose the previous deletions. The repository acts as the source of truth at runtime, initialized from the JSON and modified in memory during the session.

---

## BLoC

**5. Why BLoC and not Riverpod or Provider?**

> BLoC enforces an explicit separation between events, states, and logic. That makes the flow very predictable and easy to test — `blocTest` lets you seed an initial state, dispatch an event, and verify exactly which states are emitted. For a team, BLoC is also more readable because each user interaction has a named event. Riverpod is more flexible but less prescriptive, which can be an advantage or a disadvantage depending on the team.

---

**6. Explain the four BLoC widgets you used and why each one.**

> — `BlocBuilder` in `MemberCountHeader`: I need to rebuild the entire widget when the state changes, with a `buildWhen` filter to ignore states other than `Loaded`.
>
> — `BlocSelector` in `MemberCountBadge`: I only care about the `int` count. The selector extracts that value and the widget only rebuilds when that integer changes, regardless of what other fields in the state have changed.
>
> — `BlocListener` in `RemovalListener`: the SnackBar is a side effect, it doesn't need to rebuild anything. `BlocListener` is transparent in the widget tree.
>
> — `BlocConsumer` in `MembersErrorConsumer`: the error requires two things simultaneously — showing a SnackBar and replacing the UI with an error view. I need both `listener` and `builder`, so `BlocConsumer` is the right tool.

---

**7. Why does the page's `BlocBuilder` have `buildWhen: (prev, curr) => curr is! TeamMembersError`?**

> When an error occurs, `MembersErrorConsumer` already takes care of showing it — both the SnackBar and the error view. If the parent `BlocBuilder` didn't filter out that state, it would receive `TeamMembersError` and clear the list that was already on screen. With that `buildWhen`, the `BlocBuilder` ignores errors and delegates that responsibility to the `BlocConsumer`. Each widget has a single responsibility.

---

**8. Why is the BLoC registered as `registerFactory` and not as `registerLazySingleton`?**

> The BLoC has state. If it were a singleton, navigating back and returning to the screen would cause the BLoC to preserve the state from the previous session. With `registerFactory`, each navigation creates a new instance that starts in `TeamMembersInitial`. The use cases and repository are `lazySingleton` because they don't have their own mutable state — the repository has the cache, but that's precisely what we want to share.

---

**9. How does pull-to-refresh work with BLoC?**

> `RefreshIndicator` expects the `Future` from `onRefresh` to complete in order to stop the animation. With BLoC you don't have a direct `Future` to resolve, so I listen to the BLoC's stream and wait for the first terminal state:
> ```dart
> await bloc.stream.firstWhere(
>   (s) => s is TeamMembersLoaded || s is TeamMembersEmpty || s is TeamMembersError,
> );
> ```
> When the BLoC emits any of those states, the `Future` completes and the spinner disappears.

---

## Testing

**10. How did you test the BLoC?**

> With `bloc_test` and `mocktail`. `blocTest` lets you define an initial state with `seed`, dispatch events with `act`, and verify the exact sequence of emitted states with `expect`. The use cases are mocked with `mocktail`, so the BLoC is tested completely in isolation without touching the repository or the datasource. I also use `verify` to ensure that the use case was called exactly once.

---

**11. What's the difference between your unit tests and your widget tests?**

> Unit tests verify the BLoC's logic in complete isolation — no Flutter, no widgets, no UI. Widget tests verify that widgets render correctly given a BLoC state. For widget tests I use a `MockTeamMembersBloc` into which I inject the state I want to test. I have shared helpers: `pump_app.dart` which wraps the widget with `MaterialApp` and the theme, and `team_member_factory.dart` with consistent data fixtures.

---

**12. What would you test if you had more time?**

> I would add integration tests that exercise the complete flow from the datasource to the UI, without mocks. I would also test the `RemovalListener` to verify that `clearSnackBars()` is called before showing the new SnackBar when members are removed consecutively. And I would add golden tests for the most important visual widgets like `TeamMemberItem` and `EmptyMembersWidget`.

---

## Specific decisions

**13. Why did you use `sealed class` for the states?**

> `sealed class` enables exhaustive pattern matching with `switch`. If I add a new state and don't handle it in the UI's `switch`, the compiler flags it as an error. Without `sealed`, an incomplete `switch` or `if/else` would fail silently at runtime. It's compile-time type safety.

---

**14. When there's an error in the JSON, what does the user see?**

> A readable message. In the datasource I catch `FormatException` specifically and throw a `DataParsingException` with the text "The data could not be read". Any other error throws a `DataLoadException` with "Could not load team members. Please try again." The BLoC just does `e.toString()` and that clean message reaches the error state. The user never sees a stack trace or a technical Dart message.

---

**15. How would you scale dependency injection if the project grows?**

> By separating the registrations per feature into independent modules. `dependency_injection.dart` remains an orchestrator that only calls each module. Adding a new feature means creating a file in `core/di/features/` and adding one line in `initDependencies()`. The main file never grows.

---

**16. Why didn't you use `WidgetsFlutterBinding.ensureInitialized()`?**

> Because there's no asynchronous operation or native plugin before `runApp`. `initDependencies()` is pure Dart code that only registers factories in `get_it`. `ensureInitialized()` is necessary when, before `runApp`, you use a plugin like Firebase, SharedPreferences or path_provider, which need the binding with the native engine to be ready. Adding it without need would be code with no purpose.
