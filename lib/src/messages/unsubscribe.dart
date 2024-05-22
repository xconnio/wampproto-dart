import "package:wampproto/src/messages/message.dart";
import "package:wampproto/src/messages/util.dart";
import "package:wampproto/src/messages/validation_spec.dart";

class UnSubscribe implements Message {
  UnSubscribe(this.requestID, this.subscriptionID);

  static const int id = 34;

  static const String text = "UNSUBSCRIBE";

  static final _validationSpec = ValidationSpec(
    minLength: 3,
    maxLength: 3,
    message: text,
    spec: {
      1: validateRequestID,
      2: validateSubscriptionID,
    },
  );

  final int requestID;
  final int subscriptionID;

  static UnSubscribe parse(final List<dynamic> message) {
    var fields = validateMessage(message, id, text, _validationSpec);

    return UnSubscribe(fields.requestID!, fields.subscriptionID!);
  }

  @override
  List<dynamic> marshal() {
    return [id, requestID, subscriptionID];
  }

  @override
  int messageType() => id;
}
