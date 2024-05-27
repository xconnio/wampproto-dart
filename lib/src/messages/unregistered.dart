import "package:wampproto/src/messages/message.dart";
import "package:wampproto/src/messages/util.dart";
import "package:wampproto/src/messages/validation_spec.dart";

abstract class IUnRegisteredFields {
  int get requestID;
}

class UnRegisteredFields implements IUnRegisteredFields {
  UnRegisteredFields(this._requestID);

  final int _requestID;

  @override
  int get requestID => _requestID;
}

class UnRegistered implements Message {
  UnRegistered(this._unRegisteredFields);

  static const int id = 67;

  static const String text = "UNREGISTERED";

  static final _validationSpec = ValidationSpec(
    minLength: 2,
    maxLength: 2,
    message: text,
    spec: {
      1: validateRequestID,
    },
  );

  final UnRegisteredFields _unRegisteredFields;

  int get requestID => _unRegisteredFields.requestID;

  static UnRegistered parse(final List<dynamic> message) {
    var fields = validateMessage(message, id, text, _validationSpec);

    return UnRegistered(UnRegisteredFields(fields.requestID!));
  }

  @override
  List<dynamic> marshal() {
    return [id, requestID];
  }

  @override
  int messageType() => id;
}
