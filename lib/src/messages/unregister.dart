import "package:wampproto/src/messages/message.dart";
import "package:wampproto/src/messages/util.dart";
import "package:wampproto/src/messages/validation_spec.dart";

abstract class IUnRegisterFields {
  int get requestID;

  int get registrationID;
}

class UnRegisterFields implements IUnRegisterFields {
  UnRegisterFields(this._requestID, this._registrationID);

  final int _requestID;
  final int _registrationID;

  @override
  int get requestID => _requestID;

  @override
  int get registrationID => _registrationID;
}

class UnRegister implements Message {
  UnRegister(this._unRegisterFields);

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

  final UnRegisterFields _unRegisterFields;

  int get requestID => _unRegisterFields.requestID;

  int get registrationID => _unRegisterFields.registrationID;

  static UnRegister parse(final List<dynamic> message) {
    var fields = validateMessage(message, id, text, _validationSpec);

    return UnRegister(UnRegisterFields(fields.requestID!, fields.registrationID!));
  }

  @override
  List<dynamic> marshal() {
    return [id, requestID, registrationID];
  }

  @override
  int messageType() => id;
}
