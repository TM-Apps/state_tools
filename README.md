# State Tools

A light and simple State Manager for Flutter Apps.

## How Simple?

#### 1. Create your [StateNotifier](lib/state/state_notifier.dart) class:
```dart
class CounterState extends StateNotifier<int> {
  CounterState() : super(0);
  
  void increment() => state += 1;
}
```

if you want a specialized type for Lists:
```dart
class CounterState extends ListStateNotifier<int> {
  CounterState() : super(List.empty());

  void push(int value) => add(value * 2);

  @override
  bool filter(int value) => value % 2 == 0;
}
```

You can apply a filter for items on list (**not mandatory**).<br/>
This filter will be applied every time the list value change.

Also, the [ListStateNotifier](lib/state/state_notifier.dart#L69) offers prebuilt helper modifiers, like:
- add(item)
- removeFist(item)
- addAll([ list of items ])
- removeAll([ list of items ])

#### 2. On your Widget use a [StateBuilder](lib/state/state_widgets.dart) to interact with your `StateNotifier`
```dart
StateBuilder<int>(
  notifier: counterStateInstance,
  builder: (context, state) => Text('$state')
)

...

FloatingActionButton(
  onPressed: () => counterStateInstance.increment(),
  tooltip: 'Increment',
  child: const Icon(Icons.add),
)
```

Or... you can just listen the changes and do your Non-UI related logic:

```dart
StateListener<int>(
  notifier: counterStateInstance,
  listener: (context, state) => log('$state'),
  child: const Text('My StateListener')
)
```

Since version 1.1.0, it's possible to build and to listen more than just one state at same time, with `DoubleStateBuilder`, `DoubleStateListener`, `TripleStateBuilder` and `TripleStateListener`:

```dart
DoubleStateBuilder<int, String>(
  notifier1: counterStateInstance,
  notifier2: textStateInstance,
  builder: (context, counter, text) => Text('$state : $text')
)

...

TripleStateListener<int, String, bool>(
  notifier1: counterStateInstance,
  notifier2: textStateInstance,
  notifier3: boolStateInstance,
  listener: (context, counter, text, boolValue) => log('$state : $text : $boolValue'),
  child: const Text('My TripleStateListener')
)
```

## Want More?

If you wish, you can use the [PersistableStateNotifier](lib/state/state_notifier.dart#L117)
```dart
class CounterState extends PersistableStateNotifier<int> {
  CounterState() : super(0);
     
  void increment() => state += 1;

  @override
  int fromJson(Map<String, dynamic> json) => json['value'] as int;
  
  @override
  Map<String, int> toJson(int state) => {'value': state};
}
```

## Interested?

Add `state_notifier` package on your App:
```yaml
state_tools: 1.1.0
```

## License

    Copyright 2024 TMApps
    
    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at
    
       http://www.apache.org/licenses/LICENSE-2.0
    
    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.