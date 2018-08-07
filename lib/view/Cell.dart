import 'package:flutter/material.dart';
import 'package:flutter_tetris/constants/Constants.dart';
import 'package:flutter_tetris/util/Point.dart';

// Cell代表一个正方形的小方块，一个Shape是由多个小方块组成的
class Cell extends StatefulWidget {
  Color color = Colors.blue; // 小方块的颜色
  Point point; // 表示Shape内这个Cell的坐标
  bool isFill; // 是否填充
  List<List<int>> shapeOrGroundData;

  BorderSide _borderThin = new BorderSide(width: 0.5, color: Colors.grey);
  BorderSide _borderBold = new BorderSide(width: 1.0, color: Colors.grey);

  int hCount;
  int vCount;

  Cell({Key key, this.color, this.point, this.isFill, this.shapeOrGroundData, this.hCount = 4, this.vCount = 4}) : super(key: key);

  Border generateBorder() {
    int x = this.point.x;
    int y = this.point.y;
    BorderSide leftBorder = _borderThin;
    BorderSide topBorder = _borderThin;
    BorderSide rightBorder = _borderThin;
    BorderSide bottomBorder = _borderThin;
    if (isFill) {
      if (x == 0 || (this.shapeOrGroundData[x - 1][y] == 0)) {
        topBorder = _borderBold;
      }
      if (x == vCount - 1 || (this.shapeOrGroundData[x + 1][y] == 0)) {
        bottomBorder = _borderBold;
      }
      if (y == 0 || (this.shapeOrGroundData[x][y - 1] == 0)) {
        leftBorder = _borderBold;
      }
      if (y == hCount - 1 || (this.shapeOrGroundData[x][y + 1] == 0)) {
        rightBorder = _borderBold;
      }
    }
    return new Border(
      left: leftBorder,
      top: topBorder,
      right: rightBorder,
      bottom: bottomBorder
    );
  }

  @override
  State<StatefulWidget> createState() => new CellState();
}

class CellState extends State<Cell> {
  @override
  Widget build(BuildContext context) {
    if (this.widget.isFill) {
      return new Container(
        width: Constants.cellWidth,
        height: Constants.cellWidth,
        decoration: new BoxDecoration(
          color: this.widget.color,
          border: this.widget.generateBorder()
        ),
      );
    }
    return new Container(
      width: Constants.cellWidth,
      height: Constants.cellWidth,
      color: Colors.transparent
    );
  }
}
