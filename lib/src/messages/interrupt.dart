import "package:wampproto/src/messages/message.dart";
import "package:wampproto/src/messages/util.dart";
import "package:wampproto/src/messages/validation_spec.dart";

class Interrupt implements Message {
  Interrupt(this.invRequestID, this.options);

  static const int id = 69;

  static const String text = "INTERRUPT";

  static final _validationSpec = ValidationSpec(
    minLength: 3,
    maxLength: 3,
    message: text,
    spec: {
      1: validateRequestID,
      2: validateOptions,
    },
  );

  final int invRequestID;
  final Map<String, dynamic> options;

  static Interrupt parse(final List<dynamic> message) {
    var fields = validateMessage(message, id, text, _validationSpec);

    return Interrupt(fields.requestID!, fields.options!);
  }

  @override
  List<dynamic> marshal() {
    return [id, invRequestID, options];
  }

  @override
  int messageType() => id;
}
