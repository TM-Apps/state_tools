import 'package:state_tools/state_tools.dart';

class CounterStore extends PersistableStateNotifier<int> {
  CounterStore() : super(0);
  // static CounterStore? _instance;

  // CounterStore._() : super(0);

  // Lazy Loading
  // static CounterStore get instance => _instance ??= CounterStore._();

  void decrement() => state -= 1;
  void increment() => state += 1;

  @override
  int fromJson(Map<String, dynamic> json) => json['value'] as int;

  @override
  Map<String, int> toJson(int state) => {'value': state};
}
