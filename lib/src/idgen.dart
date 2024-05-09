import "dart:math";

const _idMax = 1 << 32;
const _maxScope = 1 << 53;

int generateSessionID() {
  return Random().nextInt(_idMax);
}

class SessionScopeIDGenerator {
  int id = 0;

  int next() {
    if (id == _maxScope) {
      id = 0;
    }

    return id += 1;
  }
}
