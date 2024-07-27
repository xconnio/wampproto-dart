import "package:wampproto/src/messages/message.dart";
import "package:wampproto/src/messages/util.dart";
import "package:wampproto/src/messages/validation_spec.dart";

abstract class IUnregisteredFields {
  int get requestID;
}

class UnregisteredFields implements IUnregisteredFields {
  UnregisteredFields(this._requestID);

  final int _requestID;

  @override
  int get requestID => _requestID;
}

class Unregistered implements Message {
  Unregistered(int requestID) {
    _unregisteredFields = UnregisteredFields(requestID);
  }

  Unregistered.withFields(this._unregisteredFields);

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

  late IUnregisteredFields _unregisteredFields;

  int get requestID => _unregisteredFields.requestID;

  static Unregistered parse(final List<dynamic> message) {
    var fields = validateMessage(message, id, _validationSpec);

    return Unregistered(fields.requestID!);
  }

  @override
  List<dynamic> marshal() {
    return [id, requestID];
  }

  @override
  int messageType() => id;
}
