import "package:wampproto/src/messages/message.dart";
import "package:wampproto/src/messages/util.dart";
import "package:wampproto/src/messages/validation_spec.dart";

abstract class IWelcomeFields {
  int get sessionID;

  Map<String, dynamic> get roles;

  String get authID;

  String get authRole;

  String get authMethod;

  Map<String, dynamic> get authExtra;
}

class WelcomeFields implements IWelcomeFields {
  WelcomeFields(
    this._sessionID,
    this._roles,
    this._authid,
    this._authRole,
    this._authmethod, {
    Map<String, dynamic>? authExtra,
  }) : _authextra = authExtra ?? {};
  final int _sessionID;
  final Map<String, dynamic> _roles;
  final String _authid;
  final String _authRole;
  final String _authmethod;
  final Map<String, dynamic> _authextra;

  @override
  int get sessionID => _sessionID;

  @override
  Map<String, dynamic> get roles => _roles;

  @override
  String get authID => _authid;

  @override
  String get authRole => _authRole;

  @override
  String get authMethod => _authmethod;

  @override
  Map<String, dynamic> get authExtra => _authextra;
}

class Welcome implements Message {
  Welcome(
    int sessionID,
    Map<String, dynamic> roles,
    String authid,
    String authRole,
    String authMethod, {
    Map<String, dynamic>? authExtra,
  }) {
    _welcomeFields = WelcomeFields(sessionID, roles, authid, authRole, authMethod, authExtra: authExtra);
  }

  Welcome.withFields(this._welcomeFields);

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

  late IWelcomeFields _welcomeFields;

  int get sessionID => _welcomeFields.sessionID;

  Map<String, dynamic> get roles => _welcomeFields.roles;

  String get authID => _welcomeFields.authID;

  String get authRole => _welcomeFields.authRole;

  String get authMethod => _welcomeFields.authMethod;

  Map<String, dynamic> get authExtra => _welcomeFields.authExtra;

  static Welcome parse(final List<dynamic> message) {
    var fields = validateMessage(message, id, _validationSpec);

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
