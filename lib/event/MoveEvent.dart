
enum MoveEventType {
  moveLeft, moveRight, moveDown, transform
}

class MoveEvent {
  MoveEventType type;

  MoveEvent({this.type});
}