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

  Widget buildStudentSelector(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Text('Who are you?'),
        DropdownButton(
          value: _studentName,
          icon: Icon(Icons.person),
          onChanged: (String v) {
            debugPrint("Student name set to $v");
            _studentName = v;
          },
          items: _studentNameList.map((student) {
            return DropdownMenuItem(
              value: student,
              child: Text(student),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget buildTeamSelector(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Text('Who are they?'),
        DropdownButton(
          value: _team,
          icon: Icon(Icons.device_hub),
          onChanged: (String v) {
            debugPrint("Team set to $v");
            _team = v;
          },
          items: _teamList.map((team) {
            return DropdownMenuItem(
              value: team,
              child: Text(team),
            );
          }).toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called.
    // It's like magic.  OoOoOo!
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            buildStudentSelector(context),
            buildTeamSelector(context),
          ],
        ),
      ),
    );
  }
}
