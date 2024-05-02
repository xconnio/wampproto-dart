import "package:wampproto/src/messages/message.dart";
import "package:wampproto/src/messages/util.dart";

class Event implements Message {
  Event(
    this.subscriptionID,
    this.publicationID, {
    List<dynamic>? args,
    Map<String, dynamic>? kwargs,
    Map<String, dynamic>? details,
  })  : args = args ?? [],
        kwargs = kwargs ?? {},
        details = details ?? {};

  static const int id = 36;

  static const String text = "EVENT";

  final int subscriptionID;
  final int publicationID;
  final List<dynamic> args;
  final Map<String, dynamic> kwargs;
  final Map<String, dynamic> details;

  static Event parse(final List<dynamic> message) {
    sanityCheck(message, 4, 6, id, text);

    int subscriptionID = validateIntOrRaise(message[1], text, "subscription ID");

    int publicationID = validateIntOrRaise(message[2], text, "publication ID");

    Map<String, dynamic> details = validateMapOrRaise(message[3], text, "details");

    List<dynamic>? args;
    if (message.length > 4) {
      args = validateListOrRaise(message[4], text, "args");
    }

    Map<String, dynamic>? kwargs;
    if (message.length > 5) {
      kwargs = validateMapOrRaise(message[5], text, "kwargs");
    }

    return Event(subscriptionID, publicationID, args: args, kwargs: kwargs, details: details);
  }

  @override
  List<dynamic> marshal() {
    List<dynamic> message = [id, subscriptionID, publicationID, details];
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
