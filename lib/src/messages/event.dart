import "package:wampproto/src/messages/message.dart";
import "package:wampproto/src/messages/util.dart";
import "package:wampproto/src/messages/validation_spec.dart";

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

  static final _validationSpec = ValidationSpec(
    minLength: 4,
    maxLength: 6,
    message: text,
    spec: {
      1: validateSubscriptionID,
      2: validatePublicationID,
      3: validateDetails,
      4: validateArgs,
      5: validateKwargs,
    },
  );

  final int subscriptionID;
  final int publicationID;
  final List<dynamic> args;
  final Map<String, dynamic> kwargs;
  final Map<String, dynamic> details;

  static Event parse(final List<dynamic> message) {
    var fields = validateMessage(message, id, text, _validationSpec);

    return Event(
      fields.subscriptionID!,
      fields.publicationID!,
      args: fields.args,
      kwargs: fields.kwargs,
      details: fields.details,
    );
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
