import "dart:convert";

import "package:test/test.dart";

import "package:wampproto/messages.dart";
import "package:wampproto/src/auth/wampcra.dart";

void main() {
  const craChallenge = '{"nonce":"cdcb3b12d56e12825be99f38f55ba43f","authprovider":"provider","authid":"foo",'
      '"authrole":"admin","authmethod":"wampcra","session":123,"timestamp":"2024-05-07T09:25:13.307Z"}';
  const key = "6d9b906ad60d1f4dd796dbadcc2e2252310565ccdc6fe10b289df5684faf2a46";
  const validSignature = "0c854bddb2acfc48bdd5e4326339f352a12c893997ef4e413445ee89c3698bc0";

  group("WAMPCRAAuthenticator", () {
    test("authenticate", () {
      final authenticator = WAMPCRAAuthenticator(key, "authID", {});
      final challenge = Challenge("wampcra", {"challenge": craChallenge});

      final authenticate = authenticator.authenticate(challenge);
      expect(authenticate.signature, validSignature);
    });
  });

  group("WAMPCRAAuthenticator helper Functions", () {
    test("generateNonce", () {
      final nonce = generateNonce();
      expect(nonce, isNotNull);
      expect(nonce.length, 32);
    });

    test("utcNow", () {
      final dateTimeString = utcNow();
      final dateTime = DateTime.parse(dateTimeString);
      expect(dateTime, isNotNull);
      expect(dateTime.isUtc, isTrue);
    });

    test("generateWampCRAChallenge", () {
      final challenge = generateWampCRAChallenge(123, "foo", "admin", "provider");
      expect(challenge, isNotNull);
      expect(challenge.isNotEmpty, isTrue);
    });

    test("signWampCRAChallenge", () {
      final signature = signWampCRAChallenge(craChallenge, utf8.encode(key));
      expect(signature, isNotNull);
      expect(signature, validSignature);
    });

    test("verifyWampCRASignature", () {
      final isValid = verifyWampCRASignature(validSignature, craChallenge, utf8.encode(key));
      expect(isValid, isTrue);
    });

    test("verifyWampCRASignature", () {
      const signature = "invalid_signature";
      final isValid = verifyWampCRASignature(signature, craChallenge, utf8.encode(key));
      expect(isValid, isFalse);
    });
  });
}
