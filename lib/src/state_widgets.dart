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

/// Signature for the `buildWhen` and `listenWhen` functions which takes 
/// the previous `state` and the current `state` and is responsible 
/// for returning a [bool] which determines whether to the new `state` 
/// should be emitted to the expected widget.
typedef StateConditionFunction<State> = bool Function(State? previous, State current);

/// Signature for the `builder` and `listener` functions which takes the 
/// [BuildContext] of the widget and the current `state` emitted from [StateNotifier].
typedef StateHandlerFunction<State> = Widget Function(BuildContext context, State state);

/// Signature for the `builder` and `listener` functions which takes the
/// [BuildContext] of the widget and the current `state` emitted from [StateNotifier].
typedef StateListenerFunction<State> = void Function(BuildContext context, State state);

/// Checker for the `buildWhen` and `listenWhen` functions which takes 
/// the previous `state` and the current `state` and returns `true` if 
/// they are not equals (aka different).
bool different<State>(State? previous, State current) => current != previous;

/// Checker for the `buildWhen` and `listenWhen` functions which takes 
/// the previous `state` and the current `state` and returns `true` if 
/// they are equals.
bool equals<State>(State? previous, State current) => current == previous;
