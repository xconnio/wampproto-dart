import "package:wampproto/src/messages/message.dart";
import "package:wampproto/src/messages/util.dart";

class Subscribed implements Message {
  Subscribed(this.requestID, this.subscriptionID);

  static const int id = 33;

  static const String text = "SUBSCRIBED";

  final int requestID;
  final int subscriptionID;

  static Subscribed parse(final List<dynamic> message) {
    sanityCheck(message, 3, 3, id, text);

    int requestID = validateIntOrRaise(message[1], text, "request ID");

    int subscriptionID = validateIntOrRaise(message[2], text, "subscription ID");

    return Subscribed(requestID, subscriptionID);
  }

  @override
  List<dynamic> marshal() {
    return [id, requestID, subscriptionID];
  }

  @override
  int messageType() => id;
}
