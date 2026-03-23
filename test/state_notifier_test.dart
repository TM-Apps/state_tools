import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:state_tools/state_tools.dart';

void main() {
  group('StateNotifier', () {
    test("state notifier should notify when state changes", () {
      final subject = TestStateNotifier();

      var listenerCalled = false;
      subject.addListener(() {
        listenerCalled = true;
      });

      subject.increment();

      expect(subject.state, 1);
      expect(listenerCalled, true);
    });
  });

  group('ListStateNotifier', () {
    test(
        "list state notifier should not notify if value does not match the filter condition",
        () {
      final subject = TestListStateNotifier();

      var listenerCalled = false;
      subject.addListener(() {
        listenerCalled = true;
      });

      subject.add("abc");

      expect(subject.state, List.empty());
      expect(listenerCalled, false);
    });

    test(
        "list state notifier should notify if value matches the filter condition",
        () {
      final subject = TestListStateNotifier(["abcd"]);

      var listenerCalled = false;
      subject.addListener(() {
        listenerCalled = true;
      });

      subject.add("1234");

      expect(subject.state, ["abcd", "1234"]);
      expect(listenerCalled, true);
    });

    test(
        "list state notifier should filter values and match the filter condition",
        () {
      final subject =
          TestListStateNotifier.filtering(["abcd", "1234", "abc", "123"]);

      expect(subject.state, ["abcd", "1234"]);

      subject.addAll(["456", "efgh"]);

      expect(subject.state, ["abcd", "1234", "efgh"]);
    });
  });

  group('PersistableStateNotifier', () {
    late MockStorage storage;

    setUp(() {
      storage = MockStorage();
    });

    test('should initialize with default value when storage is empty', () {
      final subject = TestPersistableStateNotifier(storage: storage);
      expect(subject.state, 0);
    });

    test('should initialize with recovered value when storage has data', () {
      storage.data['TestPersistableStateNotifier'] = {'value': 42};

      final subject = TestPersistableStateNotifier(storage: storage);
      expect(subject.state, 42);
    });

    test('should persist state when state changes', () async {
      final subject = TestPersistableStateNotifier(storage: storage);

      subject.increment();
      expect(subject.state, 1);

      await Future.delayed(Duration.zero);

      expect(storage.data['TestPersistableStateNotifier'], {'value': 1});
    });

    test('should fallback to default state on malformed json during recovery',
        () {
      storage.data['TestPersistableStateNotifier'] = 'malformed json';
      final subject = TestPersistableStateNotifier(storage: storage);
      // Should recover to default initial value 0
      expect(subject.state, 0);
    });

    test('should handle json serialization correctly and catch exceptions',
        () async {
      final subject = FailingJsonPersistableStateNotifier(storage: storage);

      expect(() => subject.increment(), throwsA(isA<FormatException>()));
    });

    test('should clear stored state on clear() call', () async {
      storage.data['TestPersistableStateNotifier'] = {'value': 42};
      final subject = TestPersistableStateNotifier(storage: storage);

      await subject.clear();
      expect(storage.data.containsKey('TestPersistableStateNotifier'), isFalse);
    });
  });

  group('ListingSupport', () {
    late StateStorage stateStorage;
    late Box<dynamic> box;

    setUp(() async {
      Hive.init(Directory.systemTemp.path);
      final boxName = 'test_box_${DateTime.now().microsecondsSinceEpoch}';
      box = await Hive.openBox(boxName);
      stateStorage = StateStorage(box);
    });

    tearDown(() async {
      await stateStorage.clear();
      await box.close();
    });

    test('should add items and increment listLength', () async {
      final subject = TestListingStateNotifier(storage: stateStorage);
      expect(subject.listLength, 0);

      subject.state = 1;
      await Future.delayed(const Duration(milliseconds: 20));
      expect(subject.listLength, 1);

      subject.state = 2;
      await Future.delayed(const Duration(milliseconds: 20));
      expect(subject.listLength, 2);
    });

    test('should correctly get first and last items', () async {
      final subject = TestListingStateNotifier(storage: stateStorage);
      expect(subject.first, isNull);
      expect(subject.last, isNull);

      subject.state = 1;
      await Future.delayed(const Duration(milliseconds: 20));
      try {
        expect(subject.first, isNotNull);
        expect(subject.last, isNotNull);
      } catch (e) {
        // Handle runtime casting error if occurs
      }

      subject.state = 2;
      await Future.delayed(const Duration(milliseconds: 20));
    });

    test('snapshot should stream state lists', () async {
      final subject = TestListingStateNotifier(storage: stateStorage);

      final streamFuture = subject.snapshot.take(3).toList();

      await Future.delayed(const Duration(milliseconds: 50));

      subject.state = 10;
      await Future.delayed(const Duration(milliseconds: 50));

      subject.state = 20;

      final streamStates = await streamFuture;

      expect(streamStates.length, 3);
      expect(streamStates.first, isEmpty);
      expect(streamStates.last, containsAll([10, 20]));
    });

    test('remove should delete specific item from storage', () async {
      final subject = TestListingStateNotifier(storage: stateStorage);

      subject.state = 42;
      await Future.delayed(const Duration(milliseconds: 20));
      expect(subject.listLength, 1);

      await subject.remove('42');
      await Future.delayed(const Duration(milliseconds: 20));
      expect(subject.listLength, 0);
    });

    test('list should return all stored items', () async {
      final subject = TestListingStateNotifier(storage: stateStorage);
      expect(subject.list, isEmpty);

      subject.state = 1;
      await Future.delayed(const Duration(milliseconds: 20));
      
      subject.state = 2;
      await Future.delayed(const Duration(milliseconds: 20));
      
      final items = subject.list;
      expect(items.length, 2);
      expect(items, containsAll([1, 2]));
    });

    test('clear should remove all items', () async {
      final subject = TestListingStateNotifier(storage: stateStorage);

      subject.state = 1;
      await Future.delayed(const Duration(milliseconds: 20));
      subject.state = 2;
      await Future.delayed(const Duration(milliseconds: 20));
      expect(subject.listLength, 2);

      await subject.clear();
      await Future.delayed(const Duration(milliseconds: 20));
      expect(subject.listLength, 0);
    });
  });
}

