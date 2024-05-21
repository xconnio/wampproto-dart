import "package:wampproto/src/messages/message.dart";
import "package:wampproto/src/messages/util.dart";
import "package:wampproto/src/messages/validation_spec.dart";

class Challenge implements Message {
  Challenge(this.authMethod, this.extra);

  static const int id = 4;

  static const String text = "CHALLENGE";

  static final _validationSpec = ValidationSpec(
    minLength: 3,
    maxLength: 3,
    message: text,
    spec: {
      1: validateAuthMethod,
      2: validateExtra,
    },
  );

  final String authMethod;
  final Map<String, dynamic> extra;

  static Challenge parse(final List<dynamic> message) {
    var fields = validateMessage(message, id, text, _validationSpec);

    return Challenge(fields.authmethod!, fields.extra!);
  }

  @override
  List<dynamic> marshal() {
    return [id, authMethod, extra];
  }

  @override
  int messageType() => id;
}
