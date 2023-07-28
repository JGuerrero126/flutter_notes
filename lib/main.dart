// ignore_for_file: prefer_const_constructors

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
  var previous = "";
  late List notesList;
  // ignore: unused_field, prefer_typing_uninitialized_variables
  var _notes;

  Future<void> getNotes() async {
    debugPrint("STARTED THE GET NOTES FUNCTION");
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var nList = prefs.getStringList("notes");
    setState(() {
      notesList = nList ?? [];
    });
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    notesList = <String>[];
    getNotes();
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

  Future<void> _removeAllNotes() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove("notes");
    setState(() {
      notesList = [];
    });
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
            SizedBox(width: 20),
            ElevatedButton(
              onPressed: () {
                debugPrint("All Notes Deleted");
                _removeAllNotes();
                _controller.clear();
                setState(() {
                  previous = "";
                });
              },
              child: Text("Delete All Notes"),
            ),
          ],
        ),
        Expanded(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: notesList.length,
            itemBuilder: (context, index) {
              return Dismissible(
                  background: Container(
                    color: Colors.amberAccent,
                  ),
                  key: UniqueKey(),
                  onDismissed: (DismissDirection direction) => {
                        setState(() {
                          notesList.removeAt(index);
                          previous = "";
                        })
                      },
                  confirmDismiss: (direction) async {
                    return await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text("Confirm"),
                          content: const Text(
                              "Are you sure you wish to delete this item?"),
                          actions: <Widget>[
                            TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                                child: const Text("DELETE")),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text("CANCEL"),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: ListTile(
                    title: Text(notesList[index]),
                    onTap: () => {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => NotePage())

                          // _controller.text = notesList[index],
                          // _setPrevious(notesList[index])
                          )
                    },
                  ));
            },
          ),
        )
      ]),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class NotePage extends StatelessWidget {
  const NotePage({super.key, note});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Note Page'),
      ),
      body: Center(
        child: Text('Hi There'),
      ),
    );
  }
}
