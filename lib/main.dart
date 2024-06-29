library;

export 'package:fancy_list_view/src/fancy_list_view.dart';

// Remove before publish
import 'dart:math';
import 'package:fancy_list_view/src/fancy_list_controller.dart';
import 'package:flutter/material.dart';
import 'package:fancy_list_view/src/fancy_list_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<StatefulWidget> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    final FancyListController controller = FancyListController();

    return Scaffold(
      body: Column(children: [
        Container(
          height: 155,
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            FloatingActionButton(
              backgroundColor: Colors.green,
              onPressed: () {
                controller.addItem(Container(
                  color: Colors.green,
                ));
              },
              child: const Icon(Icons.add),
            ),
            FloatingActionButton(
              backgroundColor: Colors.blue,
              onPressed: () {
                controller.addItemAt(
                    Container(
                      color: Colors.blue,
                    ),
                    1);
              },
              child: const Icon(Icons.create_new_folder_rounded),
            ),
            FloatingActionButton(
              backgroundColor: Colors.red,
              onPressed: () {
                controller.removeItemAt(3);
              },
              child: const Icon(Icons.delete_rounded),
            ),
          ]),
        ),
        FancyListView(
            controller: controller,
            clipBehavior: Clip.antiAlias,
            height: MediaQuery.sizeOf(context).height,
            itemHeight: 155,
            children: [1, 2, 3, 4, 5]
                .map((e) => Container(
                      color: Color((Random().nextDouble() * 0xFFFFFF).toInt())
                          .withOpacity(1.0),
                    ))
                .toList())
      ]),
    );
  }
}
