import "package:wampproto/src/messages/message.dart";
import "package:wampproto/src/messages/util.dart";
import "package:wampproto/src/messages/validation_spec.dart";

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

  static final _validationSpec = ValidationSpec(
    minLength: 3,
    maxLength: 5,
    message: text,
    spec: {
      1: validateRequestID,
      2: validateDetails,
      3: validateArgs,
      4: validateKwargs,
    },
  );

  final int requestID;
  final List<dynamic> args;
  final Map<String, dynamic> kwargs;
  final Map<String, dynamic> details;

  static Result parse(final List<dynamic> message) {
    var fields = validateMessage(message, id, text, _validationSpec);

    return Result(fields.requestID!, args: fields.args, kwargs: fields.kwargs, details: fields.details);
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
