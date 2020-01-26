import 'package:flutter/material.dart';

void main() => runApp(FRC4003ScoutApp());

class FRC4003ScoutApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trisonics Scouting',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: ScoutHomePage(title: 'Trisonics Scouting'),
    );
  }
}

class ScoutHomePage extends StatefulWidget {
  ScoutHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _ScoutHomePageState createState() => _ScoutHomePageState();
}

class _ScoutHomePageState extends State<ScoutHomePage> {
  String _studentName;
  String _team;
  var _studentNameList = <String>['Justin', 'Morrie', 'David', 'Kyle'];
  var _teamList = <String>['3141', '5926', '5358', '7958'];

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DropdownButton(
              value: _studentName,
              icon: Icon(Icons.person),
              onChanged: (String v) {
                setState(() {
                  debugPrint("Student name set to $v");
                  _studentName = v;
                });
              },
              items: _studentNameList.map((student) {
                return DropdownMenuItem(
                  value: student,
                  child: Text(student),
                );
              }).toList(),
            ),
            DropdownButton(
              value: _team,
              icon: Icon(Icons.device_hub),
              onChanged: (String v) {
                setState(() {
                  debugPrint("Team set to $v");
                  _team = v;
                });
              },
              items: _teamList.map((team) {
                return DropdownMenuItem(
                  value: team,
                  child: Text(team),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
