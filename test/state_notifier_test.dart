import 'package:state_tools/src/state_notifier.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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

  test("list state notifier should not notify if value does not match the filter condition", () {
    final subject = TestListStateNotifier();

    var listenerCalled = false;
    subject.addListener(() {
      listenerCalled = true;
    });

    subject.add("abc");

    expect(subject.state, List.empty());
    expect(listenerCalled, false);
  });

  test("list state notifier should notify if value matches the filter condition", () {
    final subject = TestListStateNotifier(["abcd"]);

    var listenerCalled = false;
    subject.addListener(() {
      listenerCalled = true;
    });

    subject.add("1234");

    expect(subject.state, ["abcd", "1234"]);
    expect(listenerCalled, true);
  });

  test("list state notifier should filter values and match the filter condition", () {
    final subject = TestListStateNotifier.filtering(["abcd", "1234", "abc", "123"]);

    expect(subject.state, ["abcd", "1234"]);

    subject.addAll(["456", "efgh"]);

    expect(subject.state, ["abcd", "1234", "efgh"]);
  });
}

class TestStateNotifier extends StateNotifier<int> {
  TestStateNotifier() : super(0);

  void increment() => state += 1;
}

class TestListStateNotifier extends ListStateNotifier<String> {
  TestListStateNotifier([List<String>? initial]) : super(initial ?? List.empty());

  TestListStateNotifier.filtering(super.list) : super.filtering();

  @override
  bool filter(String value) => value.length > 3;
}
