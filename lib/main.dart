// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

// import 'dart:math';

// import 'dart:js_util';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

var uuid = Uuid();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.amber,
      ),
      home: const MyHomePage(title: 'Notes'),
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
  late TextEditingController _controller;

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  late Future<List> _notes;
  var previous = "";
  var notesList = <String>[];

  @override
  void initState() {
    super.initState();
    _notes = _prefs.then((SharedPreferences prefs) {
      notesList = prefs.getStringList("notes") ?? [];
      return prefs.getStringList("notes") ?? [];
    });
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _saveNote(givenValue) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var id = uuid.v4();
    await prefs.setString(id, givenValue);
    var nList = prefs.getStringList("notes") ?? [];
    nList.add(givenValue);

    setState(() {
      _notes = prefs.setStringList("notes", nList).then((bool success) {
        return nList;
      });
      notesList = nList;
    });
    debugPrint(nList.toString());
  }

  Future<void> _removeNotes(givenValue) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(givenValue);
    var nList = prefs.getStringList("notes");
    nList!.remove(givenValue);
    setState(() {
      _notes = prefs.setStringList("notes", nList).then((bool success) {
        return nList;
      });
      notesList = nList;
    });
    debugPrint(nList.toString());
  }

  Future<void> _saveEditedNote(prev, givenValue) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var nList = prefs.getStringList("notes") ?? [];
    var ind = nList.indexOf(prev.toString());
    debugPrint(ind.toString());
    nList.setAll(ind, [givenValue]);

    setState(() {
      _notes = prefs.setStringList("notes", nList).then((bool success) {
        return nList;
      });
      notesList = nList;
    });
    debugPrint(nList.toString());
  }

  Future<void> _setPrevious(givenValue) async {
    setState(() {
      previous = givenValue.toString();
    });
    debugPrint(previous);
  }

  @override
  Widget build(BuildContext context) {
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      body: Column(children: [
        AppBar(
          centerTitle: true,
          title: Text("Notes"),
        ),
        TextField(
          controller: _controller,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Enter Note Here',
          ),
          onSubmitted: (value) => {
            if (previous.isEmpty)
              {_saveNote(value)}
            else
              {_saveEditedNote(previous, value)}
          },
          onChanged: (value) => {debugPrint(value), debugPrint(previous)},
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                debugPrint("Note Saved");
                if (previous.isEmpty) {
                  _saveNote(_controller.text);
                } else {
                  _saveEditedNote(previous, _controller.text);
                }
              },
              child: Text("Save"),
            ),
            SizedBox(width: 20),
            ElevatedButton(
              onPressed: () {
                debugPrint("New Note Started");
                _controller.clear();
                setState(() {
                  previous = "";
                });
              },
              child: Text("New Note"),
            ),
          ],
        ),
        Expanded(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: notesList.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(notesList[index]),
                onTap: () => {
                  _controller.text = notesList[index],
                  _setPrevious(notesList[index])
                },
                trailing: IconButton(
                  icon: const Icon(Icons.remove_circle),
                  onPressed: () => _removeNotes(notesList[index]),
                ),
              );
            },
          ),
        )
      ]),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
