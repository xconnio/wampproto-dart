import "dart:math";
import "package:pinenacl/ed25519.dart";

const hex = Base16Encoder.instance;

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
