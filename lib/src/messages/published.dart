import "package:wampproto/src/messages/message.dart";
import "package:wampproto/src/messages/util.dart";

class Published implements Message {
  Published(this.requestID, this.publicationID);

  static const int id = 17;

  static const String text = "PUBLISHED";

  static const int minLength = 3;
  static const int maxLength = 3;

  final int requestID;
  final int publicationID;

  static Published parse(final List<dynamic> message) {
    sanityCheck(message, minLength, maxLength, id, text);

    int requestID = validateIntOrRaise(message[1], text, "request ID");

    int publicationID = validateIntOrRaise(message[2], text, "publication ID");

    return Published(requestID, publicationID);
  }

  @override
  List<dynamic> marshal() {
    return [id, requestID, publicationID];
  }

  @override
  int messageType() => id;
}
