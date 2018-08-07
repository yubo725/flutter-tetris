import 'package:flutter/material.dart';

class PausePanel extends StatelessWidget {

  double width, height;
  TextStyle textStyle;

  PausePanel({Key key, this.width, this.height}) : super(key: key) {
    textStyle = new TextStyle(
      fontSize: 28.0,
      color: Colors.white,
      fontWeight: FontWeight.bold
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      width: this.width,
      height: this.height,
      color: Color(0x50000000),
      child: new Center(
        child: new Text("游戏已暂停", style: textStyle)
      ),
    );
  }
}