import "package:wampproto/src/messages/message.dart";
import "package:wampproto/src/messages/util.dart";
import "package:wampproto/src/messages/validation_spec.dart";

class UnRegistered implements Message {
  UnRegistered(this.requestID);

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
  final int requestID;

  static UnRegistered parse(final List<dynamic> message) {
    var fields = validateMessage(message, id, text, _validationSpec);

    return UnRegistered(fields.requestID!);
  }

  @override
  List<dynamic> marshal() {
    return [id, requestID];
  }

  @override
  int messageType() => id;
}
