import "dart:convert";
import "dart:math";
import "dart:typed_data";

import "package:crypto/crypto.dart";
import "package:pointycastle/pointycastle.dart";
import "package:wampproto/messages.dart";
import "package:wampproto/src/auth/auth.dart";

class WAMPCRAAuthenticator extends IClientAuthenticator {
  WAMPCRAAuthenticator(String authID, Map<String, dynamic>? authExtra, this._secret) : super(type, authID, authExtra);

  static const String type = "wampcra";
  final String _secret;

  @override
  Authenticate authenticate(Challenge challenge) {
    Uint8List? rawSecret;
    String? saltStr = challenge.extra["salt"] as String?;
    if (saltStr != null && saltStr.isNotEmpty) {
      int iters = challenge.extra["iterations"] as int? ?? 0;
      int keylen = challenge.extra["keylen"] as int? ?? 32;

      rawSecret = deriveCRAKey(saltStr, _secret, iters, keylen);
    } else {
      rawSecret = Uint8List.fromList(utf8.encode(_secret));
    }

    String signed = signWampCRAChallenge(challenge.extra["challenge"], rawSecret);
    return Authenticate(signed, {});
  }
}

Uint8List deriveCRAKey(String saltStr, String secret, int iterations, int keyLength) {
  final salt = utf8.encode(saltStr);
  final secretBytes = utf8.encode(secret);

  final iter = iterations > 0 ? iterations : 1000;
  final keyLen = keyLength > 0 ? keyLength : 32;

  final params = Pbkdf2Parameters(Uint8List.fromList(salt), iter, keyLen);
  final pbkdf2 = KeyDerivator("SHA-256/HMAC/PBKDF2")..init(params);
  final derivedKey = pbkdf2.process(Uint8List.fromList(secretBytes));

  return Uint8List.fromList(base64.encode(derivedKey).codeUnits);
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
