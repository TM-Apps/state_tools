import 'package:flutter/widgets.dart';

import 'state_notifier.dart';

/// [StateBuilder] handles building a widget in response to new `states`.
/// [StateBuilder] is analogous to [StreamBuilder] but has simplified API to
/// reduce the amount of boilerplate code needed as well as [state]-specific
/// performance improvements.
class StateBuilder<S> extends StatefulWidget {
  const StateBuilder({
    super.key,
    required this.notifier,
    required this.builder,
    this.listener,
    this.buildWhen,
    this.listenWhen,
  });

  /// The [StateNotifier] supplied to the constructor.
  final StateNotifier<S> notifier;

  /// Called when the [StateNotifier] notifies about a change and
  /// the if the `state` pass the `builderWhen` filter (if set).
  final StateHandlerFunction<S> builder;

  /// Condition to determine if the [builder] should be called or not.
  final StateConditionFunction<S>? buildWhen;

  /// Called when the [StateNotifier] notifies about a change and
  /// the if the `state` pass the `listenWhen` filter (if set).
  final StateListenerFunction<S>? listener;

  /// Condition to determine if the [listener] should be called or not.
  final StateConditionFunction<S>? listenWhen;

  @override
  State<StateBuilder> createState() => _StateBuilderState<S>();
}

class _StateBuilderState<S> extends State<StateBuilder<S>> {
  S? _previousState;
  late S _state;

  @override
  void initState() {
    super.initState();
    _state = widget.notifier.state;
    widget.notifier.addListener(_onStateChanged);
  }

  void _onStateChanged() {
    final currentState = widget.notifier.state;
    if (widget.buildWhen?.call(_previousState, currentState) ?? true) {
      setState(() => _state = currentState);
    }
    if (widget.listener != null &&
        (widget.listenWhen?.call(_previousState, currentState) ?? true)) {
      widget.listener?.call(context, currentState);
    }
  }

  @override
  Widget build(BuildContext context) {
    final result = widget.builder(context, _state);
    _previousState = _state;
    return result;
  }

  @override
  void dispose() {
    widget.notifier.removeListener(_onStateChanged);
    super.dispose();
  }
}

/// Takes a [StateNotifier] and invokes the [listener] in response to `state` changes.
/// It should be used for functionality that needs to occur only in response to
/// a `state` change such as navigation, showing a `SnackBar`, showing
/// a `Dialog`, etc...
/// The [listener] is guaranteed to only be called once for each `state` change
/// unlike the `builder` in `StateBuilder`.
class StateListener<S> extends StatefulWidget {
  const StateListener({
    super.key,
    required this.notifier,
    required this.listener,
    required this.child,
    this.listenWhen,
  });

  /// The [StateNotifier] supplied to the constructor.
  final StateNotifier<S> notifier;

  /// Called when the [StateNotifier] notifies about a change and
  /// the if the `state` pass the `listenWhen` filter (if set).
  final StateListenerFunction<S> listener;

  /// The child widget to pass to the [builder].
  final Widget child;

  /// Condition to determine if the [listener] should be called or not.
  final StateConditionFunction<S>? listenWhen;

  @override
  State<StateListener> createState() => _StateListenerState<S>();
}

class _StateListenerState<S> extends State<StateListener<S>> {
  S? _previousState;

  @override
  void initState() {
    super.initState();
    widget.notifier.addListener(_onStateChanged);
  }

