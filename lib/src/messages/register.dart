import "package:wampproto/src/messages/message.dart";
import "package:wampproto/src/messages/util.dart";
import "package:wampproto/src/messages/validation_spec.dart";

abstract class IRegisterFields {
  int get requestID;

  String get uri;

  Map<String, dynamic> get options;
}

class RegisterFields implements IRegisterFields {
  RegisterFields(
    this._requestID,
    this._uri, {
    Map<String, dynamic>? options,
  }) : _options = options ?? {};

  final int _requestID;
  final String _uri;
  final Map<String, dynamic> _options;

  @override
  int get requestID => _requestID;

  @override
  String get uri => _uri;

  @override
  Map<String, dynamic> get options => _options;
}

class Register implements Message {
  Register(int requestID, String uri, {Map<String, dynamic>? options}) {
    _registerFields = RegisterFields(requestID, uri, options: options);
  }

  Register.withFields(this._registerFields);

  static const int id = 64;

  static const String text = "REGISTER";

  static final _validationSpec = ValidationSpec(
    minLength: 4,
    maxLength: 4,
    message: text,
    spec: {
      1: validateRequestID,
      2: validateOptions,
      3: validateURI,
    },
  );

  late IRegisterFields _registerFields;

  int get requestID => _registerFields.requestID;

  String get uri => _registerFields.uri;

  Map<String, dynamic> get options => _registerFields.options;

  static Register parse(final List<dynamic> message) {
    var fields = validateMessage(message, id, _validationSpec);

    return Register(fields.requestID!, fields.uri!, options: fields.options);
  }

  @override
  List<dynamic> marshal() {
    return [id, requestID, options, uri];
  }

  @override
  int messageType() => id;
}
