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
  bool _controller = false;
  bool _crossedHABLine = false;

  /* Magic strings everywhere but... we can fix this at a later date */
  var _studentNameList = <String>['', 'Justin', 'Morrie', 'David', 'Kyle'];
  var _teamList = <String>['', '3141', '5926', '5358', '7958'];
  /* Soon
  var _startLocationList = <String>['Left', 'Center', 'Right'];
  var _startHabLevelList = <String>['None', '1', '2'];
  var _rocketLevelList = <int>[0, 1, 2, 3];
  var _habLevelEndList = <String>['None', '0', '1', '2', '3'];
  var _liftOthersList = <String>['None', '0', '1', '2'];
  */

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
            setState(() {
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
            setState(() {
              _team = v;
            });
            debugPrint("Team set to $v");
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

  void rebuildTeamList() async {
    setState(() {
      _teamList = <String>['', '4004', '254', '76', '238'];
      if (!_teamList.contains(_team)) {
        _team = _teamList[0];
      }
    });
  }

  void rebuildStudentList() async {
    debugPrint('Rebuilding student list has begun.');
    setState(() {
      _studentNameList = <String>['', 'Chad', 'Justin', 'Morrie', 'David', 'Kyle'];
      if (!_studentNameList.contains(_studentName)) {
        // We've selected an item no longer in the list
        // Default to the first one for lack of a better choice
        _studentName = _studentNameList[0];
      }
    });
  }

  /* 
   * This method just shows how you can kick off methods that result in changes
   * to member variables which trigger a redraw of UI elements. It's a pretty
   * slick way of letting async calls out to external data sources play nicely.
   * There's no figuring out when to redraw or mark things dirty. The 'junk' is
   * just sort of handled nicely in the background.
   */
  Widget buildExampleButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        RaisedButton(
          onPressed: () {
            rebuildTeamList();
            rebuildStudentList();
          },
          child: Text("Grab External Data"),
        )
      ],
    );
  }

  Widget buildControllerPrompt(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Text('Controller?'),
        Switch(
          onChanged: (bool b) {
            setState(() {
              _controller = b;
            });
          },
          value: _controller,
        )
      ],
    );
  }

  Widget buildHABLinePrompt(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Text('Crossed HAB line??'),
        Switch(
          onChanged: (bool b) {
            setState(() {
              _crossedHABLine = b;
            });
          },
          value: _crossedHABLine,
        )
      ],
    );
  }

  Widget buildSandstorm(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        buildControllerPrompt(context),
        buildHABLinePrompt(context),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called and setState detects a
    // change warrants a rebuild of the UI.
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
            buildExampleButtons(context),
            buildSandstorm(context),
          ],
        ),
      ),
    );
  }
}
