import "package:wampproto/src/messages/message.dart";
import "package:wampproto/src/messages/util.dart";
import "package:wampproto/src/messages/validation_spec.dart";

abstract class IAuthenticateFields {
  String get signature;

  Map<String, dynamic> get extra;
}

class AuthenticateFields implements IAuthenticateFields {
  AuthenticateFields(this._signature, this._extra);

  final String _signature;

  final Map<String, dynamic> _extra;

  @override
  String get signature => _signature;

  @override
  Map<String, dynamic> get extra => _extra;
}

class Authenticate implements Message {
  Authenticate(String signature, Map<String, dynamic> extra) {
    _authenticateFields = AuthenticateFields(signature, extra);
  }

  Authenticate.withFields(this._authenticateFields);

  static const int id = 5;

  static const String text = "AUTHENTICATE";

  static final _validationSpec = ValidationSpec(
    minLength: 3,
    maxLength: 3,
    message: text,
    spec: {
      1: validateSignature,
      2: validateExtra,
    },
  );

  late IAuthenticateFields _authenticateFields;

  String get signature => _authenticateFields.signature;

  Map<String, dynamic> get extra => _authenticateFields.extra;

  static Authenticate parse(final List<dynamic> message) {
    var fields = validateMessage(message, id, text, _validationSpec);

    return Authenticate(fields.signature!, fields.extra!);
  }

  @override
  List<dynamic> marshal() {
    return [id, signature, extra];
  }

  @override
  int messageType() => id;
}
