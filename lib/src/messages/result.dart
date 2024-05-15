import "package:wampproto/src/messages/message.dart";
import "package:wampproto/src/messages/util.dart";

class Result implements Message {
  Result(
    this.requestID, {
    List<dynamic>? args,
    Map<String, dynamic>? kwargs,
    Map<String, dynamic>? details,
  })  : args = args ?? [],
        kwargs = kwargs ?? {},
        details = details ?? {};

  static const int id = 50;

  static const String text = "RESULT";

  static const int minLength = 3;
  static const int maxLength = 5;

  final int requestID;
  final List<dynamic> args;
  final Map<String, dynamic> kwargs;
  final Map<String, dynamic> details;

  static Result parse(final List<dynamic> message) {
    sanityCheck(message, minLength, maxLength, id, text);

    int requestID = validateIntOrRaise(message[1], text, "request ID");

    Map<String, dynamic> details = validateMapOrRaise(message[2], text, "details");

    List<dynamic>? args;
    if (message.length > minLength) {
      args = validateListOrRaise(message[3], text, "args");
    }

    Map<String, dynamic>? kwargs;
    if (message.length == maxLength) {
      kwargs = validateMapOrRaise(message[4], text, "kwargs");
    }

    return Result(requestID, args: args, kwargs: kwargs, details: details);
  }

  @override
  List<dynamic> marshal() {
    List<dynamic> message = [id, requestID, details];
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
