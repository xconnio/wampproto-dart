import "package:wampproto/src/messages/message.dart";
import "package:wampproto/src/messages/util.dart";

class UnRegister implements Message {
  UnRegister(this.requestID, this.registrationID);

  static const int id = 66;

  static const String text = "UNREGISTER";

  static const int minLength = 3;
  static const int maxLength = 3;

  final int requestID;
  final int registrationID;

  static UnRegister parse(final List<dynamic> message) {
    sanityCheck(message, minLength, maxLength, id, text);

    int requestID = validateIntOrRaise(message[1], text, "request ID");

    int registrationID = validateIntOrRaise(message[2], text, "registration ID");

    return UnRegister(requestID, registrationID);
  }

  @override
  List<dynamic> marshal() {
    return [id, requestID, registrationID];
  }

  @override
  int messageType() => id;
}
