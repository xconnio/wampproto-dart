import "package:wampproto/src/messages/message.dart";
import "package:wampproto/src/messages/util.dart";

class Authenticate implements Message {
  Authenticate(this.signature, this.extra);

  static const int id = 5;

  static const String text = "AUTHENTICATE";

  final String signature;
  final Map<String, dynamic> extra;

  static Authenticate parse(final List<dynamic> message) {
    sanityCheck(message, 3, 3, id, text);

    String signature = validateStringOrRaise(message[1], text, "signature");

    Map<String, dynamic> extra = validateMapOrRaise(message[2], text, "extra");

    return Authenticate(signature, extra);
  }

  @override
  List<dynamic> marshal() {
    return [id, signature, extra];
  }

  @override
  int messageType() => id;
}
