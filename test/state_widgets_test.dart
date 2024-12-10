import 'package:flutter/material.dart';
import 'package:state_tools/src/state_notifier.dart';
import 'package:state_tools/src/state_widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('StateBuilder widget should notify when state changes',
      (WidgetTester tester) async {
    final subject =
        createIncrementerWidgetWithStateBuilder(TestIntStateNotifier());

    // Build our StateBuilder widget and trigger a frame.
    await tester.pumpWidget(subject);

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the 'add' button and trigger a frame.
    await tester.tap(find.text('add'));
    await tester.pump();

    // Verify that our State has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });

  testWidgets(
      'StateListener widget should fire the listener when state changes',
      (WidgetTester tester) async {
    var listenerCalled = false;

    final subject = createIncrementerWidgetWithStateListener(
        TestIntStateNotifier(), () => listenerCalled = true);

    // Build our StateBuilder widget and trigger a frame.
    await tester.pumpWidget(subject);

    // Verify that our StateListener is present.
    expect(find.text('My StateListener'), findsOneWidget);
    expect(listenerCalled, false);

    // Tap the 'add' button and trigger a frame.
    await tester.tap(find.text('add'));
    await tester.pump();

    // Verify that our StateListener fired the listener and still the same.
    expect(find.text('My StateListener'), findsOneWidget);
    expect(listenerCalled, true);
  });

  testWidgets(
      'DoubleStateBuilder widget should notify when one of the states changes',
      (WidgetTester tester) async {
    final subject = createWidgetWithDoubleStateBuilder(
        TestIntStateNotifier(), TestStringStateNotifier());

    // Build our StateBuilder widget and trigger a frame.
    await tester.pumpWidget(subject);

    // Verify that our widget starts at initial values.
    expect(find.text('0 : initial'), findsOneWidget);
    expect(find.text('1 : initial'), findsNothing);

    // Tap the 'change one' button and trigger a frame.
    await tester.tap(find.text('change one'));
    await tester.pump();

    // Verify that our State has incremented.
    expect(find.text('0 : initial'), findsNothing);
    expect(find.text('1 : initial'), findsOneWidget);
  });

  testWidgets(
      'DoubleStateBuilder widget should notify when both states changes',
      (WidgetTester tester) async {
    final subject = createWidgetWithDoubleStateBuilder(
        TestIntStateNotifier(), TestStringStateNotifier());

    // Build our StateBuilder widget and trigger a frame.
    await tester.pumpWidget(subject);

    // Verify that our widget starts at initial values.
    expect(find.text('0 : initial'), findsOneWidget);
    expect(find.text('1 : hello'), findsNothing);

    // Tap the 'change both' button and trigger a frame.
    await tester.tap(find.text('change both'));
    await tester.pump();

    // Verify that our State has incremented.
    expect(find.text('0 : initial'), findsNothing);
    expect(find.text('1 : hello'), findsOneWidget);
  });

  testWidgets(
      'Double StateListener widget should fire the listener when just one of the states changes',
      (WidgetTester tester) async {
    var listenerCalled = false;

    final subject = createWidgetWithDoubleStateListener(TestIntStateNotifier(),
        TestStringStateNotifier(), () => listenerCalled = true);

    // Build our StateBuilder widget and trigger a frame.
    await tester.pumpWidget(subject);

    // Verify that our StateListener is present.
    expect(find.text('My StateListener'), findsOneWidget);
    expect(listenerCalled, false);

    // Tap the 'change one' button and trigger a frame.
    await tester.tap(find.text('change one'));
    await tester.pump();

    // Verify that our StateListener fired the listener and still the same.
    expect(find.text('My StateListener'), findsOneWidget);
    expect(listenerCalled, true);
  });

  testWidgets(
      'Double StateListener widget should fire the listener when both states changes',
      (WidgetTester tester) async {
    var listenerCalled = false;

    final subject = createWidgetWithDoubleStateListener(TestIntStateNotifier(),
        TestStringStateNotifier(), () => listenerCalled = true);

    // Build our StateBuilder widget and trigger a frame.
    await tester.pumpWidget(subject);

    // Verify that our StateListener is present.
    expect(find.text('My StateListener'), findsOneWidget);
    expect(listenerCalled, false);

    // Tap the 'change both' button and trigger a frame.
    await tester.tap(find.text('change both'));
    await tester.pump();

    // Verify that our StateListener fired the listener and still the same.
    expect(find.text('My StateListener'), findsOneWidget);
    expect(listenerCalled, true);
  });
}

class TestIntStateNotifier extends StateNotifier<int> {
  TestIntStateNotifier() : super(0);

  void increment() => state += 1;
}

class TestStringStateNotifier extends StateNotifier<String> {
  TestStringStateNotifier() : super("initial");

  void set(String value) => state = value;
}

Widget createIncrementerWidgetWithStateBuilder(TestIntStateNotifier notifier) =>
    Directionality(
        textDirection: TextDirection.ltr,
        child: Row(children: <Widget>[
          StateBuilder<int>(
              notifier: notifier, builder: (context, state) => Text('$state')),
          TextButton(
              onPressed: () => notifier.increment(), child: const Text('add'))
        ]));

Widget createIncrementerWidgetWithStateListener(
        TestIntStateNotifier notifier, VoidCallback listenerFunction) =>
    Directionality(
        textDirection: TextDirection.ltr,
        child: Row(children: <Widget>[
          StateListener<int>(
              notifier: notifier,
              listener: (context, state) => listenerFunction.call(),
              child: const Text('My StateListener')),
          TextButton(
              onPressed: () => notifier.increment(), child: const Text('add'))
        ]));

Widget createWidgetWithDoubleStateBuilder(TestIntStateNotifier intNotifier,
        TestStringStateNotifier strNotifier) =>
    Directionality(
        textDirection: TextDirection.ltr,
        child: Row(children: <Widget>[
          DoubleStateBuilder<int, String>(
              notifier1: intNotifier,
              notifier2: strNotifier,
              builder: (context, stateInt, stateString) =>
                  Text('$stateInt : $stateString')),
          TextButton(
              onPressed: () {
                intNotifier.increment();
              },
              child: const Text('change one')),
          TextButton(
              onPressed: () {
                intNotifier.increment();
                strNotifier.set('hello');
              },
              child: const Text('change both'))
        ]));

Widget createWidgetWithDoubleStateListener(TestIntStateNotifier intNotifier,
        TestStringStateNotifier strNotifier, VoidCallback listenerFunction) =>
    Directionality(
        textDirection: TextDirection.ltr,
        child: Row(children: <Widget>[
          DoubleStateListener<int, String>(
              notifier1: intNotifier,
              notifier2: strNotifier,
              listener: (context, stateInt, stateString) =>
                  listenerFunction.call(),
              child: const Text('My StateListener')),
          TextButton(
              onPressed: () {
                intNotifier.increment();
              },
              child: const Text('change one')),
          TextButton(
              onPressed: () {
                intNotifier.increment();
                strNotifier.set('hello');
              },
              child: const Text('change both'))
        ]));
