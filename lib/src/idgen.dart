import "dart:math";

int idMax = 1 << 32;

int generateSessionID() {
  return Random().nextInt(idMax);
}

class SessionScopeIDGenerator {
  int id = 0;

  int next() {
    if (id == idMax) {
      id = 0;
    }

    return id += 1;
  }
}
