import "package:wampproto/src/messages/message.dart";
import "package:wampproto/src/messages/util.dart";
import "package:wampproto/src/messages/validation_spec.dart";

class Subscribe implements Message {
  Subscribe(this.requestID, this.topic, {Map<String, dynamic>? options}) : options = options ?? {};

  static const int id = 32;

  static const String text = "SUBSCRIBE";

  static final _validationSpec = ValidationSpec(
    minLength: 4,
    maxLength: 4,
    message: text,
    spec: {
      1: validateRequestID,
      2: validateOptions,
      3: validateTopic,
    },
  );

  final int requestID;
  final String topic;
  final Map<String, dynamic> options;

  static Subscribe parse(final List<dynamic> message) {
    var fields = validateMessage(message, id, text, _validationSpec);

    return Subscribe(fields.requestID!, fields.topic!, options: fields.options);
  }

  @override
  List<dynamic> marshal() {
    return [id, requestID, options, topic];
  }

  @override
  int messageType() => id;
}
