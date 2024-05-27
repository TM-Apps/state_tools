// ignore_for_file: avoid_catching_errors

import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

import 'state_storage.dart';
import 'state_utils.dart';

/// {@template state_notifier}
/// State Notifier base class.
///
/// ```dart
/// class CounterState extends StateNotifier<int> {
///   CounterState() : super(0);
///
///   void increment() => state += 1;
///   void decrement() => state -= 1;
/// }
/// ```
///
/// {@endtemplate}
class StateNotifier<State> extends ChangeNotifier {
  StateNotifier(State initial) : _state = initial {
    // ignore: invalid_use_of_protected_member
    StateUtils.observer?.onCreated(this, initial);
  }

  State _state;

  State get state => _state;

  @protected
  @mustCallSuper
  set state(State value) {
    final previous = _state;
    _state = value;
    notifyListeners();
    // ignore: invalid_use_of_protected_member
    StateUtils.observer?.onStateChanged(this, previous, value);
  }

  @override
  void dispose() {
    super.dispose();
    // ignore: invalid_use_of_protected_member
    StateUtils.observer?.onDisposed(this);
  }
}

/// {@template list_state_notifier}
/// Specialized [StateNotifier] for List data types.
/// With this [StateNotifier] type you can set a filter and work with
/// only a subset (filtered items) of the main List.
///
/// ```dart
/// class EvenNumbersState extends ListStateNotifier<int> {
///   EvenNumbersState() : super(List.empty(growable: true));
///
///   void push(int value) => state = List.from(state)..add(value);
///
///   @override
///   bool filter(int value) => value % 2 == 0;
/// }
/// ```
///
/// {@endtemplate}
class ListStateNotifier<State> extends StateNotifier<List<State>> {
  ListStateNotifier(super.initial);

  /// Initialize the StateNotifier filtering the given given list parameter
  /// with the rules defined by `filter` function.
  ListStateNotifier.filtering(List<State> list) : super(List.empty()) {
    _state = list.where((value) => filter(value)).toList(growable: false);
  }

  @override
  set state(List<State> value) {
    final filteredValue = value.where((item) => filter(item));
    if (filteredValue.isNotEmpty) {
      super.state = filteredValue.toList(growable: false);
    }
  }

  void add(State value) => state = List.from(state)..add(value);
  void removeFirst(State value) => state = List.from(state)..remove(value);
  void addAll(List<State> values) => state = List.from(state)..addAll(values);
  void removeAll(State value) => state = List.from(state)..removeWhere((element) => element == value);

  /// Filter the list items when a State value is set.
  @protected
  bool filter(State value) => true;
}

/// {@template persistable_state_notifier}
/// Specialized [StateNotifier] which handles initializing the [StateNotifier]
/// state based on the persisted state. This allows state to be persisted
/// across application restarts.
///
/// ```dart
/// class CounterState extends PersistableStateNotifier<int> {
///   CounterState() : super(0);
///
///   void increment() => state += 1;
///   void decrement() => state -= 1;
///
///   @override
///   int fromJson(Map<String, dynamic> json) => json['value'] as int;
///
///   @override
///   Map<String, int> toJson(int state) => {'value': state};
/// }
/// ```
///
/// {@endtemplate}
abstract class PersistableStateNotifier<State> extends StateNotifier<State> {
  /// {@macro persistable_state_notifier}
  PersistableStateNotifier(super.initial, {Storage? storage}) {
    _storage = storage;
    recover();
  }

  Storage? _storage;

  /// A default Storage for all [PersistableStateNotifier] instances.
  static Storage? _defaultStorage;

  /// Setter for instance of default [Storage] which will be used to
  /// manage persisting/restoring the [StateNotifier] state if no one
  /// is passed on constructor.
  static set defaultStorage(Storage? storage) => _defaultStorage = storage;

  /// Instance of [Storage] which will be used to
  /// manage persisting/restoring the [StateNotifier] state.
  Storage get storage {
    final storage = _storage ?? _defaultStorage;
    if (storage == null) throw const StorageNotFound();
    return storage;
  }

  /// Populates the internal state storage with the latest state.
  void recover() {
    try {
      final stateJson = storage.read(storageToken) as Map<dynamic, dynamic>?;
      _state = stateJson != null ? _fromJson(stateJson)! : super.state;
    } catch (error, stackTrace) {
      onError(error, stackTrace);
      _state = super.state;
    }

    try {
      final stateJson = _toJson(state);
      if (stateJson != null) {
        storage.write(storageToken, stateJson).then((_) {}, onError: onError);
        // ignore: invalid_use_of_protected_member
        StateUtils.observer?.onStateRecovered(this, state);
      }
    } catch (error, stackTrace) {
      onError(error, stackTrace);
      if (error is StorageNotFound) rethrow;
    }
  }

