import 'dart:async';
import 'dart:math' show Random;

main() {
  for (int i = 0; i < 100; i++) {
    print(new Random().nextInt(27) % 9);
  }
}