import "package:pinenacl/ed25519.dart";
import "package:test/test.dart";

import "package:wampproto/messages.dart";
import "package:wampproto/src/auth/cryptosign.dart";

void main() {
  const privateKeyHex = "c7e8c1f8f16ec37f53ed153f8afb7f18469b051f1d24dbea2097a2a104b2e9db";
  const publicKeyHex = "c53e4f2756a52ca1ed5cd00da108b3ed7bcffe6294e78283521e5102824f52d3";

  const challenge = "a1d483092ec08960fedbaed2bc1d411568a59077b794210e251bd3abb1563f7c";
  const signature = "01d4b7a515b1023196e2bbb57c5202da72088f99a17eaeed62ba97ebf93381b92a3e8430154667e194d971fb41b090"
      "a9338b92021c39271e910a8ea072fe950c";

  group("CryptoSignAuthenticator", () {
    CryptoSignAuthenticator authenticator = CryptoSignAuthenticator("authID", privateKeyHex);

    test("constructor", () {
      expect(authenticator.authID, "authID");
      expect(authenticator.authExtra!["pubkey"], hex.decode(publicKeyHex));
    });

    test("authenticate", () {
      final authenticate = authenticator.authenticate(Challenge("cryptosign", {"challenge": challenge}));
      expect(authenticate.signature, signature + challenge);
    });
  });

  group("CryptoSignAuthenticator helper functions", () {
    test("generateCryptoSignChallenge", () {
      String challenge = generateCryptoSignChallenge();
      expect(challenge, isNotEmpty);
      expect(challenge.length, 64);
    });

    test("signCryptoSignChallenge", () {
      var signed = signCryptoSignChallenge(challenge, SigningKey(seed: hex.decode(privateKeyHex)));
      expect(signed, isNotEmpty);
      expect(signed, signature);
    });

    test("verifyCryptoSignSignature", () {
      final publicKey = Base16Encoder.instance.decode(publicKeyHex);
      final isValid = verifyCryptoSignSignature(signature + challenge, publicKey);
      expect(isValid, isTrue);
    });
  });
}
