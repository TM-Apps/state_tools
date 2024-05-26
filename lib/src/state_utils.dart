import 'package:meta/meta.dart';

import 'state_notifier.dart';

class StateUtils {
  static StateObserver? observer;
}

abstract class StateObserver {
  const StateObserver();

  @protected
  void onCreated(StateNotifier<dynamic> stateNotifier, dynamic initialState);

  @protected
  void onStateChanged(StateNotifier<dynamic> stateNotifier, dynamic previousState, dynamic newState);

  @protected
  void onStateRecovered(StateNotifier<dynamic> stateNotifier, dynamic state);

  @protected
  void onDisposed(StateNotifier<dynamic> stateNotifier);
}
