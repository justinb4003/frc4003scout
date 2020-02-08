import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'drawer.dart';
import 'results.dart';

void main() => runApp(FRC4003ScoutApp());

/*
 * Container class that holds data on a student.
 */
class Student {
  final String key;
  final String name;
  /* Dart has an handy constrcutor syntax to handle a common initialization case.  This is the equivalent to:
  Student(String key, String name) {
    this.key = key;
    this.name = name;
  }
  ... because that happens so often you sometimes find shortcuts for it.  This is Dart's.
  */
  Student(this.key, this.name);

  // JJB: you need to override this or the DropDown controls flip out about
  // having 0 or 2+ possible items for any value.
  bool operator ==(Object other) => other is Student && other.key == key;
  // ... and if you override == you should override hashCode
  int get hashCode => key.hashCode;
}

/*
 * Container class that holds data on a team.
 */
class Team {
  String teamNumber;
  String teamName;
  String schoolName;
  Team(this.teamNumber, this.teamName, this.schoolName);
  Team.fromSnapshot(DocumentSnapshot snapshot)
      : teamNumber = snapshot.documentID,
        teamName = snapshot['team_name'],
        schoolName = snapshot['school_name'];
  bool operator ==(Object other) =>
      other is Team && other.teamNumber == teamNumber;
  int get hashCode => teamNumber.hashCode;
}

/*
 * Class that represents the data we're storing for every scouted match in Firecloud.
 */
class ScoutResult {
  bool autoLine = false;
  int autoPortBottom = 0;

  ScoutResult.fromSnapshot(DocumentSnapshot snapshot)
      : autoLine =
            snapshot['auto_line'] == null ? false : snapshot['auto_line'],
        autoPortBottom = snapshot['auto_port_bottom'] == null
            ? 0
            : snapshot['auto_port_bottom'];
}