  @override
  set state(State value) {
    super.state = value;
    try {
      final stateJson = _toJson(value);
      if (stateJson != null) {
        storage.write(storageToken, stateJson).then((_) {}, onError: onError);
      }
    } catch (error, stackTrace) {
      onError(error, stackTrace);
      rethrow;
    }
    //_state = state;
  }

  @protected
  @mustCallSuper
  void onError(Object error, StackTrace stackTrace) {
    // ignore: invalid_use_of_protected_member
  }

  State? _fromJson(dynamic json) {
    final dynamic traversedJson = _traverseRead(json);
    final castJson = _cast<Map<String, dynamic>>(traversedJson);
    return fromJson(castJson ?? <String, dynamic>{});
  }

  Map<String, dynamic>? _toJson(State state) {
    return _cast<Map<String, dynamic>>(_traverseWrite(toJson(state)).value);
  }

  dynamic _traverseRead(dynamic value) {
    if (value is Map) {
      return value.map<String, dynamic>((dynamic key, dynamic value) {
        return MapEntry<String, dynamic>(
          _cast<String>(key) ?? '',
          _traverseRead(value),
        );
      });
    }
    if (value is List) {
      for (var i = 0; i < value.length; i++) {
        value[i] = _traverseRead(value[i]);
      }
    }
    return value;
  }

  T? _cast<T>(dynamic x) => x is T ? x : null;

  _Traversed _traverseWrite(Object? value) {
    final dynamic traversedAtomicJson = _traverseAtomicJson(value);
    if (traversedAtomicJson is! NIL) {
      return _Traversed.atomic(traversedAtomicJson);
    }
    final dynamic traversedComplexJson = _traverseComplexJson(value);
    if (traversedComplexJson is! NIL) {
      return _Traversed.complex(traversedComplexJson);
    }
    try {
      _checkCycle(value);
      final dynamic customJson = _toEncodable(value);
      final dynamic traversedCustomJson = _traverseJson(customJson);
      if (traversedCustomJson is NIL) {
        throw PersistableUnsupportedError(value);
      }
      _removeSeen(value);
      return _Traversed.complex(traversedCustomJson);
    } on PersistableCyclicError catch (e) {
      throw PersistableUnsupportedError(value, cause: e);
    } on PersistableUnsupportedError {
      rethrow; // do not stack `PersistableUnsupportedError`
    } catch (e) {
      throw PersistableUnsupportedError(value, cause: e);
    }
  }

  dynamic _traverseAtomicJson(dynamic object) {
    if (object is num) {
      if (!object.isFinite) return const NIL();
      return object;
    } else if (identical(object, true)) {
      return true;
    } else if (identical(object, false)) {
      return false;
    } else if (object == null) {
      return null;
    } else if (object is String) {
      return object;
    }
    return const NIL();
  }

  dynamic _traverseComplexJson(dynamic object) {
    if (object is List) {
      if (object.isEmpty) return object;
      _checkCycle(object);
      List<dynamic>? list;
      for (var i = 0; i < object.length; i++) {
        final traversed = _traverseWrite(object[i]);
        list ??= traversed.outcome == _Outcome.atomic
            ? object.sublist(0)
            : (<dynamic>[]..length = object.length);
        list[i] = traversed.value;
      }
      _removeSeen(object);
      return list;
    } else if (object is Map) {
      _checkCycle(object);
      final map = <String, dynamic>{};
      object.forEach((dynamic key, dynamic value) {
        final castKey = _cast<String>(key);
        if (castKey != null) {
          map[castKey] = _traverseWrite(value).value;
        }
      });
      _removeSeen(object);
      return map;
    }
    return const NIL();
  }

  dynamic _traverseJson(dynamic object) {
    final dynamic traversedAtomicJson = _traverseAtomicJson(object);
    return traversedAtomicJson is! NIL
        ? traversedAtomicJson
        : _traverseComplexJson(object);
  }

  // ignore: avoid_dynamic_calls
  dynamic _toEncodable(dynamic object) => object.toJson();

  final _seen = <dynamic>[];

  void _checkCycle(Object? object) {
    for (var i = 0; i < _seen.length; i++) {
      if (identical(object, _seen[i])) {
        throw PersistableCyclicError(object);
      }
    }
    _seen.add(object);
  }

