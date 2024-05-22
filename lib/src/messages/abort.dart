import "package:wampproto/src/messages/message.dart";
import "package:wampproto/src/messages/util.dart";
import "package:wampproto/src/messages/validation_spec.dart";

class Abort implements Message {
  Abort(this.details, this.reason);

  static const int id = 3;

  static const String text = "ABORT";

  static final _validationSpec = ValidationSpec(
    minLength: 3,
    maxLength: 3,
    message: text,
    spec: {
      1: validateDetails,
      2: validateReason,
    },
  );

  final Map<String, dynamic> details;
  final String reason;

  static Abort parse(final List<dynamic> message) {
    var fields = validateMessage(message, id, text, _validationSpec);

    return Abort(fields.details!, fields.reason!);
  }

  @override
  List<dynamic> marshal() {
    return [id, details, reason];
  }

  @override
  int messageType() => id;
}
