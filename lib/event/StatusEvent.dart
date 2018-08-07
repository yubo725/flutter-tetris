import 'package:flutter_tetris/view/Shape.dart';

enum Status {
  // shape死掉的事件
  shapeDie,

  // 生产新的图形
  newShape,

  // shape马上落到最底下
  shapeDieNow,

  // 下一个图形的数据
  nextShapeData,

  // 游戏结束
  gameOver,

  // 游戏暂停
  gamePause,

  // 重玩游戏
  replay
}

class StatusEvent {
  Status type;
  Shape shape;
  List<List<List<int>>> nextShapeData;
  bool isPause;

  StatusEvent({this.type, this.shape, this.nextShapeData, this.isPause});
}

