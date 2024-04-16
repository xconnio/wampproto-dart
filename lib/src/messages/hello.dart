import "package:wampproto/src/messages/message.dart";
import "package:wampproto/src/messages/util.dart";

class Hello implements Message {
  Hello(this.realm, this.roles, this.authID, this.authRole, this.authMethods, this.authExtra);

  static const int id = 1;
  static const String text = "HELLO";

  final String realm;
  final Map<String, Map<String, bool>> roles;
  final String authID;
  final String authRole;
  final List<String> authMethods;
  final Map<String, dynamic> authExtra;

  static Hello parse(final List<dynamic> message) {
    sanityCheck(message, 3, 3, id, text);

    String realm = validateStringOrRaise(message[1], text, "realm1");

    Map<String, dynamic> details = validateMapOrRaise(message[2], text, "details");

    Map<String, Map<String, bool>> roles = validateRolesOrRaise(details["roles"], text);

    String authid = validateStringOrRaise(details["authid"], text, "authid");

    String authRole = validateStringOrRaise(details["authrole"], text, "authrole");

    List<String> authMethods = validateListOrRaise(details["authmethods"], text, "authmethods");

    Map<String, dynamic> authExtra = validateMapOrRaise(details["authextra"], text, "authextra");

    return Hello(realm, roles, authid, authRole, authMethods, authExtra);
  }

  @override
  List<dynamic> marshal() {
    Map<String, dynamic> details = {};
    details["roles"] = roles;
    details["authid"] = authID;
    details["authrole"] = authRole;
    details["authmethods"] = authMethods;
    details["authextra"] = authExtra;

    return [id, realm, details];
  }

  @override
  int messageType() => id;
}
