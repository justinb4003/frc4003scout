import 'package:flutter/material.dart';
import 'main.dart';
import 'results.dart';
import 'login.dart';

  Widget buildAppDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        //padding: EdgeInsets.zero,
        children: <Widget>[
          Container(
            height: 80,
            child: DrawerHeader(
              child: Text('Scouting Menu',
                  style: TextStyle(fontSize: 24, color: Colors.white)),
              decoration: BoxDecoration(
                color: Colors.redAccent,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.check_box),
            title: Text('Scout!'),
            onTap: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ScoutHomePage(title: 'Trisonics Scouting')));
            },
          ),
          ListTile(
            leading: Icon(Icons.data_usage),
            title: Text('Login'),
            onTap: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage(title: 'View Results')));
            },
          ),
          ListTile(
            leading: Icon(Icons.data_usage),
            title: Text('View Results'),
            onTap: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ResultsPage(title: 'View Results')));
            },
          ),
        ],
      ),
    );
  }
