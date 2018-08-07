import 'package:flutter/material.dart';
import 'package:flutter_tetris/constants/Constants.dart';
import 'package:flutter_tetris/view/Shape.dart';
import 'package:flutter_tetris/view/Ground.dart';
import 'package:flutter_tetris/constants/Global.dart';
import 'package:flutter_tetris/event/StatusEvent.dart';
import 'package:flutter_tetris/view/PausePanel.dart';
import 'package:flutter_tetris/view/GameOverPanel.dart';

class PlayPanel extends StatefulWidget {

  int hCount, vCount;
  double width, height;
  Shape shape;
  Ground ground;
  PausePanel pausePanel;
  GameOverPanel gameOverPanel;

  PlayPanel({Key key, this.width, this.height, this.hCount, this.vCount}) : super(key: key) {
    this.ground = new Ground(hCount: hCount, vCount: vCount);
    this.shape = new Shape(hCount: hCount, vCount: vCount, ground: this.ground);
    this.pausePanel = new PausePanel(width: hCount * Constants.cellWidth, height: vCount * Constants.cellWidth);
    this.gameOverPanel = new GameOverPanel(width: hCount * Constants.cellWidth, height: vCount * Constants.cellWidth);
  }

  @override
  State<StatefulWidget> createState() => PlayPanelState();
}

class PlayPanelState extends State<PlayPanel> {

  bool isPause = false;
  bool isGameOver = false;

  @override
  void initState() {
    super.initState();
    Global.eventBus.on<StatusEvent>().listen((event) {
      if (event.type == Status.gamePause) {
        setState(() {
          this.isPause = event.isPause;
        });
      } else if (event.type == Status.gameOver) {
        setState(() {
          this.isGameOver = true;
        });
      } else if (event.type == Status.replay) {
        setState(() {
          this.isGameOver = false;
          this.isPause = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> items = [
      this.widget.shape,
      this.widget.ground
    ];
    if (isPause) {
      items.add(this.widget.pausePanel);
    }
    if (isGameOver) {
      items.add(this.widget.gameOverPanel);
    }
    return new Container(
      margin: const EdgeInsets.all(Constants.bodyPadding),
      width: this.widget.width - Constants.bodyPadding * 2,
      height: this.widget.height - Constants.bodyPadding * 2,
      color: Colors.blue,
      child: new Center(
        child: new Container(
          width: this.widget.hCount * Constants.cellWidth,
          height: this.widget.vCount * Constants.cellWidth,
          color: Colors.white,
          child: new Stack(children: items)
        ),
      ),
    );
  }

}