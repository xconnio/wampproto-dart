import "package:wampproto/src/messages/message.dart";
import "package:wampproto/src/messages/util.dart";
import "package:wampproto/src/messages/validation_spec.dart";

class UnRegister implements Message {
  UnRegister(this.requestID, this.registrationID);

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

  final int requestID;
  final int registrationID;

  static UnRegister parse(final List<dynamic> message) {
    var fields = validateMessage(message, id, text, _validationSpec);

    return UnRegister(fields.requestID!, fields.registrationID!);
  }

  @override
  List<dynamic> marshal() {
    return [id, requestID, registrationID];
  }

  @override
  int messageType() => id;
}
