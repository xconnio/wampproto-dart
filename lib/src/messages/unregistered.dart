import "package:wampproto/src/messages/message.dart";
import "package:wampproto/src/messages/util.dart";

class UnRegistered implements Message {
  UnRegistered(this.requestID);

  static const int id = 67;

  static const String text = "UNREGISTERED";

  static const int minLength = 2;
  static const int maxLength = 2;

  final int requestID;

  static UnRegistered parse(final List<dynamic> message) {
    sanityCheck(message, minLength, maxLength, id, text);

    int requestID = validateIntOrRaise(message[1], text, "request ID");

    return UnRegistered(requestID);
  }

  @override
  List<dynamic> marshal() {
    return [id, requestID];
  }

  @override
  int messageType() => id;
}
