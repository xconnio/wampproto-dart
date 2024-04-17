import "dart:convert";
import "dart:math";
import "dart:typed_data";

import "package:crypto/crypto.dart";
import "package:wampproto/messages.dart";
import "package:wampproto/src/auth/auth.dart";

class WAMPCRAAuthenticator extends IClientAuthenticator {
  WAMPCRAAuthenticator(this._secret, String authID, Map<String, dynamic> authExtra) : super(type, authID, authExtra);

  static const String type = "wampcra";
  final String _secret;

  @override
  Authenticate authenticate(Challenge challenge) {
    String signed = signWampCRAChallenge(challenge.extra["challenge"], utf8.encode(_secret));
    return Authenticate(signed, {});
  }
}

String generateNonce() {
  final random = Random.secure();
  final nonceBytes = Uint8List.fromList(List.generate(16, (_) => random.nextInt(256)));
  return nonceBytes.map((byte) => byte.toRadixString(16).padLeft(2, "0")).join();
}

String utcNow() {
  DateTime dt = DateTime.now().toUtc();
  return "${dt.toIso8601String().substring(0, 23)}Z";
}

String generateWampcraChallenge(int sessionId, String authId, String authRole, String provider) {
  final nonce = generateNonce();

  final data = {
    "nonce": nonce,
    "authprovider": provider,
    "authid": authId,
    "authrole": authRole,
    "authmethod": "wampcra",
    "session": sessionId,
    "timestamp": utcNow,
  };

  return json.encode(data);
}

String signWampCRAChallenge(String challenge, Uint8List key) {
  return Hmac(sha256, key).convert(utf8.encode(challenge)).toString();
}

bool verifyWampCRASignature(String signature, String challenge, Uint8List key) {
  final localSignature = signWampCRAChallenge(challenge, key);
  return signature == localSignature;
}
