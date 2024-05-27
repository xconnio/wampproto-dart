import "package:test/test.dart";

import "package:wampproto/auth.dart";
import "package:wampproto/src/messages/challenge.dart";

void main() {
  group("TicketAuthenticator", () {
    const ticket = "test";
    const authID = "authID";
    final authExtra = {"extra": "data"};
    final authenticator = TicketAuthenticator(ticket, authID, authExtra);

    test("constructor", () {
      expect(authenticator, isNotNull);
      expect(authenticator.authID, authID);
      expect(authenticator.authExtra, authExtra);
      expect(authenticator.authMethod, "ticket");
    });

    test("authenticate", () {
      final challenge = Challenge(ChallengeFields(authenticator.authMethod, {"challenge": "test"}));
      final authenticate = authenticator.authenticate(challenge);
      expect(authenticate.signature, isNotNull);
      expect(authenticate.signature, ticket);
    });
  });
}
