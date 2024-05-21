import "package:wampproto/src/messages/message.dart";
import "package:wampproto/src/messages/util.dart";
import "package:wampproto/src/messages/validation_spec.dart";

class Register implements Message {
  Register(this.requestID, this.uri, {Map<String, dynamic>? options}) : options = options ?? {};

  static const int id = 64;

  static const String text = "REGISTER";

  static final _validationSpec = ValidationSpec(
    minLength: 4,
    maxLength: 4,
    message: text,
    spec: {
      1: validateRequestID,
      2: validateOptions,
      3: validateURI,
    },
  );

  final int requestID;
  final String uri;
  final Map<String, dynamic> options;

  static Register parse(final List<dynamic> message) {
    var fields = validateMessage(message, id, text, _validationSpec);

    return Register(fields.requestID!, fields.uri!, options: fields.options);
  }

  @override
  List<dynamic> marshal() {
    return [id, requestID, options, uri];
  }

  @override
  int messageType() => id;
}
