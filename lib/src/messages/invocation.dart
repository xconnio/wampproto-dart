import "package:wampproto/src/messages/message.dart";
import "package:wampproto/src/messages/util.dart";
import "package:wampproto/src/messages/validation_spec.dart";

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

  static final _validationSpec = ValidationSpec(
    minLength: 4,
    maxLength: 6,
    message: text,
    spec: {
      1: validateRequestID,
      2: validateRegistrationID,
      3: validateDetails,
      4: validateArgs,
      5: validateKwargs,
    },
  );

  final int requestID;
  final int registrationID;
  final List<dynamic> args;
  final Map<String, dynamic> kwargs;
  final Map<String, dynamic> details;

  static Invocation parse(final List<dynamic> message) {
    var fields = validateMessage(message, id, text, _validationSpec);

    return Invocation(
      fields.requestID!,
      fields.registrationID!,
      args: fields.args,
      kwargs: fields.kwargs,
      details: fields.details,
    );
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
