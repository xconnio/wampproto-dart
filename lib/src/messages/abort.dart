import "package:wampproto/src/messages/message.dart";
import "package:wampproto/src/messages/util.dart";

class Abort implements Message {
  Abort(this.details, this.reason);

  static const int id = 3;

  static const String text = "ABORT";

  static const int minLength = 3;
  static const int maxLength = 3;

  final Map<String, dynamic> details;
  final String reason;

  static Abort parse(final List<dynamic> message) {
    sanityCheck(message, minLength, maxLength, id, text);

    Map<String, dynamic> details = validateMapOrRaise(message[1], text, "details");

    String reason = validateStringOrRaise(message[2], text, "reason");

    return Abort(details, reason);
  }

  @override
  List<dynamic> marshal() {
    return [id, details, reason];
  }

  @override
  int messageType() => id;
}
