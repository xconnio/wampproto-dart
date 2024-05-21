import "package:wampproto/src/messages/message.dart";
import "package:wampproto/src/messages/util.dart";
import "package:wampproto/src/messages/validation_spec.dart";

class Error implements Message {
  Error(
    this.msgType,
    this.requestID,
    this.uri, {
    List<dynamic>? args,
    Map<String, dynamic>? kwargs,
    Map<String, dynamic>? details,
  })  : args = args ?? [],
        kwargs = kwargs ?? {},
        details = details ?? {};

  static const int id = 8;

  static const String text = "ERROR";

  static final _validationSpec = ValidationSpec(
    minLength: 5,
    maxLength: 7,
    message: text,
    spec: {
      1: validateMessageType,
      2: validateRequestID,
      3: validateDetails,
      4: validateURI,
      5: validateArgs,
      6: validateKwargs,
    },
  );

  final int msgType;
  final int requestID;
  final String uri;
  final List<dynamic> args;
  final Map<String, dynamic> kwargs;
  final Map<String, dynamic> details;

  static Error parse(final List<dynamic> message) {
    var fields = validateMessage(message, id, text, _validationSpec);

    return Error(
      fields.messageType!,
      fields.requestID!,
      fields.uri!,
      args: fields.args,
      kwargs: fields.kwargs,
      details: fields.details,
    );
  }

  @override
  List<dynamic> marshal() {
    List<dynamic> message = [id, msgType, requestID, details, uri];
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
