import "dart:convert";
import "dart:math";
import "dart:typed_data";

import "package:crypto/crypto.dart";
import "package:wampproto/messages.dart";
import "package:wampproto/src/auth/auth.dart";

class WAMPCRAAuthenticator extends IClientAuthenticator {
  WAMPCRAAuthenticator(String authID, Map<String, dynamic>? authExtra, this._secret) : super(type, authID, authExtra);

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

String generateWampCRAChallenge(int sessionID, String authID, String authRole, String provider) {
  final nonce = generateNonce();

  final data = {
    "nonce": nonce,
    "authprovider": provider,
    "authid": authID,
    "authrole": authRole,
    "authmethod": "wampcra",
    "session": sessionID,
    "timestamp": utcNow(),
  };

  return json.encode(data);
}

String signWampCRAChallenge(String challenge, Uint8List key) {
  final signature = Hmac(sha256, key).convert(utf8.encode(challenge));
  return base64.encode(signature.bytes);
}

bool verifyWampCRASignature(String signature, String challenge, Uint8List key) {
  final localSignature = signWampCRAChallenge(challenge, key);
  return signature == localSignature;
}
