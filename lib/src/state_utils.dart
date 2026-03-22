part of '../state_tools.dart';

@Deprecated("Use [StateTools] instead")
class StateUtils {
  @Deprecated("Use [StateTools.observer] instead")
  static set observer(StateObserver? observer) =>
      StateTools.observer = observer;
}

class StateTools {
  /// A [StateObserver] which will be used to notify about state changes.
  static StateObserver? observer;

  /// A default Storage for all persistable [StateNotifier] instances.
  static Storage? defaultStorage;
}

/// A [StateObserver] which will be used to notify about state changes.
/// The observer notify each state changing on events:
/// - [onCreated]: when a [StateNotifier] is created.
/// - [onStateChanged]: when a [StateNotifier] state is changed.
/// - [onStateRecovered]: when a [StateNotifier] state is recovered.
/// - [onDisposed]: when a [StateNotifier] is disposed.
abstract class StateObserver {
  const StateObserver();

  @protected
  void onCreated(StateNotifier<dynamic> stateNotifier, dynamic initialState);

  @protected
  void onStateChanged(StateNotifier<dynamic> stateNotifier,
      dynamic previousState, dynamic newState);

  @protected
  void onStateRecovered(StateNotifier<dynamic> stateNotifier, dynamic state);

  @protected
  void onDisposed(StateNotifier<dynamic> stateNotifier);
}
