import "package:wampproto/src/messages/message.dart";
import "package:wampproto/src/messages/util.dart";

class Interrupt implements Message {
  Interrupt(this.invRequestID, this.options);

  static const int id = 69;

  static const String text = "INTERRUPT";

  final int invRequestID;
  final Map<String, dynamic> options;

  static Interrupt parse(final List<dynamic> message) {
    sanityCheck(message, 3, 3, id, text);

    int invRequestID = validateIntOrRaise(message[1], text, "invocation requestID");

    Map<String, dynamic> options = validateMapOrRaise(message[2], text, "options");

    return Interrupt(invRequestID, options);
  }

  @override
  List<dynamic> marshal() {
    return [id, invRequestID, options];
  }

  @override
  int messageType() => id;
}
