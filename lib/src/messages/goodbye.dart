import "package:wampproto/src/messages/message.dart";
import "package:wampproto/src/messages/util.dart";

class Goodbye implements Message {
  Goodbye(this.details, this.reason);

  static const int id = 6;

  static const String text = "GOODBYE";

  final Map<String, dynamic> details;
  final String reason;

  static Goodbye parse(final List<dynamic> message) {
    sanityCheck(message, 3, 3, id, text);

    Map<String, dynamic> details = validateMapOrRaise(message[1], text, "details");

    String reason = validateStringOrRaise(message[2], text, "reason");

    return Goodbye(details, reason);
  }

  @override
  List<dynamic> marshal() {
    return [id, details, reason];
  }

  @override
  int messageType() => id;
}
