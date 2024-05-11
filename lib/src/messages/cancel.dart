import "package:wampproto/src/messages/message.dart";
import "package:wampproto/src/messages/util.dart";

class Cancel implements Message {
  Cancel(this.callRequestID, this.options);

  static const int id = 49;

  static const String text = "CANCEL";

  final int callRequestID;
  final Map<String, dynamic> options;

  static Cancel parse(final List<dynamic> message) {
    sanityCheck(message, 3, 3, id, text);

    int callRequestID = validateIntOrRaise(message[1], text, "call requestID");

    Map<String, dynamic> options = validateMapOrRaise(message[2], text, "options");

    return Cancel(callRequestID, options);
  }

  @override
  List<dynamic> marshal() {
    return [id, callRequestID, options];
  }

  @override
  int messageType() => id;
}
