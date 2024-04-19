import "package:wampproto/src/messages/message.dart";
import "package:wampproto/src/messages/util.dart";

class UnSubscribed implements Message {
  UnSubscribed(this.requestID);

  static const int id = 35;

  static const String text = "UNSUBSCRIBED";

  final int requestID;

  static UnSubscribed parse(final List<dynamic> message) {
    sanityCheck(message, 2, 2, id, text);

    int requestID = validateIntOrRaise(message[1], text, "request ID");

    return UnSubscribed(requestID);
  }

  @override
  List<dynamic> marshal() {
    return [id, requestID];
  }

  @override
  int messageType() => id;
}
