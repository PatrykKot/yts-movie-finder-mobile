import 'package:flutter/material.dart';

import 'torrent/page/MainPage.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YTS Movie Finder',
      theme: ThemeData(primarySwatch: Colors.blue, brightness: Brightness.dark),
      home: MainPage(),
    );
  }
}
