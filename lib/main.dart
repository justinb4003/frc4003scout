import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() => runApp(FRC4003ScoutApp());

// TODO: Switch back to String. We're not doing any manipulation on the team
// numbers as ints.
class Match {
  String blue1;
  String blue2;
  String blue3;
  String red1;
  String red2;
  String red3;

  Match.fromSnapshot(DocumentSnapshot snapshot)
      : blue1 = snapshot['blue1'],
        blue2 = snapshot['blue2'],
        blue3 = snapshot['blue3'],
        red1 = snapshot['red1'],
        red2 = snapshot['red2'],
        red3 = snapshot['red3'];
}

class ScoutResult {
  String scoutName;
  String teamNumber;
  bool autoLine;

  ScoutResult.fromSnapshot(DocumentSnapshot snapshot)
      : scoutName = snapshot['scout_name'],
        teamNumber = snapshot['team_number'],
        autoLine = snapshot['auto_line'];
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
  String _compName = 'stjoe';
  String _compYear = '2020';
  int _autoPortBottomScore = 0;

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
            .document(_compYear)
            .collection(_compName)
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
          items: <DropdownMenuItem<String>>[
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
            DropdownMenuItem<String>(
              value: data.red1.toString(),
              child: Text(data.red1.toString()),
            ),
            DropdownMenuItem<String>(
              value: data.red2.toString(),
              child: Text(data.red2.toString()),
            ),
            DropdownMenuItem<String>(
              value: data.red3.toString(),
              child: Text(data.red3.toString()),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildTeamStream(BuildContext context) {
    if (_matchName == null || _matchName.length == 0) {
      return LinearProgressIndicator();
    }
    debugPrint("Loading teams for $_matchName");
    return StreamBuilder(
      stream: Firestore.instance
          .collection('competitions')
          .document(_compYear)
          .collection(_compName)
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

  Widget buildAutoLine(BuildContext context, ScoutResult sr) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Text('Moved off auto line?'),
        Switch(
          onChanged: (bool b) {
            setState(() {
              Firestore.instance
                  .collection('scoutresults')
                  .document(_compYear)
                  .collection(_compName)
                  .document(_matchName)
                  .updateData({'auto_line': b});
            });
          },
          value: sr.autoLine,
        )
      ],
    );
  }

  Widget buildAutoPortBottom(BuildContext context, ScoutResult sr) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Text('Auto bottom port score'),
        IconButton(
            icon: Icon(Icons.remove),
            onPressed: () {
              setState(() {
                _autoPortBottomScore--;
              });
              Firestore.instance
                  .collection('scoutresults')
                  .document(_compYear)
                  .collection(_compName)
                  .document(_matchName)
                  .updateData({'auto_port_bottom': _autoPortBottomScore});
            }),
        Text(_autoPortBottomScore.toString()),
        IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              setState(() {
                _autoPortBottomScore++;
              });
              Firestore.instance
                  .collection('scoutresults')
                  .document(_compYear)
                  .collection(_compName)
                  .document(_matchName)
                  .updateData({'auto_port_bottom': _autoPortBottomScore});
            }),
      ],
    );
  }

  Widget build2020ScoutingWidgets(BuildContext context, ScoutResult sr) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        buildAutoLine(context, sr),
        buildAutoPortBottom(context, sr),
      ],
    );
  }

  Widget build2020ScoutingStream(BuildContext context) {
    if (_matchName == null || _matchName.length == 0) {
      return CircularProgressIndicator();
    }
    return StreamBuilder(
        stream: Firestore.instance
            .collection('scoutresults')
            .document(_compYear)
            .collection(_compName)
            .document(_matchName)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return LinearProgressIndicator();
          }
          return build2020ScoutingWidgets(
              context, ScoutResult.fromSnapshot(snapshot.data));
        });
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
            buildTeamStream(context),
            build2020ScoutingStream(context),
          ],
        ),
      ),
    );
  }
}
