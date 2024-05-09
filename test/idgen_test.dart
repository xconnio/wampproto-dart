import "package:test/test.dart";

import "package:wampproto/src/idgen.dart";

void main() {
  test("GenerateSessionID", () {
    final id = generateSessionID();
    expect(id, greaterThan(0));
  });

  test("SessionScopeIDGenerator", () {
    final generator = SessionScopeIDGenerator();
    for (int i = 1; i < 10; i++) {
      final id = generator.next();
      expect(id, i);
    }
  });
}
