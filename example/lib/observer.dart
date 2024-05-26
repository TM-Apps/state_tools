import 'package:flutter/widgets.dart';
import 'package:state_tools/state_tools.dart';

class AppStateObserver extends StateObserver {
  const AppStateObserver();

  @override
  void onCreated(StateNotifier stateNotifier, initialState) {
    debugPrint('${stateNotifier.runtimeType} => created with initial state: $initialState');
  }

  @override
  void onStateChanged(StateNotifier stateNotifier, previousState, newState) {
    debugPrint('${stateNotifier.runtimeType}: $previousState => $newState');
  }

  @override
  void onStateRecovered(StateNotifier stateNotifier, state) {
    debugPrint('${stateNotifier.runtimeType} => recovered state: $state');
  }

  @override
  void onDisposed(StateNotifier stateNotifier) {
    debugPrint('${stateNotifier.runtimeType} => disposed');
  }
}
