import "package:wampproto/messages.dart";
import "package:wampproto/src/auth/auth.dart";

class TicketAuthenticator extends IClientAuthenticator {
  TicketAuthenticator(String authID, Map<String, dynamic>? authExtra, this._ticket) : super(type, authID, authExtra);

  static const String type = "ticket";
  final String _ticket;

  @override
  Authenticate authenticate(Challenge challenge) {
    return Authenticate(_ticket, {});
  }
}
