import "package:wampproto/messages.dart";
import "package:wampproto/src/auth/auth.dart";

class AnonymousAuthenticator extends IClientAuthenticator {
  AnonymousAuthenticator(String authID, [Map<String, dynamic>? authExtra]) : super(type, authID, authExtra);

  static const String type = "anonymous";
  @override
  Authenticate authenticate(Challenge challenge) {
    throw UnimplementedError();
  }
}
