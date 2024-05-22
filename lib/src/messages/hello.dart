import "package:wampproto/src/messages/message.dart";
import "package:wampproto/src/messages/util.dart";
import "package:wampproto/src/messages/validation_spec.dart";

class Hello implements Message {
  Hello(this.realm, this.roles, this.authID, this.authMethods, {Map<String, dynamic>? authExtra})
      : authExtra = authExtra ?? {};

  static const int id = 1;
  static const String text = "HELLO";

  static final _validationSpec = ValidationSpec(
    minLength: 3,
    maxLength: 3,
    message: text,
    spec: {
      1: validateRealm,
      2: validateDetails,
    },
  );

  final String realm;
  final Map<String, dynamic> roles;
  final String authID;
  final List<dynamic> authMethods;
  final Map<String, dynamic> authExtra;

  static Hello parse(final List<dynamic> message) {
    var fields = validateMessage(message, id, text, _validationSpec);

    Map<String, dynamic> roles = validateRolesOrRaise(fields.details!["roles"], text);

    String authid = "";
    if (fields.details!["authid"] != null) {
      authid = validateStringOrRaise(fields.details!["authid"], text, "authid");
    }

    List<dynamic> authMethods = [];
    if (fields.details!["authmethods"] != null) {
      authMethods = validateListOrRaise(fields.details!["authmethods"], text, "authmethods");
    }

    Map<String, dynamic>? authExtra;
    if (fields.details!["authextra"] != null) {
      authExtra = validateMapOrRaise(fields.details!["authextra"], text, "authextra");
    }

    return Hello(fields.realm!, roles, authid, authMethods, authExtra: authExtra);
  }

  @override
  List<dynamic> marshal() {
    Map<String, dynamic> details = {};
    details["roles"] = roles;
    details["authid"] = authID;
    details["authmethods"] = authMethods;
    details["authextra"] = authExtra;

    return [id, realm, details];
  }

  @override
  int messageType() => id;
}