  void _removeSeen(dynamic object) {
    assert(_seen.isNotEmpty, 'seen must not be empty');
    assert(identical(_seen.last, object), 'last seen object must be identical');
    _seen.removeLast();
  }

  /// [id] is used to uniquely identify multiple instances
  /// of the same [PersistableStateNotifier] type.
  /// In most cases it is not necessary;
  /// however, if you wish to intentionally have multiple instances
  /// of the same [PersistableStateNotifier], then you must override [id]
  /// and return a unique identifier for each [PersistableStateNotifier] instance
  /// in order to keep the caches independent of each other.
  String get id => '';

  /// Storage prefix which can be overridden to provide a custom
  /// storage namespace.
  /// Defaults to [runtimeType] but should be overridden in cases
  /// where stored data should be resilient to obfuscation or persist
  /// between debug/release builds.
  String get storagePrefix => runtimeType.toString();

  /// `storageToken` is used as registration token for persistable storage.
  /// Composed of [storagePrefix] and [id].
  @nonVirtual
  String get storageToken => '$storagePrefix$id';

  /// [clear] is used to wipe or invalidate the cache of a [PersistableStateNotifier].
  /// Calling [clear] will delete the cached state of the StateNotifier
  /// but will not modify the current state of the StateNotifier.
  Future<void> clear() => storage.delete(storageToken);

  /// Responsible for converting the `Map<String, dynamic>` representation
  /// of the StateNotifier state into a concrete instance of the StateNotifier state.
  State? fromJson(Map<String, dynamic> json);

  /// Responsible for converting a concrete instance of the StateNotifier state
  /// into the the `Map<String, dynamic>` representation.
  ///
  /// If [toJson] returns `null`, then no state changes will be persisted.
  Map<String, dynamic>? toJson(State state);
}

/// Reports that an object could not be serialized due to cyclic references.
/// When the cycle is detected, a [PersistableCyclicError] is thrown.
class PersistableCyclicError extends PersistableUnsupportedError {
  /// The first object that was detected as part of a cycle.
  PersistableCyclicError(super.object);

  @override
  String toString() => 'Cyclic error while state traversing';
}

/// {@template storage_not_found}
/// Exception thrown if there was no [StateStorage] specified.
/// This is most likely due to forgetting to setup the [StateStorage]:
///
/// ```dart
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   PersistableStateNotifier.defaultStorage = await StateStorage.build();
///   runApp(MyApp());
/// }
/// ```
///
/// {@endtemplate}
class StorageNotFound implements Exception {
  /// {@macro storage_not_found}
  const StorageNotFound();

  @override
  String toString() {
    return 'Storage was accessed before it was initialized.\n'
        'Please ensure that storage has been initialized.\n\n'
        'For example:\n\n'
        'PersistableStateNotifier.defaultStorage = await StateStorage.build();';
  }
}

/// Reports that an object could not be serialized.
/// The [unsupportedObject] field holds object that failed to be serialized.
///
/// If an object isn't directly serializable, the serializer calls the `toJson`
/// method on the object. If that call fails, the error will be stored in the
/// [cause] field. If the call returns an object that isn't directly
/// serializable, the [cause] is null.
class PersistableUnsupportedError extends Error {
  /// The object that failed to be serialized.
  /// Error of attempt to serialize through `toJson` method.
  PersistableUnsupportedError(
    this.unsupportedObject, {
    this.cause,
  });

  /// The object that could not be serialized.
  final Object? unsupportedObject;

  /// The exception thrown when trying to convert the object.
  final Object? cause;

  @override
  String toString() {
    final safeString = Error.safeToString(unsupportedObject);
    final prefix = cause != null
        ? 'Converting object to an encodable object failed:'
        : 'Converting object did not return an encodable object:';
    return '$prefix $safeString';
  }
}

/// {@template NIL}
/// Type which represents objects that do not support json encoding
///
/// This should never be used and is exposed only for testing purposes.
/// {@endtemplate}
@visibleForTesting
class NIL {
  /// {@macro NIL}
  const NIL();
}

enum _Outcome { atomic, complex }

class _Traversed {
  _Traversed._({required this.outcome, required this.value});
  _Traversed.atomic(dynamic value)
      : this._(outcome: _Outcome.atomic, value: value);
  _Traversed.complex(dynamic value)
      : this._(outcome: _Outcome.complex, value: value);
  final _Outcome outcome;
  final dynamic value;
}
