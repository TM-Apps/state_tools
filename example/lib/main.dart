import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:state_tools/state_tools.dart';

import 'fruits.dart';
import 'injector.dart';
import 'observer.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  StateTools.observer = const AppStateObserver();
  StateTools.defaultStorage = await StateStorage.build(
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
          title: 'Flutter - State Tools',
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: themeMode,
          home: const MyHomePage(title: 'State Tools - Demo'),
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
              builder: (context, themeMode) => IconButton(
                  onPressed: () => context.themeStore.switchTheme(),
                  icon: Icon(themeMode == ThemeMode.light
                      ? Icons.mode_night_sharp
                      : Icons.sunny)),
            )
          ],
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 16.0),
            Padding(
                padding: const EdgeInsets.all(16.0),
                child: counterSample(context)),
            const SizedBox(height: 16.0),
            Padding(
                padding: const EdgeInsets.all(16.0),
                child: listSample(context)),
          ],
        ),
      );

  Widget counterSample(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          FloatingActionButton(
            onPressed: () => context.counterStore.decrement(),
            tooltip: 'Decrement',
            child: const Icon(Icons.remove),
          ),
          StateBuilder<int>(
            notifier: context.counterStore,
            // buildWhen: (previous, current) => current % 2 == 0,
            builder: (BuildContext context, int count) => Text(
              'Count Number: $count',
              style: context.theme.textTheme.headlineMedium,
            ),
          ),
          FloatingActionButton(
            onPressed: () => context.counterStore.increment(),
            tooltip: 'Increment',
            child: const Icon(Icons.add),
          ),
        ],
      );

  Widget listSample(BuildContext context) => Column(
        children: <Widget>[
          StreamBuilder<List<String>>(
            stream: context.fruitsState.snapshot,
            builder: (context, snapshot) {
              final fruits = snapshot.data ?? const <String>[];
              return ListView.builder(
                shrinkWrap: true,
                itemCount: fruits.length,
                itemBuilder: (context, index) => Center(
                  child: Text(
                    fruits[index],
                    style: context.theme.textTheme.headlineMedium,
                  ),
                ),
              );
            },
          ),
          ElevatedButton(
            onPressed: () => context.fruitsState.state =
                fruits[Random().nextInt(fruits.length)],
            child: const Text('Add Fruit'),
          ),
          ElevatedButton(
            onPressed: () {
              final first = context.fruitsState.first;
              if (first != null) {
                context.fruitsState.remove(first);
              }
            },
            child: const Text('Remove Fruit'),
          ),
        ],
      );
}
