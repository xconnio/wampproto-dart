import "package:wampproto/src/messages/message.dart";
import "package:wampproto/src/messages/util.dart";
import "package:wampproto/src/messages/validation_spec.dart";

class Cancel implements Message {
  Cancel(this.callRequestID, this.options);

  static const int id = 49;

  static const String text = "CANCEL";

  static final _validationSpec = ValidationSpec(
    minLength: 3,
    maxLength: 3,
    message: text,
    spec: {
      1: validateRequestID,
      2: validateOptions,
    },
  );

  final int callRequestID;
  final Map<String, dynamic> options;

  static Cancel parse(final List<dynamic> message) {
    var fields = validateMessage(message, id, text, _validationSpec);

    return Cancel(fields.requestID!, fields.options!);
  }

  @override
  List<dynamic> marshal() {
    return [id, callRequestID, options];
  }

  @override
  int messageType() => id;
}
