import 'package:flutter/material.dart';
import 'package:flutter_tetris/view/Cell.dart';
import 'package:flutter_tetris/util/Point.dart';
import 'package:flutter_tetris/event/MoveEvent.dart';
import 'package:flutter_tetris/event/StatusEvent.dart';
import 'package:flutter_tetris/constants/Global.dart';
import 'package:flutter_tetris/view/Ground.dart';
import 'package:flutter_tetris/util/ShapeFactory.dart';
import 'dart:async';

// 代表一个图形
class Shape extends StatefulWidget {

  int autoMoveDownDuration = 300;
  int curIndex = 0;
  bool isShapeDie = true;
  ShapeFactory factory = new ShapeFactory();
  List<List<List<int>>> shapeData, nextShapeData;

  // 当前图形的数据，为4x4的矩阵
  List<List<int>> data;
  final int initPosY = 0;
  // 图形右上角在游戏区域的坐标
  int posX, posY;
  // 图形所在的游戏区域，水平和垂直方向的方格数
  int hCount, vCount;

  Ground ground;

  Shape({Key key, this.hCount, this.vCount, this.ground}) : super(key: key) {
    this.shapeData = factory.getRandomShapeData();
    this.data = shapeData[0];
    this.posX = hCount ~/ 2 - 2;
    this.posY = initPosY;
    initNextShapeData();
  }

  Shape.withData(List<List<List<int>>> withData) {
    this.shapeData = withData;
    this.data = withData[0];
  }

  initNextShapeData() {
    nextShapeData = factory.getRandomShapeData();
    new Timer(new Duration(seconds: 1), () {
      Global.eventBus.fire(new StatusEvent(type: Status.nextShapeData, nextShapeData: nextShapeData));
    });
  }

  resetShape() {
    this.shapeData = this.nextShapeData;
    this.data = shapeData[0];
    this.posX = hCount ~/ 2 - 2;
    this.posY = initPosY;
    initNextShapeData();
  }

  setEmptyData() {
    this.shapeData = factory.getEmptyShapeData();
    this.data = shapeData[0];
  }

  // 获取4*4的图形
  Widget getShapeView() {
    List<Row> rows = new List();
    for (int row = 0; row < 4; row++) {
      List<Cell> rowData = new List<Cell>();
      for (int col = 0; col < 4; col++) {
        Point point = new Point(col, row);
        rowData.add(new Cell(color: Colors.blue, point: point, isFill: data[row][col] == 1, shapeOrGroundData: data));
      }
      rows.add(new Row(children: rowData));
    }
    return new Column(children: rows);
  }

  @override
  State<StatefulWidget> createState() => ShapeState();
}

class ShapeState extends State<Shape> {

  Timer shapeTimer;
  bool isPause = false;

  // 判断图形的某一列是否存在实心Cell
  bool colContainFillCell(int colIndex, {List<List<int>> data}) {
    List<List<int>> list = this.widget.data;
    if (data != null) {
      list = data;
    }
    for (int i = 0; i < 4; i++) {
      if (list[i][colIndex] == 1) {
        return true;
      }
    }
    return false;
  }

  // 判断图形的某一行是否存在实心Cell
  bool rowContainFillCell(int rowIndex, {List<List<int>> data}) {
    List<List<int>> list = this.widget.data;
    if (data != null) {
      list = data;
    }
    for (int i = 0; i < 4; i++) {
      if (list[rowIndex][i] == 1) {
        return true;
      }
    }
    return false;
  }

  // 向下移动图形
  void moveDown() {
    setState(() {
      this.widget.posY += 1;
    });
  }

  // 向左移动图形
  void moveLeft() {
    if (!this.widget.isShapeDie && !isPause &&  canMoveLeft()) {
      setState(() {
        this.widget.posX -= 1;
      });
    }
  }

  // 是否能左移
  bool canMoveLeft() {
    int x = this.widget.posX - 1;
    for (int col = 0; col < 4; col++) {
      if (colContainFillCell(col) && x + col < 0) {
        return false;
      }
    }
    List<List<int>> groundData = this.widget.ground.data;
    for (int row = 0; row < 4; row++) {
      for (int col = 0; col < 4; col++) {
        if (this.widget.data[row][col] == 1 && groundData[row + this.widget.posY][col + x] == 1) {
          return false;
        }
      }
    }
    return true;
  }

  // 向右移动图形
  void moveRight() {
    if (!this.widget.isShapeDie && !isPause &&  canMoveRight()) {
      setState(() {
        this.widget.posX += 1;
      });
    }
  }

  // 是否能右移
  bool canMoveRight() {
    int x = this.widget.posX + 1;
    for (int col = 3; col >= 0; col--) {
      if (colContainFillCell(col) && x + col + 1 > this.widget.hCount) {
        return false;
      }
    }
    List<List<int>> groundData = this.widget.ground.data;
    for (int row = 0; row < 4; row++) {
      for (int col = 0; col < 4; col++) {
        if (this.widget.data[row][col] == 1 && groundData[row + this.widget.posY][col + x] == 1) {
          return false;
        }
      }
    }
    return true;
  }

  // 是否能下落
  bool canMoveDown() {
    // 判断是否有触底的
    for (int row = 3; row >= 0; row--) {
      if (rowContainFillCell(row) && this.widget.posY + row + 1 >= this.widget.vCount) {
        return false;
      }
    }
    // 判断是否有跟ground相交的
    List<List<int>> groundData = this.widget.ground.data;
    int x = this.widget.posX;
    int y = this.widget.posY + 1;
    for (int row = 0; row < 4; row++) {
      for (int col = 0; col < 4; col++) {
        if (this.widget.data[row][col] == 1 && groundData[row + y][col + x] == 1) {
          return false;
        }
      }
    }
    return true;
  }

