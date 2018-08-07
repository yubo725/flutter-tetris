
enum ScoreEventType {
  newScore
}

class ScoreEvent {
  ScoreEventType type;
  int newScore;

  ScoreEvent({this.type, this.newScore});
}