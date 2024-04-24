import "package:wampproto/src/messages/message.dart";
import "package:wampproto/src/messages/util.dart";

class Subscribe implements Message {
  Subscribe(this.requestID, this.topic, {Map<String, dynamic>? options}) : options = options ?? {};

  static const int id = 32;

  static const String text = "SUBSCRIBE";

  final int requestID;
  final String topic;
  final Map<String, dynamic> options;

  static Subscribe parse(final List<dynamic> message) {
    sanityCheck(message, 4, 4, id, text);

    int requestID = validateIntOrRaise(message[1], text, "request ID");

    Map<String, dynamic> options = validateMapOrRaise(message[2], text, "options");

    String topic = validateStringOrRaise(message[3], text, "topic");

    return Subscribe(requestID, topic, options: options);
  }

  @override
  List<dynamic> marshal() {
    return [id, requestID, options, topic];
  }

  @override
  int messageType() => id;
}
