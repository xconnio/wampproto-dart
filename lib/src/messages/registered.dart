import "package:wampproto/src/messages/message.dart";
import "package:wampproto/src/messages/util.dart";
import "package:wampproto/src/messages/validation_spec.dart";

abstract class IRegisteredFields {
  int get requestID;

  int get registrationID;
}

class RegisteredFields implements IRegisteredFields {
  RegisteredFields(this._requestID, this._registrationID);

  final int _requestID;
  final int _registrationID;

  @override
  int get requestID => _requestID;

  @override
  int get registrationID => _registrationID;
}

class Registered implements Message {
  Registered(int requestID, int registrationID) {
    _registeredFields = RegisteredFields(requestID, registrationID);
  }

  Registered.withFields(this._registeredFields);

  static const int id = 65;

  static const String text = "REGISTERED";

  static final _validationSpec = ValidationSpec(
    minLength: 3,
    maxLength: 3,
    message: text,
    spec: {
      1: validateRequestID,
      2: validateRegistrationID,
    },
  );

  late IRegisteredFields _registeredFields;

  int get requestID => _registeredFields.requestID;

  int get registrationID => _registeredFields.registrationID;

  static Registered parse(final List<dynamic> message) {
    var fields = validateMessage(message, id, text, _validationSpec);

    return Registered(fields.requestID!, fields.registrationID!);
  }

  @override
  List<dynamic> marshal() {
    return [id, requestID, registrationID];
  }

  @override
  int messageType() => id;
}
