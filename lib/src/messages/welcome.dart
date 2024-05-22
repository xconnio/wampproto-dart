import "package:wampproto/src/messages/message.dart";
import "package:wampproto/src/messages/util.dart";
import "package:wampproto/src/messages/validation_spec.dart";

class Welcome implements Message {
  Welcome(this.sessionID, this.roles, this.authID, this.authRole, this.authMethod, {Map<String, dynamic>? authExtra})
      : authExtra = authExtra ?? {};

  static const int id = 2;
  static const String text = "WELCOME";

  static final _validationSpec = ValidationSpec(
    minLength: 3,
    maxLength: 3,
    message: text,
    spec: {
      1: validateSessionID,
      2: validateDetails,
    },
  );

  final int sessionID;
  final Map<String, dynamic> roles;
  final String authID;
  final String authRole;
  final String authMethod;
  final Map<String, dynamic> authExtra;

  static Welcome parse(final List<dynamic> message) {
    var fields = validateMessage(message, id, text, _validationSpec);

    Map<String, dynamic> roles = validateRolesOrRaise(fields.details!["roles"], text);

    String authid = validateStringOrRaise(fields.details!["authid"], text, "authid");

    String authRole = validateStringOrRaise(fields.details!["authrole"], text, "authrole");

    String authMethod = validateStringOrRaise(fields.details!["authmethod"], text, "authmethod");

    Map<String, dynamic>? authExtra;
    if (fields.details!["authextra"] != null) {
      authExtra = validateMapOrRaise(fields.details!["authextra"], text, "authextra");
    }

    return Welcome(fields.sessionID!, roles, authid, authRole, authMethod, authExtra: authExtra);
  }

  @override
  List<dynamic> marshal() {
    Map<String, dynamic> details = {};
    details["roles"] = roles;
    details["authid"] = authID;
    details["authrole"] = authRole;
    details["authmethod"] = authMethod;
    details["authextra"] = authExtra;

    return [id, sessionID, details];
  }

  @override
  int messageType() => id;
}
