# BLoC Widgets

Quick reference for the four BLoC widgets used in this project.

---

## BlocBuilder

Rebuilds a widget in response to state changes.

```dart
BlocBuilder<MyBloc, MyState>(
  buildWhen: (previous, current) => current is MyLoaded, // optional filter
  builder: (context, state) {
    return Text(state.value);
  },
)
```

**How it works:**
Subscribes to the BLoC stream and calls `builder` every time a new state is emitted.
If `buildWhen` is provided, the rebuild only happens when it returns `true`.

**Use it when:** the widget needs to visually reflect the state, and you optionally
want to skip rebuilds caused by irrelevant state changes.

**In this project:** `MemberCountHeader` — rebuilds the member count text only when
the state is `TeamMembersLoaded`.

---

## BlocSelector

Extracts a single value from the state and rebuilds only when that value changes.

```dart
BlocSelector<MyBloc, MyState, int>(
  selector: (state) => state is MyLoaded ? state.count : 0,
  builder: (context, count) {
    return Text('$count');
  },
)
```

**How it works:**
Runs the `selector` on every emitted state. If the returned value is equal to the
previous one (via `==`), the rebuild is skipped entirely.

**Use it when:** you only care about one derived value from the state and want to
avoid rebuilds triggered by unrelated state changes. More targeted than `buildWhen`.

**In this project:** `MemberCountBadge` — extracts the `int` count from the state.
The badge does not rebuild when, for example, the state transitions from
`Loading` to `Loaded` with the same count.

---

## BlocListener

Runs a side effect in response to state changes without rebuilding any UI.

```dart
BlocListener<MyBloc, MyState>(
  listenWhen: (previous, current) => current is MyError, // optional filter
  listener: (context, state) {
    ScaffoldMessenger.of(context).showSnackBar(...);
  },
  child: MyWidget(),
)
```

**How it works:**
Wraps its child transparently — it does not contribute any widget to the tree.
`listener` is called once per qualifying state change. If `listenWhen` is provided,
the listener only fires when it returns `true`.

**Use it when:** you need a one-time side effect (SnackBar, navigation, dialog,
analytics event) in response to a state change, with no UI rebuild needed.

**In this project:** `RemovalListener` — shows a SnackBar when a member is removed.
The `listenWhen` checks that the previous and current states are both `Loaded`
and that the member count decreased, so the SnackBar only appears on an actual removal.

---

## BlocConsumer

Combines `BlocListener` and `BlocBuilder` in a single widget.

```dart
BlocConsumer<MyBloc, MyState>(
  listenWhen: (previous, current) => current is MyError,
  listener: (context, state) {
    ScaffoldMessenger.of(context).showSnackBar(...);
  },
  buildWhen: (previous, current) => current is! MyError,
  builder: (context, state) {
    return MyWidget(state);
  },
)
```

**How it works:**
On each state emission, both callbacks are evaluated independently using their
respective `listenWhen` / `buildWhen` conditions. The listener fires its side effect
and the builder rebuilds the UI — they can respond to the same state or different ones.

**Use it when:** a single state change requires both a side effect AND a UI rebuild.
If you only need one of the two, prefer `BlocListener` or `BlocBuilder` to keep
the widget's intent explicit.

**In this project:** `MembersErrorConsumer` — on `TeamMembersError`, the listener
shows a SnackBar with the error message and the builder replaces the content area
with an error view that includes a retry button.

---

## Summary

| Widget | Rebuilds UI | Side effects | When to use |
|---|---|---|---|
| `BlocBuilder` | Yes | No | UI reflects state, optional rebuild filter |
| `BlocSelector` | Yes (value-based) | No | Only one derived value matters |
| `BlocListener` | No | Yes | SnackBar, navigation, dialog |
| `BlocConsumer` | Yes | Yes | Both a rebuild and a side effect needed |