  void _onStateChanged() {
    final currentState = widget.notifier.state;
    if (widget.listenWhen?.call(_previousState, currentState) ?? true) {
      widget.listener.call(context, currentState);
      _previousState = currentState;
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;

  @override
  void dispose() {
    widget.notifier.removeListener(_onStateChanged);
    super.dispose();
  }
}

class DoubleStateBuilder<S1, S2> extends StatefulWidget {
  const DoubleStateBuilder({
    super.key,
    required this.notifier1,
    required this.notifier2,
    required this.builder,
    this.listener,
    this.buildWhen,
    this.listenWhen,
  });

  /// The first [StateNotifier] supplied to the constructor.
  final StateNotifier<S1> notifier1;

  /// The second [StateNotifier] supplied to the constructor.
  final StateNotifier<S2> notifier2;

  /// Called when the [StateNotifier] notifies about a change and
  /// the if the `state` pass the `builderWhen` filter (if set).
  final StateHandlerFunction2<S1, S2> builder;

  /// Condition to determine if the [builder] should be called or not.
  final StateConditionFunction2<S1, S2>? buildWhen;

  /// Called when the [StateNotifier] notifies about a change and
  /// the if the `state` pass the `listenWhen` filter (if set).
  final StateListenerFunction2<S1, S2>? listener;

  /// Condition to determine if the [listener] should be called or not.
  final StateConditionFunction2<S1, S2>? listenWhen;

  @override
  State<DoubleStateBuilder> createState() => _DoubleStateBuilderState<S1, S2>();
}

class _DoubleStateBuilderState<S1, S2>
    extends State<DoubleStateBuilder<S1, S2>> {
  S1? _previousState1;
  late S1 _state1;

  S2? _previousState2;
  late S2 _state2;

  @override
  void initState() {
    super.initState();
    _state1 = widget.notifier1.state;
    _state2 = widget.notifier2.state;

    widget.notifier1.addListener(_onStateChanged);
    widget.notifier2.addListener(_onStateChanged);
  }

  void _onStateChanged() {
    final currentState1 = widget.notifier1.state;
    final currentState2 = widget.notifier2.state;

    if (widget.buildWhen?.call(
            _previousState1, currentState1, _previousState2, currentState2) ??
        true) {
      setState(() {
        _state1 = currentState1;
        _state2 = currentState2;
      });
    }
    if (widget.listener != null &&
        (widget.listenWhen?.call(_previousState1, currentState1,
                _previousState2, currentState2) ??
            true)) {
      widget.listener?.call(context, currentState1, currentState2);
    }
  }

  @override
  Widget build(BuildContext context) {
    final result = widget.builder(context, _state1, _state2);
    _previousState1 = _state1;
    _previousState2 = _state2;
    return result;
  }

  @override
  void dispose() {
    widget.notifier1.removeListener(_onStateChanged);
    widget.notifier2.removeListener(_onStateChanged);
    super.dispose();
  }
}

/// Takes a [StateNotifier] and invokes the [listener] in response to `state` changes.
/// It should be used for functionality that needs to occur only in response to
/// a `state` change such as navigation, showing a `SnackBar`, showing
/// a `Dialog`, etc...
/// The [listener] is guaranteed to only be called once for each `state` change
/// unlike the `builder` in `StateBuilder`.
class DoubleStateListener<S1, S2> extends StatefulWidget {
  const DoubleStateListener({
    super.key,
    required this.notifier1,
    required this.notifier2,
    required this.listener,
    required this.child,
    this.listenWhen,
  });

  /// The first [StateNotifier] supplied to the constructor.
  final StateNotifier<S1> notifier1;

  /// The second [StateNotifier] supplied to the constructor.
  final StateNotifier<S2> notifier2;

  /// Called when the [StateNotifier] notifies about a change and
  /// the if the `state` pass the `listenWhen` filter (if set).
  final StateListenerFunction2<S1, S2> listener;

  /// The child widget to pass to the [builder].
  final Widget child;

  /// Condition to determine if the [listener] should be called or not.
  final StateConditionFunction2<S1, S2>? listenWhen;

  @override
  State<DoubleStateListener> createState() =>
      _DoubleStateListenerState<S1, S2>();
}

class _DoubleStateListenerState<S1, S2>
    extends State<DoubleStateListener<S1, S2>> {
  S1? _previousState1;
  S2? _previousState2;

  @override
  void initState() {
    super.initState();
    widget.notifier1.addListener(_onStateChanged);
    widget.notifier2.addListener(_onStateChanged);
  }

  void _onStateChanged() {
    final currentState1 = widget.notifier1.state;
    final currentState2 = widget.notifier2.state;

    if (widget.listenWhen?.call(
            _previousState1, currentState1, _previousState2, currentState2) ??
        true) {
      widget.listener.call(context, currentState1, currentState2);
      _previousState1 = currentState1;
      _previousState2 = currentState2;
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;

  @override
  void dispose() {
    widget.notifier1.removeListener(_onStateChanged);
    widget.notifier2.removeListener(_onStateChanged);
    super.dispose();
  }
}

class TripleStateBuilder<S1, S2, S3> extends StatefulWidget {
  const TripleStateBuilder({
    super.key,
    required this.notifier1,
    required this.notifier2,
    required this.notifier3,
    required this.builder,
    this.listener,
    this.buildWhen,
    this.listenWhen,
  });

  /// The first [StateNotifier] supplied to the constructor.
  final StateNotifier<S1> notifier1;

  /// The second [StateNotifier] supplied to the constructor.
  final StateNotifier<S2> notifier2;

  /// The third [StateNotifier] supplied to the constructor.
  final StateNotifier<S3> notifier3;

  /// Called when the [StateNotifier] notifies about a change and
  /// the if the `state` pass the `builderWhen` filter (if set).
  final StateHandlerFunction3<S1, S2, S3> builder;

  /// Condition to determine if the [builder] should be called or not.
  final StateConditionFunction3<S1, S2, S3>? buildWhen;

  /// Called when the [StateNotifier] notifies about a change and
  /// the if the `state` pass the `listenWhen` filter (if set).
  final StateListenerFunction3<S1, S2, S3>? listener;

  /// Condition to determine if the [listener] should be called or not.
  final StateConditionFunction3<S1, S2, S3>? listenWhen;

  @override
  State<TripleStateBuilder> createState() =>
      _TripleStateBuilderState<S1, S2, S3>();
}

class _TripleStateBuilderState<S1, S2, S3>
    extends State<TripleStateBuilder<S1, S2, S3>> {
  S1? _previousState1;
  late S1 _state1;

  S2? _previousState2;
  late S2 _state2;

  S3? _previousState3;
  late S3 _state3;

  @override
  void initState() {
    super.initState();
    _state1 = widget.notifier1.state;
    _state2 = widget.notifier2.state;
    _state3 = widget.notifier3.state;

    widget.notifier1.addListener(_onStateChanged);
    widget.notifier2.addListener(_onStateChanged);
    widget.notifier3.addListener(_onStateChanged);
  }

  void _onStateChanged() {
    final currentState1 = widget.notifier1.state;
    final currentState2 = widget.notifier2.state;
    final currentState3 = widget.notifier3.state;

    if (widget.buildWhen?.call(_previousState1, currentState1, _previousState2,
            currentState2, _previousState3, currentState3) ??
        true) {
      setState(() {
        _state1 = currentState1;
        _state2 = currentState2;
        _state3 = currentState3;
      });
    }
    if (widget.listener != null &&
        (widget.listenWhen?.call(
                _previousState1,
                currentState1,
                _previousState2,
                currentState2,
                _previousState3,
                currentState3) ??
            true)) {
      widget.listener
          ?.call(context, currentState1, currentState2, currentState3);
    }
  }

  @override
  Widget build(BuildContext context) {
    final result = widget.builder(context, _state1, _state2, _state3);
    _previousState1 = _state1;
    _previousState2 = _state2;
    _previousState3 = _state3;
    return result;
  }

  @override
  void dispose() {
    widget.notifier1.removeListener(_onStateChanged);
    widget.notifier2.removeListener(_onStateChanged);
    widget.notifier3.removeListener(_onStateChanged);
    super.dispose();
  }
}

/// Takes a [StateNotifier] and invokes the [listener] in response to `state` changes.
/// It should be used for functionality that needs to occur only in response to
/// a `state` change such as navigation, showing a `SnackBar`, showing
/// a `Dialog`, etc...
/// The [listener] is guaranteed to only be called once for each `state` change
/// unlike the `builder` in `StateBuilder`.
class TripleStateListener<S1, S2, S3> extends StatefulWidget {
  const TripleStateListener({
    super.key,
    required this.notifier1,
    required this.notifier2,
    required this.notifier3,
    required this.listener,
    required this.child,
    this.listenWhen,
  });

  /// The first [StateNotifier] supplied to the constructor.
  final StateNotifier<S1> notifier1;

  /// The second [StateNotifier] supplied to the constructor.
  final StateNotifier<S2> notifier2;

  /// The third [StateNotifier] supplied to the constructor.
  final StateNotifier<S3> notifier3;

  /// Called when the [StateNotifier] notifies about a change and
  /// the if the `state` pass the `listenWhen` filter (if set).
  final StateListenerFunction3<S1, S2, S3> listener;

  /// The child widget to pass to the [builder].
  final Widget child;

  /// Condition to determine if the [listener] should be called or not.
  final StateConditionFunction3<S1, S2, S3>? listenWhen;

  @override
  State<TripleStateListener> createState() =>
      _TripleStateListenerState<S1, S2, S3>();
}

class _TripleStateListenerState<S1, S2, S3>
    extends State<TripleStateListener<S1, S2, S3>> {
  S1? _previousState1;
  S2? _previousState2;
  S3? _previousState3;

  @override
  void initState() {
    super.initState();
    widget.notifier1.addListener(_onStateChanged);
    widget.notifier2.addListener(_onStateChanged);
    widget.notifier3.addListener(_onStateChanged);
  }

  void _onStateChanged() {
    final currentState1 = widget.notifier1.state;
    final currentState2 = widget.notifier2.state;
    final currentState3 = widget.notifier3.state;

    if (widget.listenWhen?.call(_previousState1, currentState1, _previousState2,
            currentState2, _previousState3, currentState3) ??
        true) {
      widget.listener
          .call(context, currentState1, currentState2, currentState3);
      _previousState1 = currentState1;
      _previousState2 = currentState2;
      _previousState3 = currentState3;
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;

  @override
  void dispose() {
    widget.notifier1.removeListener(_onStateChanged);
    widget.notifier2.removeListener(_onStateChanged);
    widget.notifier3.removeListener(_onStateChanged);
    super.dispose();
  }
}

/// Signature for the `buildWhen` and `listenWhen` functions which takes
/// the previous `state` and the current `state` and is responsible
/// for returning a [bool] which determines whether to the new `state`
/// should be emitted to the expected widget.
typedef StateConditionFunction<State> = bool Function(
    State? previous, State current);

/// Signature for the `buildWhen` and `listenWhen` functions which takes
/// the previous `state` and the current `state` and is responsible
/// for returning a [bool] which determines whether to the new `state`
/// should be emitted to the expected widget.
typedef StateConditionFunction2<State1, State2> = bool Function(
    State1? previous1, State1 current1, State2? previous2, State2 current2);

/// Signature for the `buildWhen` and `listenWhen` functions which takes
/// the previous `state` and the current `state` and is responsible
/// for returning a [bool] which determines whether to the new `state`
/// should be emitted to the expected widget.
typedef StateConditionFunction3<State1, State2, State3> = bool Function(
    State1? previous1,
    State1 current1,
    State2? previous2,
    State2 current2,
    State3? previous3,
    State3 current3);

/// Signature for the `builder` and `listener` functions which takes the
/// [BuildContext] of the widget and the current `state` emitted from [StateNotifier].
typedef StateHandlerFunction<State> = Widget Function(
    BuildContext context, State state);

/// Signature for the `builder` and `listener` functions which takes the
/// [BuildContext] of the widget and the current `state` emitted from [StateNotifier].
typedef StateHandlerFunction2<State1, State2> = Widget Function(
    BuildContext context, State1 state1, State2 state2);

/// Signature for the `builder` and `listener` functions which takes the
/// [BuildContext] of the widget and the current `state` emitted from [StateNotifier].
typedef StateHandlerFunction3<State1, State2, State3> = Widget Function(
    BuildContext context, State1 state1, State2 state2, State3 state3);

/// Signature for the `builder` and `listener` functions which takes the
/// [BuildContext] of the widget and the current `state` emitted from [StateNotifier].
typedef StateListenerFunction<State> = void Function(
    BuildContext context, State state);

/// Signature for the `builder` and `listener` functions which takes the
/// [BuildContext] of the widget and the current `state` emitted from [StateNotifier].
typedef StateListenerFunction2<State1, State2> = void Function(
    BuildContext context, State1 state1, State2 state2);

/// Signature for the `builder` and `listener` functions which takes the
/// [BuildContext] of the widget and the current `state` emitted from [StateNotifier].
typedef StateListenerFunction3<State1, State2, State3> = void Function(
    BuildContext context, State1 state1, State2 state2, State3 state3);

/// Checker for the `buildWhen` and `listenWhen` functions which takes
/// the previous `state` and the current `state` and returns `true` if
/// they are not equals (aka different).
bool different<State>(State? previous, State current) => current != previous;

/// Checker for the `buildWhen` and `listenWhen` functions which takes
/// the previous `state` and the current `state` and returns `true` if
/// they are equals.
bool equals<State>(State? previous, State current) => current == previous;