// Unused class, keeping around for now.
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
  Student _studentObj;
  Team _teamObj;
  String _matchNumber;
  bool _matchBegun;

  /* 
    * JJB: 
    * Part of me says this should be selectable and part of me says this might
    * as well be baked into the app to make really sure everybody is running
    * the proper version and nobody can possibly get confused and select the
    * wrong week.
    * It's not lazy programming.  I thought this through. 
    */
  String _compName = 'misjo';
  String _compYear = '2020';

  @override
  void initState() {
    super.initState();
    _matchNumber = "1";
    _matchBegun = false;
  }

  String getCurrDocumentID() {
    return "$_compYear:$_compName:${_teamObj.teamNumber}:${_studentObj.key}:$_matchNumber";
  }

  void printCurrUser() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    if (user == null) {
      debugPrint("You are not currently authenticated.");
    } else {
      debugPrint("Current user: ${user.uid}");
    }
  }

  Widget buildStudentSelector(BuildContext context) {
    printCurrUser();
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
              DropdownButton<Student>(
                value: _studentObj,
                onChanged: (Student v) {
                  /*
                  debugPrint("Student key set to ${v.key}");
                  debugPrint("Student name set to ${v.name}");
                  */
                  setState(() {
                    _studentObj = v;
                  });
                },
                items:
                    snapshot.data.documents.map<DropdownMenuItem<Student>>((d) {
                  /*
                  debugPrint("Student documentID dump: ${d.documentID}");
                  debugPrint("Student name dump: ${d['name']}");
                  */
                  return DropdownMenuItem<Student>(
                    value: Student(d.documentID, d['name']),
                    child: Text(d['name']),
                  );
                }).toList(),
              ),
            ],
          );
        });
  }

  Widget buildTeamSelector(BuildContext context) {
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
              Text('Who are they?'),
              DropdownButton<Team>(
                value: _teamObj,
                onChanged: (Team v) async {
                  setState(() {
                    _teamObj = v;
                  });
                  bool mb =
                      await checkResultsDocumentExists(getCurrDocumentID());
                  setState(() {
                    _matchBegun = mb;
                  });
                },
                items: snapshot.data.documents.map<DropdownMenuItem<Team>>((d) {
                  /*
                  debugPrint("Team documentID dump: ${d.documentID}");
                  debugPrint("Team name dump: ${d['team_name']}");
                  */
                  return DropdownMenuItem<Team>(
                    value: Team(d.documentID, d['team_name'], d['school_name']),
                    child: Text(d.documentID),
                  );
                }).toList(),
              ),
            ],
          );
        });
  }

  Widget buildTeamDisplay(BuildContext context) {
    if (_teamObj != null && _teamObj.teamName.length > 0) {
      return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[Text('You have selected ${_teamObj.teamName}')]);
    }
    return SizedBox.shrink();
  }

  Widget buildStartButton(BuildContext context) {
    if (_teamObj != null && _teamObj.teamName.length > 0) {
      return Visibility(
          visible: _matchBegun == false,
          child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                RaisedButton(
                    child: Text('Begin scouting!'),
                    onPressed: () {
                      setState(() {
                        _matchBegun = true;
                      });
                      createScoutResultDocument();
                    })
              ]));
    }
    return SizedBox.shrink();
  }

  Widget buildAutoLine(BuildContext context, ScoutResult sr) {
    if (_studentObj == null) {
      return Text('select student first.');
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Text('Moved off auto line?'),
        Switch(
          onChanged: (bool b) {
            setState(() {
              Firestore.instance
                  .collection('scoutresults')
                  .document(getCurrDocumentID())
                  .updateData({'auto_line': b});
            });
          },
          value: sr.autoLine,
        )
      ],
    );
  }

  Widget buildAutoPortBottom(BuildContext context, ScoutResult sr) {
    if (_studentObj == null) {
      return Text('select student first.');
    }
    // JJB: Note the pre-increment version of ++ and -- below; they're not the
    // typical post increment that you see.  We're doing ++c not c++.
    // There is a difference.
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Text('Auto bottom port score'),
        IconButton(
            icon: Icon(Icons.remove),
            onPressed: () {
              Firestore.instance
                  .collection('scoutresults')
                  .document(getCurrDocumentID())
                  .updateData({'auto_port_bottom': --sr.autoPortBottom});
            }),
        Text(sr.autoPortBottom.toString()),
        IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Firestore.instance
                  .collection('scoutresults')
                  .document(getCurrDocumentID())
                  .updateData({'auto_port_bottom': ++sr.autoPortBottom});
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

  Future<bool> checkResultsDocumentExists(String docID) async {
    final snap = await Firestore.instance
        .collection('scoutresults')
        .document(getCurrDocumentID())
        .get();
    return snap.exists;
  }

  void createScoutResultDocument() async {
    // Prefixing an async function call with await forces it to await for it to finish.
    // This returns us to a synchronous programming model.
    final snap = await Firestore.instance
        .collection('scoutresults')
        .document(getCurrDocumentID())
        .get();
    if (snap.exists) {
      return; // Nothing needs to be done.
    }

    var d = {
      'student_name': _studentObj.name,
      'auto_line': false,
      'auto_port_bottom': 0
    };
    Firestore.instance
        .collection('scoutresults')
        .document(getCurrDocumentID())
        .setData(d);
  }

  Widget build2020ScoutingStream(BuildContext context) {
    if (_matchNumber == null ||
        _matchNumber.length == 0 ||
        _teamObj == null ||
        _teamObj.teamNumber.length == 0 ||
        _studentObj == null) {
      return SizedBox.shrink();
    }

    return StreamBuilder(
        stream: Firestore.instance
            .collection('scoutresults')
            .document(getCurrDocumentID())
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData ||
              snapshot.data == null ||
              !snapshot.data.exists) {
            return SizedBox.shrink();
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
      drawer: buildAppDrawer(context),
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
            buildTeamDisplay(context),
            buildStartButton(context),
            build2020ScoutingStream(context),
          ],
        ),
      ),
    );
  }
}
