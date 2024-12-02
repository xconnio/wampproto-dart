import "package:pinenacl/ed25519.dart";
import "package:test/test.dart";

import "package:wampproto/auth.dart";
import "package:wampproto/messages.dart";
import "package:wampproto/src/auth/cryptosign.dart";
import "package:wampproto/src/auth/wampcra.dart";

import "helper.dart";

void main() {
  group("CryptoSignAuth", () {
    const testPublicKey = "2b7ec216daa877c7f4c9439db8a722ea2340eacad506988db2564e258284f895";
    const testPrivateKey = "022b089bed5ab78808365e82dd12c796c835aeb98b4a5a9e099d3e72cb719516";

    test("GenerateChallenge", () async {
      var challenge = generateCryptoSignChallenge();

      var signature = await runCommand(
        "auth cryptosign sign-challenge $challenge $testPrivateKey",
      );

      var isVerified = await runCommand(
        "auth cryptosign verify-signature ${signature.trim()} $testPublicKey",
      );
      expect(isVerified, "Signature verified successfully\n");
    });

    test("SignCryptoSignChallenge", () async {
      var challenge = await runCommand("auth cryptosign generate-challenge");

      var signature = signCryptoSignChallenge(
        challenge.trim(),
        SigningKey(seed: Base16Encoder.instance.decode(testPrivateKey)),
      );

      if (Base16Encoder.instance.decode(signature).length == 64) {
        signature = signature + challenge.trim();
      }

      var isVerified = await runCommand(
        "auth cryptosign verify-signature $signature $testPublicKey",
      );
      expect(isVerified, "Signature verified successfully\n");
    });

    test("VerifyCryptoSignSignature", () async {
      var challenge = await runCommand("auth cryptosign generate-challenge");

      var signature = await runCommand(
        "auth cryptosign sign-challenge ${challenge.trim()} $testPrivateKey",
      );

      var isVerified = verifyCryptoSignSignature(signature.trim(), Base16Encoder.instance.decode(testPublicKey));
      expect(isVerified, true);
    });
  });

  group("CRAAuth", () {
    const testSecret = "private";
    var testSecretBytes = Uint8List.fromList(testSecret.codeUnits);

    const String authID = "foo";
    const String salt = "salt";
    const int keyLength = 32;
    const int iterations = 1000;
    const String craChallenge =
        '''{"nonce":"cdcb3b12d56e12825be99f38f55ba43f","authprovider":"provider","authid":"foo","authrole":"anonymous","authmethod":"wampcra","session":1,"timestamp":"2024-05-07T09:25:13.307Z"}''';
    final Map<String, dynamic> authExtra = {
      "challenge": craChallenge,
      "salt": salt,
      "iterations": iterations,
      "keylen": keyLength,
    };

    test("GenerateCRAChallenge", () async {
      var challenge = generateWampCRAChallenge(1, "anonymous", "anonymous", "static");

      var signChallengeCommand = "auth cra sign-challenge $challenge $testSecret";
      var signature = await runCommand(signChallengeCommand);

      var verifySignatureCommand = "auth cra verify-signature $challenge ${signature.trim()} $testSecret";
      await runCommand(verifySignatureCommand);
    });

    test("SignCRAChallenge", () async {
      var signChallengeCommand = "auth cra generate-challenge 1 anonymous anonymous static";
      var challenge = await runCommand(signChallengeCommand);

      var signature = signWampCRAChallenge(challenge, testSecretBytes);

      var verifySignatureCommand = "auth cra verify-signature $challenge ${signature.trim()} $testSecret";
      await runCommand(verifySignatureCommand);
    });

    test("VerifyCRASignature", () async {
      var verifiedCRACommand = "auth cra generate-challenge 1 anonymous anonymous static";
      var challenge = await runCommand(verifiedCRACommand);

      var signChallengeCommand = "auth cra sign-challenge ${challenge.trim()} $testSecret";
      var signature = await runCommand(signChallengeCommand);

      var isVerified = verifyWampCRASignature(signature.trim(), challenge.trim(), testSecretBytes);
      expect(isVerified, true);
    });

    test("SignCRAChallengeWithSalt", () async {
      final challenge = Challenge(WAMPCRAAuthenticator.type, authExtra);
      final authenticator = WAMPCRAAuthenticator(authID, authExtra, testSecret);

      final authenticate = authenticator.authenticate(challenge);
      final saltSecret = await runCommand("auth cra derive-key $salt $testSecret -i $iterations -l $keyLength");

      await runCommand("auth cra verify-signature $craChallenge ${authenticate.signature} ${saltSecret.trim()}");
    });

    test("VerifyCRASignatureWithSalt", () async {
      final challenge = await runCommand("auth cra generate-challenge 1 $authID anonymous provider");
      final saltSecret = await runCommand("auth cra derive-key $salt $testSecret -i $iterations -l $keyLength");

      final signature = await runCommand("auth cra sign-challenge ${challenge.trim()} ${saltSecret.trim()}");

      final isVerified = verifyWampCRASignature(
        signature.trim(),
        challenge.trim(),
        Uint8List.fromList(saltSecret.trim().codeUnits),
      );
      expect(isVerified, true);
    });
  });
}
