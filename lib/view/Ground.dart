import 'package:flutter/material.dart';
import 'package:flutter_tetris/view/Cell.dart';
import 'package:flutter_tetris/util/Point.dart';
import 'package:flutter_tetris/view/Shape.dart';
import 'package:flutter_tetris/constants/Global.dart';
import 'package:flutter_tetris/event/StatusEvent.dart';
import 'package:flutter_tetris/event/ScoreEvent.dart';

class Ground extends StatefulWidget {

  int hCount, vCount;
  List<List<int>> data;

  Ground({Key key, this.hCount, this.vCount}) : super(key: key) {
    this.data = generateEmptyData(vCount, hCount);
  }

  List<int> generateEmptyRow(int count) {
    List<int> list = [];
    for (int i = 0; i < count; i++) {
      list.add(0);
    }
    return list;
  }

  List<List<int>> generateEmptyData(int rowCount, int colCount) {
    List<List<int>> list = [];
    for (int row = 0; row < rowCount; row++) {
      list.add(generateEmptyRow(colCount));
    }
    return list;
  }

  @override
  State<StatefulWidget> createState() => GroundState();
}

class GroundState extends State<Ground> {

  @override
  void initState() {
    super.initState();
    Global.eventBus.on<StatusEvent>().listen((event) {
      if (event.type == Status.shapeDie) {
        Shape shape = event.shape;
        eatShape(shape);
      } else if (event.type == Status.replay) {
        // 重新开始游戏
        setState(() {
          this.widget.data = this.widget.generateEmptyData(this.widget.vCount, this.widget.hCount);
        });
      }
    });
  }

  // 将shape的数据变为自身的一部分
  eatShape(Shape shape) {
    setState(() {
      int x = shape.posX;
      int y = shape.posY;
      List<List<int>> shapeData = new List<List<int>>();
      shapeData.addAll(shape.data);
      // 这里将shape的数据清空，否则ground吃掉shape后还会短暂出现shape的数据
      shape.setEmptyData();
      for (int col = 0; col < 4; col++) {
        for (int row = 0; row < 4; row++) {
          if (shapeData[col][row] == 1) {
            this.widget.data[col + y][row + x] = 1;
          }
        }
      }
      clearFullRows();
    });
  }

  // 判断某一行是否是满行
  bool isFullRow(int rowIndex) {
    bool full = true;
    for (int i = 0; i < this.widget.hCount; i++) {
      if (this.widget.data[rowIndex][i] == 0) {
        full = false;
        break;
      }
    }
    return full;
  }

  // 移动数据
  moveRows(int fullRowIndex) {
    for (int row = fullRowIndex; row >= 0; row--) {
      for (int col = 0; col < this.widget.hCount; col++) {
        if (row > 0) {
          this.widget.data[row][col] = this.widget.data[row - 1][col];
        } else {
          this.widget.data[row][col] = 0;
        }
      }
    }
  }

  // 消除满行，从下到上检查
  clearFullRows() {
    int fullRowCount = 0;
    for (int row = this.widget.vCount - 1; row >= 0; row--) {
      if (isFullRow(row)) {
        ++fullRowCount;
        // 当前是满行，消除此行并将上面的数据依次往下移一行
        moveRows(row);
        // 消除满行后，从前面一行重新开始检查
        row += 1;
      }
    }
    if (fullRowCount > 0) {
      // 获得分数
      int score = fullRowCount * 10;
      // 通知InfoPanel刷新分数
      Global.eventBus.fire(new ScoreEvent(type: ScoreEventType.newScore, newScore: score));
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Row> rows = new List();
    for (int row = 0; row < this.widget.vCount; row++) { // 行
      List<Cell> rowData = new List<Cell>();
      for (int col = 0; col < this.widget.hCount; col++) { // 列
        Point point = new Point(row, col);
        rowData.add(new Cell(
          color: const Color(0xffcc3366),
          point: point,
          isFill: this.widget.data[row][col] == 1,
          shapeOrGroundData: this.widget.data,
          hCount: this.widget.hCount,
          vCount: this.widget.vCount,
        ));
      }
      rows.add(new Row(
          children: rowData
      ));
    }
    return new Column(children: rows);
  }
}