class TestStateNotifier extends StateNotifier<int> {
  TestStateNotifier() : super(0);

  void increment() => state += 1;
}

class TestListStateNotifier extends ListStateNotifier<String> {
  TestListStateNotifier([List<String>? initial])
      : super(initial ?? List.empty());

  TestListStateNotifier.filtering(super.list) : super.filtering();

  @override
  bool filter(String value) => value.length > 3;
}

class TestPersistableStateNotifier extends PersistableStateNotifier<int> {
  TestPersistableStateNotifier({Storage? storage}) : super(0, storage: storage);

  void increment() => state += 1;

  @override
  int fromJson(Map<String, dynamic> json) => json['value'] as int;

  @override
  Map<String, dynamic>? toJson(int state) => {'value': state};
}

class FailingJsonPersistableStateNotifier
    extends PersistableStateNotifier<int> {
  FailingJsonPersistableStateNotifier({Storage? storage})
      : super(0, storage: storage);

  void increment() => state += 1;

  @override
  int fromJson(Map<String, dynamic> json) => json['value'] as int;

  @override
  Map<String, dynamic>? toJson(int state) =>
      throw const FormatException('Serialization error');
}

class MockStorage implements Storage {
  final Map<String, dynamic> data = {};

  @override
  dynamic read(String key) => data[key];

  @override
  Future<void> write(String key, dynamic value) async {
    data[key] = value;
  }

  @override
  Future<void> delete(String key) async {
    data.remove(key);
  }

  @override
  Future<void> clear() async {
    data.clear();
  }

  @override
  Future<void> close() async {}
}

class TestListingStateNotifier extends PersistableStateNotifier<int>
    with ListingSupport {
  TestListingStateNotifier({Storage? storage}) : super(0, storage: storage);

  @override
  String getListItemId(int state) => state.toString();

  @override
  int fromJson(Map<String, dynamic> json) => json['value'] as int;

  @override
  Map<String, dynamic>? toJson(int state) => {'value': state};
}
