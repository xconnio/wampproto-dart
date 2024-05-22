import "package:wampproto/src/messages/message.dart";
import "package:wampproto/src/messages/util.dart";
import "package:wampproto/src/messages/validation_spec.dart";

class UnSubscribed implements Message {
  UnSubscribed(this.requestID);

  static const int id = 35;

  static const String text = "UNSUBSCRIBED";

  static final _validationSpec = ValidationSpec(
    minLength: 2,
    maxLength: 2,
    message: text,
    spec: {
      1: validateRequestID,
    },
  );

  final int requestID;

  static UnSubscribed parse(final List<dynamic> message) {
    var fields = validateMessage(message, id, text, _validationSpec);

    return UnSubscribed(fields.requestID!);
  }

  @override
  List<dynamic> marshal() {
    return [id, requestID];
  }

  @override
  int messageType() => id;
}
