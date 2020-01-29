import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() => runApp(FRC4003ScoutApp());


class Match {
  int blue1;
  int blue2;
  int blue3;

  Match.fromSnapshot(DocumentSnapshot snapshot)
  : blue1 = snapshot['blue1'],
    blue2 = snapshot['blue2'],
    blue3 = snapshot['blue3'];
}

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
  String _matchName;
  bool _controller = false;
  bool _crossedHABLine = false;

  Widget buildStudentSelector(BuildContext context) {
    return StreamBuilder(
        stream: Firestore.instance.collection('students').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return LinearProgressIndicator();
          }
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
                items: snapshot.data.documents
                    .map<DropdownMenuItem<String>>((student) {
                  return DropdownMenuItem<String>(
                    value: student['name'],
                    child: Text(student['name']),
                  );
                }).toList(),
              ),
            ],
          );
        });
  }

  Widget buildMatchSelector(BuildContext context) {
    /* 
     * JJB: 
     * Part of me says this should be selectable and part of me says this might
     * as well be baked into the app to make really sure everybody is running
     * the proper version and nobody can possibly get confused and select the
     * wrong week.context
     * It's not lazy programming.  I thought this through. 
     */
    return StreamBuilder(
        stream: Firestore.instance
            .collection('competitions')
            .document('2020')
            .collection('stjoe')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return LinearProgressIndicator();
          }
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Text('Which match?'),
              DropdownButton(
                value: _matchName,
                icon: Icon(Icons.map),
                onChanged: (String v) {
                  debugPrint("Match name set to $v");
                  setState(() {
                    _matchName = v;
                  });
                },
                items:
                    snapshot.data.documents.map<DropdownMenuItem<String>>((d) {
                  return DropdownMenuItem<String>(
                    value: d.documentID,
                    child: Text(d.documentID),
                  );
                }).toList(),
              ),
            ],
          );
        });
  }

  Widget buildTeamDropdown(BuildContext context, Match data) {
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
            items:
              <DropdownMenuItem<String>>[
                DropdownMenuItem<String>(
                  value: data.blue1.toString(),
                  child: Text(data.blue1.toString()),
                ),
                DropdownMenuItem<String>(
                  value: data.blue2.toString(),
                  child: Text(data.blue2.toString()),
                ),
                DropdownMenuItem<String>(
                  value: data.blue3.toString(),
                  child: Text(data.blue3.toString()),
                ),
              ],
          ),
        ],
      );
  }

  Widget buildTeamSelector(BuildContext context) {
    if (_matchName == null || _matchName.length == 0) {
      return LinearProgressIndicator();
    }
    debugPrint("Loading teams for $_matchName");
    return StreamBuilder(
      stream: Firestore.instance
          .collection('competitions')
          .document('2020')
          .collection('stjoe')
          .document(_matchName)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return LinearProgressIndicator();
        }
        return buildTeamDropdown(context, Match.fromSnapshot(snapshot.data));
      },
    );
  }

  Widget buildAutoLine(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Text('Moved off auto line?'),
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

  Widget buildAutoPowercells(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Text('Power cells bottom'),
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

  Widget buildAutoWidgets(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        buildAutoLine(context),
        buildHABLinePrompt(context),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called and setState detects a
    // change that warrants a rebuild of the UI.
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
            buildMatchSelector(context),
            buildTeamSelector(context),
            buildAutoWidgets(context),
          ],
        ),
      ),
    );
  }
}
