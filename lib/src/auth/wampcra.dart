import "dart:convert";
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

String signWampCRAChallenge(String challenge, Uint8List key) {
  return Hmac(sha256, key).convert(utf8.encode(challenge)).toString();
}
