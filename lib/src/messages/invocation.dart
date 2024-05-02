import "package:wampproto/src/messages/message.dart";
import "package:wampproto/src/messages/util.dart";

class Invocation implements Message {
  Invocation(
    this.requestID,
    this.registrationID, {
    List<dynamic>? args,
    Map<String, dynamic>? kwargs,
    Map<String, dynamic>? details,
  })  : args = args ?? [],
        kwargs = kwargs ?? {},
        details = details ?? {};

  static const int id = 68;

  static const String text = "INVOCATION";

  final int requestID;
  final int registrationID;
  final List<dynamic> args;
  final Map<String, dynamic> kwargs;
  final Map<String, dynamic> details;

  static Invocation parse(final List<dynamic> message) {
    sanityCheck(message, 4, 6, id, text);

    int requestID = validateIntOrRaise(message[1], text, "request ID");

    int registrationID = validateIntOrRaise(message[2], text, "registration ID");

    Map<String, dynamic> details = validateMapOrRaise(message[3], text, "details");

    List<dynamic>? args;
    if (message.length > 4) {
      args = validateListOrRaise(message[4], text, "args");
    }

    Map<String, dynamic>? kwargs;
    if (message.length > 5) {
      kwargs = validateMapOrRaise(message[5], text, "kwargs");
    }

    return Invocation(requestID, registrationID, args: args, kwargs: kwargs, details: details);
  }

  @override
  List<dynamic> marshal() {
    List<dynamic> message = [id, requestID, registrationID, details];
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
