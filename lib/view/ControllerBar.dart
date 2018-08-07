import 'package:flutter/material.dart';
import 'package:flutter_tetris/constants/Global.dart';
import 'package:flutter_tetris/event/MoveEvent.dart';

class CustomButton extends StatelessWidget {

  double width, height;
  VoidCallback onPress;
  String iconPath;

  CustomButton({Key key, this.width, this.height, this.onPress, this.iconPath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new InkWell(
      onTap: this.onPress,
      child: new Container(
        padding: const EdgeInsets.all(10.0),
        width: this.width,
        height: this.height,
        child: new Center(
          child: new Image.asset(this.iconPath, fit: BoxFit.contain),
        ),
        decoration: new BoxDecoration(
          color: const Color(0xffcccccc),
          border: new Border.all(
            width: 1.0,
            color: Colors.white,
          ),
          borderRadius: new BorderRadius.all(new Radius.circular(6.0))
        ),
      ),
    );
  }
}

class ControllerBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Row row = new Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        new CustomButton(
          width: 80.0,
          height: 50.0,
          iconPath: 'images/arrow_left.png',
          onPress: () {
            Global.eventBus.fire(new MoveEvent(type: MoveEventType.moveLeft));
          },
        ),
        new CustomButton(
          width: 120.0,
          height: 50.0,
          iconPath: 'images/arrow_up.png',
          onPress: () {
            Global.eventBus.fire(new MoveEvent(type: MoveEventType.transform));
          },
        ),
        new CustomButton(
          width: 80.0,
          height: 50.0,
          iconPath: 'images/arrow_right.png',
          onPress: () {
            Global.eventBus.fire(new MoveEvent(type: MoveEventType.moveRight));
          },
        )
      ],
    );
    Padding padding = new Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 10.0),
      child: row,
    );
    return new Container(
      child: padding,
      color: Colors.blue,
    );
  }
}