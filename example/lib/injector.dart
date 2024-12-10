import 'package:flutter/material.dart';

import 'counter.dart';
import 'theme.dart';

/// Dependency Injector widget which acts as a Service Locator.
class Injector extends InheritedWidget {
  Injector({super.key, required super.child});

  final _DependenciesGraph _deps = _DependenciesGraph();

  static Injector of(BuildContext context) {
    final result = context.dependOnInheritedWidgetOfExactType<Injector>();
    assert(result != null, 'No Injector found in context');
    return result!;
  }

  // No need to notify when Injector is rebuilt
  // as this is just a Service Locator class.
  @override
  bool updateShouldNotify(Injector oldWidget) => false;
}

class _DependenciesGraph {
  _DependenciesGraph();

  CounterStore? _counterStore;
  ThemeStore? _themeStore;

  CounterStore get counterStore => _counterStore ??= CounterStore();
  ThemeStore get themeStore => _themeStore ??= ThemeStore();
}

extension InjectorExtension on BuildContext {
  ThemeData get theme => Theme.of(this);

  CounterStore get counterStore => Injector.of(this)._deps.counterStore;
  ThemeStore get themeStore => Injector.of(this)._deps.themeStore;
}
