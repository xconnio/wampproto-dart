import "package:wampproto/src/messages/message.dart";
import "package:wampproto/src/messages/util.dart";
import "package:wampproto/src/messages/validation_spec.dart";

abstract class IResultFields {
  int get requestID;

  List<dynamic> get args;

  Map<String, dynamic> get kwargs;

  Map<String, dynamic> get details;
}

class ResultFields implements IResultFields {
  ResultFields(
    this._requestID, {
    List<dynamic>? args,
    Map<String, dynamic>? kwargs,
    Map<String, dynamic>? details,
  })  : _args = args ?? [],
        _kwargs = kwargs ?? {},
        _details = details ?? {};

  final int _requestID;
  final List<dynamic> _args;
  final Map<String, dynamic> _kwargs;
  final Map<String, dynamic> _details;

  @override
  int get requestID => _requestID;

  @override
  List get args => _args;

  @override
  Map<String, dynamic> get kwargs => _kwargs;

  @override
  Map<String, dynamic> get details => _details;
}

class Result implements Message {
  Result(int requestID, {List<dynamic>? args, Map<String, dynamic>? kwargs, Map<String, dynamic>? details}) {
    _resultFields = ResultFields(requestID, args: args, kwargs: kwargs, details: details);
  }

  Result.withFields(this._resultFields);

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

  late IResultFields _resultFields;

  int get requestID => _resultFields.requestID;

  List<dynamic> get args => _resultFields.args;

  Map<String, dynamic> get kwargs => _resultFields.kwargs;

  Map<String, dynamic> get details => _resultFields.details;

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
