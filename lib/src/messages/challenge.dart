import "package:wampproto/src/messages/message.dart";
import "package:wampproto/src/messages/util.dart";

class Challenge implements Message {
  Challenge(this.authMethod, this.extra);

  static const int id = 4;

  static const String text = "CHALLENGE";

  final String authMethod;
  final Map<String, dynamic> extra;

  static Challenge parse(final List<dynamic> message) {
    sanityCheck(message, 3, 3, id, text);

    String authMethod = validateStringOrRaise(message[1], text, "authmethod");

    Map<String, dynamic> extra = validateMapOrRaise(message[2], text, "extra");

    return Challenge(authMethod, extra);
  }

  @override
  List<dynamic> marshal() {
    return [id, authMethod, extra];
  }

  @override
  int messageType() => id;
}
