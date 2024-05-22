import "package:wampproto/src/messages/message.dart";
import "package:wampproto/src/messages/util.dart";
import "package:wampproto/src/messages/validation_spec.dart";

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

  static final _validationSpec = ValidationSpec(
    minLength: 3,
    maxLength: 5,
    message: text,
    spec: {
      1: validateRequestID,
      2: validateOptions,
      3: validateArgs,
      4: validateKwargs,
    },
  );

  final int requestID;
  final List<dynamic> args;
  final Map<String, dynamic> kwargs;
  final Map<String, dynamic> options;

  static Yield parse(final List<dynamic> message) {
    var fields = validateMessage(message, id, text, _validationSpec);

    return Yield(fields.requestID!, args: fields.args, kwargs: fields.kwargs, options: fields.options);
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
