import "package:wampproto/src/messages/message.dart";
import "package:wampproto/src/messages/util.dart";

class Yield implements Message {
  Yield(
    this.requestID, {
    List<dynamic>? args,
    Map<String, dynamic>? kwargs,
    Map<String, dynamic>? options,
  })  : args = args ?? [],
        kwargs = kwargs ?? {},
        options = options ?? {};

  static const int id = 70;

  static const String text = "YIELD";

  final int requestID;
  final List<dynamic> args;
  final Map<String, dynamic> kwargs;
  final Map<String, dynamic> options;

  static Yield parse(final List<dynamic> message) {
    sanityCheck(message, 3, 5, id, text);

    int requestID = validateIntOrRaise(message[1], text, "request ID");

    Map<String, dynamic> options = validateMapOrRaise(message[2], text, "options");

    List<dynamic>? args;
    if (message.length > 3) {
      args = validateListOrRaise(message[3], text, "args");
    }

    Map<String, dynamic>? kwargs;
    if (message.length > 4) {
      kwargs = validateMapOrRaise(message[4], text, "kwargs");
    }

    return Yield(requestID, args: args, kwargs: kwargs, options: options);
  }

  @override
  List<dynamic> marshal() {
    List<dynamic> message = [id, requestID, options];
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
