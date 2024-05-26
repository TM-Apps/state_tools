import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:state_tools/state_tools.dart';

import 'injector.dart';
import 'observer.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  StateUtils.observer = const AppStateObserver();
  PersistableStateNotifier.defaultStorage = await StateStorage.build(
    storageDirectory: kIsWeb 
        ? StateStorage.webStorageDirectory
        : await getTemporaryDirectory(),
  );
  runApp(Injector(child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => StateBuilder<ThemeMode>(
    notifier: context.themeStore,
    builder: (BuildContext context, ThemeMode themeMode) => MaterialApp(
      title: 'Flutter - State Manager',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeMode,
      home: const MyHomePage(title: 'State Manager - Demo'),
      debugShowCheckedModeBanner: false,
    ),
  );
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      title: Text(widget.title),
      actions: [
        StateBuilder<ThemeMode>(
          notifier: context.themeStore,
          builder: (context, themeMode) =>
            IconButton(
              onPressed: () => context.themeStore.switchTheme(),
              icon: Icon(themeMode == ThemeMode.light ? Icons.mode_night_sharp : Icons.sunny)
          ),
        )
      ],
    ),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Text('Count Number:'),
          StateBuilder<int>(
            notifier: context.counterStore,
            // buildWhen: (previous, current) => current % 2 == 0,
            builder: (BuildContext context, int count) => Text(
              '$count',
              style: context.theme.textTheme.headlineMedium,
            ),
          ),
        ],
      ),
    ),
    floatingActionButton: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: FloatingActionButton(
            onPressed: () => context.counterStore.decrement(),
            tooltip: 'Decrement',
            child: const Icon(Icons.remove),
          ),
        ),
        FloatingActionButton(
          onPressed: () => context.counterStore.increment(),
          tooltip: 'Increment',
          child: const Icon(Icons.add),
        ),
      ],
    ),
  );
}
