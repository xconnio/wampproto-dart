import "dart:math";

import "package:pinenacl/ed25519.dart";
import "package:wampproto/messages.dart";
import "package:wampproto/src/auth/auth.dart";

const hex = Base16Encoder.instance;

class CryptoSignAuthenticator extends IClientAuthenticator {
  CryptoSignAuthenticator(String authID, Map<String, dynamic>? authExtra, this._privateKeyHex) : super(type, authID) {
    authExtra ??= {};
    if (!authExtra.containsKey("pubkey")) {
      final pubKey = hex.encode(getPrivateKey().verifyKey);
      authExtra["pubkey"] = pubKey;
    }
    super.authExtra = authExtra;
  }

  static const String type = "cryptosign";
  final String _privateKeyHex;

  SigningKey getPrivateKey() {
    return SigningKey(seed: hex.decode(_privateKeyHex));
  }

  @override
  Authenticate authenticate(Challenge challenge) {
    if (!challenge.extra.containsKey("challenge")) {
      throw ArgumentError("challenge string missing in extra");
    }
    var challengeHex = challenge.extra["challenge"];
    var signed = signCryptoSignChallenge(challengeHex, getPrivateKey());

    return Authenticate(signed + challengeHex, {});
  }
}

String generateCryptoSignChallenge() {
  List<int> rawBytes = List<int>.generate(32, (index) => Random().nextInt(256));
  return hex.encode(rawBytes);
}

String signCryptoSignChallenge(String challenge, SigningKey privateKey) {
  final rawChallenge = hex.decode(challenge);
  final signature = privateKey.sign(rawChallenge);
  return hex.encode(signature.signature);
}

bool verifyCryptoSignSignature(String signature, Uint8List publicKey) {
  final verifyKey = VerifyKey(publicKey);
  SignedMessage signedMessage = SignedMessage.fromList(signedMessage: hex.decode(signature));
  return verifyKey.verifySignedMessage(signedMessage: signedMessage);
}
