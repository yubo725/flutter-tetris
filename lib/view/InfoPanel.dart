import 'package:flutter/material.dart';
import 'package:flutter_tetris/view/Shape.dart';
import 'package:flutter_tetris/util/ShapeFactory.dart';
import 'package:flutter_tetris/constants/Global.dart';
import 'package:flutter_tetris/event/StatusEvent.dart';
import 'package:flutter_tetris/constants/Constants.dart';
import 'package:flutter_tetris/event/ScoreEvent.dart';

import 'dart:async';

class InfoPanel extends StatefulWidget {

  double width, height;
  int vCount;
  Shape nextShape;

  InfoPanel({Key key, this.width, this.height, this.vCount}) : super(key: key) {
    nextShape = new Shape.withData(new ShapeFactory().getEmptyShapeData());
  }

  @override
  State<StatefulWidget> createState() => InfoPanelState();
}

class InfoPanelState extends State<InfoPanel> {

  TextStyle valueTextStyle = new TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.bold,
    color: Colors.blue
  );

  // 得分字符串
  String scoreStr = '0分';
  // 已游戏时间（字符串）
  String playTimeStr = '0秒';
  // 已游戏的时间（秒）
  int playTime = 0;
  // 定时器，1秒更新一次数据
  Timer timer;
  // 总分数
  int totalScore = 0;
  // 游戏是否暂停
  bool isPause = false;
  // 游戏是否结束
  bool isGameOver = false;
  String btnText = '暂停';

  @override
  void initState() {
    super.initState();
    Global.eventBus.on<StatusEvent>().listen((event) {
      if (event.type == Status.nextShapeData) {
        setState(() {
          this.widget.nextShape.shapeData = event.nextShapeData;
          this.widget.nextShape.data = event.nextShapeData[0];
        });
      } else if (event.type == Status.gameOver) {
        setState(() {
          btnText = '重玩';
          isGameOver = true;
        });
        // 游戏结束，停止计时
        if (this.timer != null) {
          this.timer.cancel();
        }
      }
    });
    Global.eventBus.on<ScoreEvent>().listen((event) {
      if (event.type == ScoreEventType.newScore) {
        int newScore = event.newScore;
        totalScore += newScore;
        setState(() {
          scoreStr = '$totalScore分';
        });
      }
    });
    startTimer();
  }

  // 开始计时
  startTimer() {
    this.timer = new Timer.periodic(new Duration(seconds: 1), (timer) {
      this.playTime++;
      String timeStr = '';
      if (this.playTime <= 60) {
        timeStr = '${this.playTime}秒';
      } else if (this.playTime <= 3600) {
        int minutes = this.playTime ~/ 60;
        int secs = this.playTime - minutes * 60;
        timeStr = '${minutes}分${secs}秒';
      }
      setState(() {
        this.playTimeStr = timeStr;
      });
    });
  }

  // 暂停游戏，暂停计时
  pauseGame() {
    String s = '暂停';
    if (isPause) {
      s = '继续';
      if (this.timer != null) {
        this.timer.cancel();
      }
    } else {
      startTimer();
    }
    setState(() {
      btnText = s;
    });
  }

  @override
  Widget build(BuildContext context) {
    var nextShapeView = new Column(
      children: <Widget>[
        new Text("下一个:"),
        this.widget.nextShape.getShapeView()
      ],
    );
    var timeView = new Column(
      children: <Widget>[
        new Text("耗时:"),
        new Text(playTimeStr, style: valueTextStyle)
      ],
    );
    var scoreView = new Column(
      children: <Widget>[
        new Text("得分:"),
        new Text(scoreStr, style: valueTextStyle)
      ],
    );
    var pauseBtn = new RaisedButton(
      onPressed: () {
        if (isGameOver) {
          // 重新开始游戏
          setState(() {
            isPause = false;
            isGameOver = false;
            btnText = '暂停';
          });
          Global.eventBus.fire(new StatusEvent(type: Status.replay));
          return;
        }
        // 发送游戏暂停的通知
        isPause = !isPause;
        pauseGame();
        Global.eventBus.fire(new StatusEvent(type: Status.gamePause, isPause: isPause));
      },
      child: new Text(btnText),
    );
    var rankBtn = new RaisedButton(
      onPressed: () {},
      child: new Text("排行榜"),
    );
    return new Container(
      margin: const EdgeInsets.fromLTRB(0.0, Constants.bodyPadding, Constants.bodyPadding, Constants.bodyPadding),
      width: this.widget.width - Constants.bodyPadding,
      height: this.widget.height - Constants.bodyPadding * 2,
      color: Colors.blue,
      child: new Center(
        child: new Container(
          padding: const EdgeInsets.fromLTRB(0.0, 30.0, 0.0, 30.0),
          width: 4 * Constants.cellWidth,
          height: this.widget.vCount * Constants.cellWidth,
          color: Colors.white,
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              nextShapeView,
              timeView,
              scoreView,
              pauseBtn,
              rankBtn
            ],
          ),
        ),
      ),
    );
  }
}