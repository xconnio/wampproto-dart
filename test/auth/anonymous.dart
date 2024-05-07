import "package:test/test.dart";

import "package:wampproto/auth.dart";
import "package:wampproto/messages.dart";

void main() {
  group("AnonymousAuthenticator", () {
    const authID = "authID";
    final authExtra = {"extra": "data"};

    final authenticator = AnonymousAuthenticator(authID, authExtra);

    test("constructor", () {
      expect(authenticator, isNotNull);
      expect(authenticator.authID, authID);
      expect(authenticator.authExtra, authExtra);
      expect(authenticator.authMethod, "anonymous");
    });

    test("authenticate", () {
      final challenge = Challenge(authenticator.authMethod, {"challenge": "test"});
      expect(() => authenticator.authenticate(challenge), throwsA(isA<UnimplementedError>()));
    });
  });
}
