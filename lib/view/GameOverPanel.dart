import 'package:flutter/material.dart';

class GameOverPanel extends StatelessWidget {

  double width, height;
  TextStyle style = new TextStyle(
    fontSize: 32.0,
    color: Colors.blue,
    fontWeight: FontWeight.bold
  );

  GameOverPanel({Key key, this.width, this.height}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new Container(
      width: this.width,
      height: this.height,
      color: const Color(0x90000000),
      child: new Center(
        child: new Text("GAME OVER", style: style)
      ),
    );
  }
}