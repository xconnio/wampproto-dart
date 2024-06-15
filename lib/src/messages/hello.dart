import "package:wampproto/messages.dart";
import "package:wampproto/src/messages/message.dart";
import "package:wampproto/src/messages/util.dart";
import "package:wampproto/src/messages/validation_spec.dart";

abstract class IHelloFields {
  String get realm;

  Map<String, dynamic> get roles;

  String get authID;

  List<dynamic> get authMethods;

  Map<String, dynamic> get authExtra;
}

class HelloFields implements IHelloFields {
  HelloFields(this._realm, this._roles, this._authid, this._authmethods, {Map<String, dynamic>? authExtra})
      : _authextra = authExtra ?? {};
  final String _realm;
  final Map<String, dynamic> _roles;
  final String _authid;
  final List<dynamic> _authmethods;
  final Map<String, dynamic> _authextra;

  @override
  String get realm => _realm;

  @override
  Map<String, dynamic> get roles => _roles;

  @override
  String get authID => _authid;

  @override
  List<dynamic> get authMethods => _authmethods;

  @override
  Map<String, dynamic> get authExtra => _authextra;
}

class Hello implements Message {
  Hello(
    String realm,
    Map<String, dynamic> roles,
    String authid,
    List<dynamic> authMethods, {
    Map<String, dynamic>? authExtra,
  }) {
    _helloFields = HelloFields(realm, roles, authid, authMethods, authExtra: authExtra);
  }

  Hello.withFields(this._helloFields);

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

  late IHelloFields _helloFields;

  String get realm => _helloFields.realm;

  Map<String, dynamic> get roles => _helloFields.roles;

  String get authID => _helloFields.authID;

  List<dynamic> get authMethods => _helloFields.authMethods;

  Map<String, dynamic> get authExtra => _helloFields.authExtra;

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
