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

    return Welcome(
      fields.sessionID!,
      fields.details!["roles"],
      fields.details!["authid"],
      fields.details!["authrole"],
      fields.details!["authmethod"],
      authExtra: fields.details!["authextra"],
    );
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