  // 旋转图形
  void transform() {
    if (!isPause && canTransform()) {
      setState(() {
        this.widget.curIndex = (this.widget.curIndex + 1) % 4;
        this.widget.data = this.widget.shapeData[this.widget.curIndex];
      });
    }
  }

  // 是否能切换到下一个形状
  bool canTransform() {
    List<List<int>> nextShapeData = this.widget.shapeData[(this.widget.curIndex + 1) % 4];
    // 是否超出左边界
    for (int i = 0; i < 4; i++) {
      if (colContainFillCell(i, data: nextShapeData) && this.widget.posX + i < 0) {
        return false;
      }
    }
    // 是否超出右边界
    for (int i = 3; i >= 0; i--) {
      if (colContainFillCell(i, data: nextShapeData) && this.widget.posX + i + 1 > this.widget.hCount) {
        return false;
      }
    }
    // 是否超出下边界
    for (int i = 3; i >= 0; i--) {
      if (rowContainFillCell(i, data: nextShapeData) && this.widget.posY + i + 1 > this.widget.vCount) {
        return false;
      }
    }
    // 是否和ground重合
    List<List<int>> groundData = this.widget.ground.data;
    for (int row = 0; row < 4; row++) {
      for (int col = 0; col < 4; col++) {
        if (nextShapeData[row][col] == 1 && groundData[row + this.widget.posY][col + this.widget.posX] == 1) {
          return false;
        }
      }
    }
    return true;
  }

  // 判断坐标是否落在Shape图形中
  bool isPosInShapeArea(Point p) { // Point, x表示col, y表示row
    return (p != null) && (p.x >= this.widget.posX && p.x <= this.widget.posX + 3
      && p.y >= this.widget.posY && p.y <= this.widget.posY + 3);
  }

  @override
  void initState() {
    super.initState();
    Global.eventBus.on<MoveEvent>().listen((event) {
      switch (event.type) {
        case MoveEventType.moveLeft:
          moveLeft();
          break;
        case MoveEventType.moveRight:
          moveRight();
          break;
        case MoveEventType.moveDown:
          moveDown();
          break;
        case MoveEventType.transform:
          transform();
          break;
      }
    });
    Global.eventBus.on<StatusEvent>().listen((event) {
      if (event.type == Status.shapeDieNow && !this.widget.isShapeDie && !isPause) {
        // 让shape立即落下到最底部成为ground的一部分
        setShapeDieNow();
      } else if (event.type == Status.gamePause) {
        isPause = event.isPause;
        if (event.isPause) {
          // 暂停
          if (this.shapeTimer != null) {
            this.shapeTimer.cancel();
          }
        } else {
          // 继续
          startAutoMoveDown();
        }
      } else if (event.type == Status.replay) {
        // 重新开始游戏
        setState(() {
          isPause = false;
          this.widget.resetShape();
          startAutoMoveDown();
        });
      }
    });
    startAutoMoveDown();
  }

  gameOver() {
    print("fire event, game over...");
    Global.eventBus.fire(new StatusEvent(type: Status.gameOver));
  }

  // 让shape立刻落下
  setShapeDieNow() {
    // 停止shape的自动下落
    if (this.shapeTimer != null) {
      this.shapeTimer.cancel();
    }
    int y = this.widget.posY;
    while (canMoveDown()) {
      y = ++this.widget.posY;
    }
    setState(() {
      this.widget.posY = y;
    });
    this.widget.isShapeDie = true;
    // 通知Ground图形死掉
    Global.eventBus.fire(new StatusEvent(type: Status.shapeDie, shape: this.widget));
    if (this.widget.posY == this.widget.initPosY) {
      // game over
      print('game over...');
      gameOver();
      return;
    }
    // 创建新的shape
    new Timer(new Duration(milliseconds: 100), () {
      this.widget.resetShape();
      startAutoMoveDown();
    });
  }

  // 图形自动下落
  startAutoMoveDown() {
    shapeTimer = new Timer.periodic(new Duration(milliseconds: this.widget.autoMoveDownDuration), (timer) {
      if (canMoveDown()) {
        this.widget.isShapeDie = false;
        moveDown();
      } else {
        this.widget.isShapeDie = true;
        // 通知Ground图形死掉
        Global.eventBus.fire(new StatusEvent(type: Status.shapeDie, shape: this.widget));
        timer.cancel();
        if (this.widget.posY == this.widget.initPosY) {
          // game over
          print('game over...');
          gameOver();
          return;
        }
        // 创建新的shape
        new Timer(new Duration(milliseconds: 500), () {
          this.widget.resetShape();
          startAutoMoveDown();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Row> rows = new List();
    for (int row = 0; row < this.widget.vCount; row++) {  // 行
      List<Cell> rowData = new List<Cell>();
      for (int col = 0; col < this.widget.hCount; col++) { // 列
        Point point = new Point(col, row);
        if (isPosInShapeArea(point)) {
          // 如果坐标在图形内，就根据图形的数据生成Cell
          rowData.add(new Cell(
            color: Colors.blue,
            point: new Point(col - this.widget.posX, row - this.widget.posY),
            isFill: this.widget.data[row - this.widget.posY][col - this.widget.posX] == 1,
            shapeOrGroundData: this.widget.data
          ));
        } else {
          // 如果坐标不在图形内，则生成透明的Cell
          rowData.add(new Cell(color: Colors.blue, point: new Point(0, 0), isFill: false, shapeOrGroundData: this.widget.data));
        }
      }
      rows.add(new Row(
        children: rowData
      ));
    }
    return new Column(children: rows);
  }

}