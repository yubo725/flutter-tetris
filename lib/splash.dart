import 'package:flutter/material.dart';

class SplashPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: "Splash",
      home: new Scaffold(
        body: new Body()
      )
    );
  }
}

class Body extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    MediaQueryData data = MediaQuery.of(context);
    return new Container(
      width: data.size.width,
      height: data.size.height,
      color: Colors.blue,
      child: new Center(
        child: new Text(
          "Flutter Tetris",
          textDirection: TextDirection.ltr,
          style: new TextStyle(
            fontSize: 30.0,
            color: Colors.white
          ),
        )
      )
    );
  }
}