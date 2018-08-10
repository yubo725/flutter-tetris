import 'package:flutter/material.dart';
import 'package:flutter_tetris/view/PlayPanel.dart';
import 'package:flutter_tetris/view/InfoPanel.dart';
import 'package:flutter_tetris/constants/Constants.dart';
import 'package:flutter_tetris/constants/Global.dart';
import 'package:flutter_tetris/event/StatusEvent.dart';
import 'dart:async';

class GameView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new GameViewState();
}

class GameViewState extends State<GameView> {

  bool measured = false;
  GlobalKey _key = new GlobalKey();
  int hCount, vCount; // 水平和垂直方向上格子的个数
  Size containerSize;
  double hPadding = 12.0;
  double vPadding = 6.0;

  double playPanelWidth, infoPanelWidth, panelHeight;

  measure() {
    new Timer(new Duration(milliseconds: 10), () {
      RenderObject obj = _key.currentContext.findRenderObject();
      while (obj == null) {
        obj = _key.currentContext.findRenderObject();
      }
      containerSize = obj.semanticBounds.size;
      hCount = (containerSize.width - hPadding) ~/ Constants.cellWidth;
      vCount = (containerSize.height - vPadding) ~/ Constants.cellWidth;
      print('hCount: $hCount, vCount: $vCount');
      panelHeight = containerSize.height;
      infoPanelWidth = 4 * Constants.cellWidth + Constants.bodyPadding * 2;
      playPanelWidth = containerSize.width - infoPanelWidth;
      setState(() {
        measured = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!measured) {
      this.measure();
      return new Expanded(
        child: new Container(
          key: _key,
          color: Colors.white,
        ),
      );
    } else {
      return new Expanded(
        flex: 1,
        child: new Row(
          children: <Widget>[
            new GestureDetector(
              child: new PlayPanel(width: playPanelWidth, height: panelHeight, hCount: hCount - 4, vCount: vCount),
              onVerticalDragEnd: (detail) {
                double speedY = detail.velocity.pixelsPerSecond.dy;
                if (speedY > 1500) {
                  // 向下滑动屏幕，让shape马上落下
                  Global.eventBus.fire(new StatusEvent(type: Status.shapeDieNow));
                }
              },
            ),
            new InfoPanel(width: infoPanelWidth, height: panelHeight, vCount: vCount)
          ],
        )
      );
    }
  }
}