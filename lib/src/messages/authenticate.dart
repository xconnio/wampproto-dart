import "package:wampproto/src/messages/message.dart";
import "package:wampproto/src/messages/util.dart";
import "package:wampproto/src/messages/validation_spec.dart";

class Authenticate implements Message {
  Authenticate(this.signature, this.extra);

  static const int id = 5;

  static const String text = "AUTHENTICATE";

  static final _validationSpec = ValidationSpec(
    minLength: 3,
    maxLength: 3,
    message: text,
    spec: {
      1: validateSignature,
      2: validateExtra,
    },
  );

  final String signature;
  final Map<String, dynamic> extra;

  static Authenticate parse(final List<dynamic> message) {
    var fields = validateMessage(message, id, text, _validationSpec);

    return Authenticate(fields.signature!, fields.extra!);
  }

  @override
  List<dynamic> marshal() {
    return [id, signature, extra];
  }

  @override
  int messageType() => id;
}
