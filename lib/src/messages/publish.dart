import "package:wampproto/src/messages/message.dart";
import "package:wampproto/src/messages/util.dart";

class Publish implements Message {
  Publish(
    this.requestID,
    this.uri, {
    List<dynamic>? args,
    Map<String, dynamic>? kwargs,
    Map<String, dynamic>? options,
  })  : args = args ?? [],
        kwargs = kwargs ?? {},
        options = options ?? {};

  static const int id = 16;

  static const String text = "PUBLISH";

  static const int minLength = 4;
  static const int maxLength = 6;

  final int requestID;
  final String uri;
  final List<dynamic> args;
  final Map<String, dynamic> kwargs;
  final Map<String, dynamic> options;

  static Publish parse(final List<dynamic> message) {
    sanityCheck(message, minLength, maxLength, id, text);

    int requestID = validateIntOrRaise(message[1], text, "request ID");

    Map<String, dynamic> options = validateMapOrRaise(message[2], text, "options");

    String uri = validateStringOrRaise(message[3], text, "uri");

    List<dynamic>? args;
    if (message.length > minLength) {
      args = validateListOrRaise(message[4], text, "args");
    }

    Map<String, dynamic>? kwargs;
    if (message.length == maxLength) {
      kwargs = validateMapOrRaise(message[5], text, "kwargs");
    }

    return Publish(requestID, uri, args: args, kwargs: kwargs, options: options);
  }

  @override
  List<dynamic> marshal() {
    List<dynamic> message = [id, requestID, options, uri];
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
