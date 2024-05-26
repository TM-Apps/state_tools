import 'package:flutter/material.dart';
import 'package:state_tools/src/state_notifier.dart';
import 'package:state_tools/src/state_widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('StateBuilder widget should notify when state changes', (WidgetTester tester) async {
    final subject = createIncrementerWidgetWithStateBuilder(TestStateNotifier());

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

  testWidgets('StateListener widget should fire the listener when state changes', (WidgetTester tester) async {
    var listenerCalled = false;

    final subject = createIncrementerWidgetWithStateListener(
        TestStateNotifier(),
        () => listenerCalled = true
    );

    // Build our StateBuilder widget and trigger a frame.
    await tester.pumpWidget(subject);

    // Verify that our StateListener is present.
    expect(find.text('My StateListener'), findsOneWidget);

    // Tap the 'add' button and trigger a frame.
    await tester.tap(find.text('add'));
    await tester.pump();

    // Verify that our StateListener fired the listener and still the same.
    expect(find.text('My StateListener'), findsOneWidget);
    expect(listenerCalled, true);
  });
}

class TestStateNotifier extends StateNotifier<int> {
  TestStateNotifier() : super(0);

  void increment() => state += 1;
}

Widget createIncrementerWidgetWithStateBuilder(TestStateNotifier notifier) =>
  Directionality(
    textDirection: TextDirection.ltr,
    child: Row(
      children: <Widget>[
        StateBuilder<int>(
          notifier: notifier,
          builder: (context, state) => Text('$state')
        ),
        TextButton(
          onPressed: () => notifier.increment(),
          child: const Text('add')
        )
      ]
    )
  );

Widget createIncrementerWidgetWithStateListener(
  TestStateNotifier notifier,
  VoidCallback listenerFunction
) => Directionality(
  textDirection: TextDirection.ltr,
  child: Row(
    children: <Widget>[
      StateListener<int>(
        notifier: notifier,
        listener: (context, state) => listenerFunction.call(),
        child: const Text('My StateListener')
      ),
      TextButton(
        onPressed: () => notifier.increment(),
        child: const Text('add')
      )
    ]
  )
);
