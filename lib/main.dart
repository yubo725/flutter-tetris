import 'package:flutter/material.dart';
import 'splash.dart';
import 'view/ControllerBar.dart';
import 'view/GameView.dart';
import 'dart:async';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new MyAppState();
}

class MyAppState extends State<MyApp> {

  bool showSplash = true;

  @override
  Widget build(BuildContext context) {
    if (showSplash) {
      new Timer(new Duration(seconds: 2), () {
        setState(() {
          showSplash = false;
        });
      });
      return SplashPage();
    }
    return new MaterialApp(
      title: "Tetris",
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text("俄罗斯方块"),
        ),
        body: new Column(
          children: <Widget>[
            new GameView(),
            new ControllerBar()
          ],
        )
      ),
    );
  }
}