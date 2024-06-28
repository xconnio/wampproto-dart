import "dart:io";

import "package:pinenacl/ed25519.dart";
import "package:test/test.dart";

import "package:wampproto/src/auth/cryptosign.dart";

Future<String> runCommand(String command) async {
  ProcessResult result = await Process.run("wampproto", command.split(" "));
  expect(result.exitCode, 0, reason: result.stderr);

  return result.stdout;
}

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
}
