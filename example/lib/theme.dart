import 'package:flutter/material.dart';
import 'package:state_tools/state_tools.dart';
 
class ThemeStore extends PersistableStateNotifier<ThemeMode> {
  ThemeStore() : super(ThemeMode.light);
  // static final ThemeStore _instance = ThemeStore._();

  // ThemeStore._() : super(ThemeMode.light);

  // Eager Loadings
  // static ThemeStore get instance => _instance;

  void switchTheme() {
    state = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
  }

  ThemeMode _fromString(String value) => value == 'light' ? ThemeMode.light : ThemeMode.dark;
  String _toString(ThemeMode mode) => mode == ThemeMode.light ? 'light' : 'dark';

  @override
  ThemeMode fromJson(Map<String, dynamic> json) => _fromString(json['theme'] as String);

  @override
  Map<String, String> toJson(ThemeMode state) => {'theme': _toString(state)};
}

ThemeData get lightTheme => ThemeData.light().copyWith(
  colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple)
);

ThemeData get darkTheme => ThemeData.dark().copyWith(
  colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey)
);
