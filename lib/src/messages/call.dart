import "package:wampproto/src/messages/message.dart";
import "package:wampproto/src/messages/util.dart";
import "package:wampproto/src/messages/validation_spec.dart";

class Call implements Message {
  Call(
    this.requestID,
    this.uri, {
    List<dynamic>? args,
    Map<String, dynamic>? kwargs,
    Map<String, dynamic>? options,
  })  : args = args ?? [],
        kwargs = kwargs ?? {},
        options = options ?? {};

  static const int id = 48;

  static const String text = "CALL";

  static final _validationSpec = ValidationSpec(
    minLength: 4,
    maxLength: 6,
    message: text,
    spec: {
      1: validateRequestID,
      2: validateOptions,
      3: validateURI,
      4: validateArgs,
      5: validateKwargs,
    },
  );

  final int requestID;
  final String uri;
  final List<dynamic> args;
  final Map<String, dynamic> kwargs;
  final Map<String, dynamic> options;

  static Call parse(final List<dynamic> message) {
    var fields = validateMessage(message, id, text, _validationSpec);

    return Call(fields.requestID!, fields.uri!, args: fields.args, kwargs: fields.kwargs, options: fields.options);
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
