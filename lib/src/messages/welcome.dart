import "package:wampproto/src/messages/message.dart";
import "package:wampproto/src/messages/util.dart";

class Welcome implements Message {
  Welcome(this.sessionID, this.roles, this.authID, this.authRole, this.authMethods, this.authExtra);

  static const int id = 2;
  static const String text = "WELCOME";

  final int sessionID;
  final Map<String, Map<String, bool>> roles;
  final String authID;
  final String authRole;
  final List<String> authMethods;
  final Map<String, dynamic> authExtra;

  static Welcome parse(final List<dynamic> message) {
    sanityCheck(message, 3, 3, id, text);

    int sessionID = validateSessionIdOrRaise(message[1], text);

    Map<String, dynamic> details = validateMapOrRaise(message[2], text, "details");

    Map<String, Map<String, bool>> roles = validateRolesOrRaise(details["roles"], text);

    String authid = validateStringOrRaise(details["authid"], text, "authid");

    String authRole = validateStringOrRaise(details["authrole"], text, "authrole");

    List<String> authMethods = validateListOrRaise(details["authmethods"], text, "authmethods");

    Map<String, dynamic> authExtra = validateMapOrRaise(details["authextra"], text, "authextra");

    return Welcome(sessionID, roles, authid, authRole, authMethods, authExtra);
  }

  @override
  List<dynamic> marshal() {
    Map<String, dynamic> details = {};
    details["roles"] = roles;
    details["authid"] = authID;
    details["authrole"] = authRole;
    details["authmethods"] = authMethods;
    details["authextra"] = authExtra;

    return [id, sessionID, details];
  }

  @override
  int messageType() => id;
}
