import "package:wampproto/src/messages/message.dart";
import "package:wampproto/src/messages/util.dart";

class Error implements Message {
  Error(
    this.msgType,
    this.requestID,
    this.uri, {
    List<dynamic>? args,
    Map<String, dynamic>? kwargs,
    Map<String, dynamic>? details,
  })  : args = args ?? [],
        kwargs = kwargs ?? {},
        details = details ?? {};

  static const int id = 8;

  static const String text = "ERROR";

  static const int minLength = 5;
  static const int maxLength = 7;

  final int msgType;
  final int requestID;
  final String uri;
  final List<dynamic> args;
  final Map<String, dynamic> kwargs;
  final Map<String, dynamic> details;

  static Error parse(final List<dynamic> message) {
    sanityCheck(message, minLength, maxLength, id, text);

    int msgType = validateIntOrRaise(message[1], text, "message type");

    int requestID = validateIntOrRaise(message[2], text, "request ID");

    Map<String, dynamic> details = validateMapOrRaise(message[3], text, "details");

    String uri = validateStringOrRaise(message[4], text, "uri");

    List<dynamic>? args;
    if (message.length > minLength) {
      args = validateListOrRaise(message[5], text, "args");
    }

    Map<String, dynamic>? kwargs;
    if (message.length == maxLength) {
      kwargs = validateMapOrRaise(message[6], text, "kwargs");
    }

    return Error(msgType, requestID, uri, args: args, kwargs: kwargs, details: details);
  }

  @override
  List<dynamic> marshal() {
    List<dynamic> message = [id, msgType, requestID, details, uri];
    if (args.isNotEmpty) {
      message.add(args);
    }

    if (kwargs.isNotEmpty) {
      if (args.isEmpty) {
        message.add([]);
      }
      message.add(kwargs);
    }

    return message;
  }

  @override
  int messageType() => id;
}
