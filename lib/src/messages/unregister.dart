import "package:wampproto/src/messages/message.dart";
import "package:wampproto/src/messages/util.dart";
import "package:wampproto/src/messages/validation_spec.dart";

abstract class IUnregisterFields {
  int get requestID;

  int get registrationID;
}

class UnregisterFields implements IUnregisterFields {
  UnregisterFields(this._requestID, this._registrationID);

  final int _requestID;
  final int _registrationID;

  @override
  int get requestID => _requestID;

  @override
  int get registrationID => _registrationID;
}

class Unregister implements Message {
  Unregister(int requestID, int registrationID) {
    _unregisterFields = UnregisterFields(requestID, registrationID);
  }

  Unregister.withFields(this._unregisterFields);

  static const int id = 66;

  static const String text = "UNREGISTER";

  static final _validationSpec = ValidationSpec(
    minLength: 3,
    maxLength: 3,
    message: text,
    spec: {
      1: validateRequestID,
      2: validateRegistrationID,
    },
  );

  late IUnregisterFields _unregisterFields;

  int get requestID => _unregisterFields.requestID;

  int get registrationID => _unregisterFields.registrationID;

  static Unregister parse(final List<dynamic> message) {
    var fields = validateMessage(message, id, _validationSpec);

    return Unregister(fields.requestID!, fields.registrationID!);
  }

  @override
  List<dynamic> marshal() {
    return [id, requestID, registrationID];
  }

  @override
  int messageType() => id;
}
