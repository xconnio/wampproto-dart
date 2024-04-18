import "package:wampproto/src/messages/message.dart";
import "package:wampproto/src/messages/util.dart";

class Register implements Message {
  Register(this.requestID, this.uri, {Map<String, dynamic>? options}) : options = options ?? {};

  static const int id = 64;

  static const String text = "REGISTER";

  final int requestID;
  final int uri;
  final Map<String, dynamic> options;

  static Register parse(final List<dynamic> message) {
    sanityCheck(message, 4, 4, id, text);

    int requestID = validateIntOrRaise(message[1], text, "request ID");

    Map<String, dynamic> options = validateMapOrRaise(message[2], text, "options");

    int uri = validateIntOrRaise(message[3], text, "uri");

    return Register(requestID, uri, options: options);
  }

  @override
  List<dynamic> marshal() {
    return [id, requestID, options, uri];
  }

  @override
  int messageType() => id;
}
