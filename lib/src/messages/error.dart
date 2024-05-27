import "package:wampproto/src/messages/message.dart";
import "package:wampproto/src/messages/util.dart";
import "package:wampproto/src/messages/validation_spec.dart";

abstract class IErrorFields {
  int get msgType;

  int get requestID;

  String get uri;

  List<dynamic> get args;

  Map<String, dynamic> get kwargs;

  Map<String, dynamic> get details;
}

class ErrorFields implements IErrorFields {
  ErrorFields(
    this._msgType,
    this._requestID,
    this._uri, {
    List<dynamic>? args,
    Map<String, dynamic>? kwargs,
    Map<String, dynamic>? details,
  })  : _args = args ?? [],
        _kwargs = kwargs ?? {},
        _details = details ?? {};

  final int _msgType;
  final int _requestID;
  final String _uri;
  final List<dynamic> _args;
  final Map<String, dynamic> _kwargs;
  final Map<String, dynamic> _details;

  @override
  int get msgType => _msgType;

  @override
  int get requestID => _requestID;

  @override
  String get uri => _uri;

  @override
  List get args => _args;

  @override
  Map<String, dynamic> get kwargs => _kwargs;

  @override
  Map<String, dynamic> get details => _details;
}

class Error implements Message {
  Error(this._errorFields);

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

  final IErrorFields _errorFields;

  int get msgType => _errorFields.msgType;

  int get requestID => _errorFields.requestID;

  String get uri => _errorFields.uri;

  List<dynamic> get args => _errorFields.args;

  Map<String, dynamic> get kwargs => _errorFields.kwargs;

  Map<String, dynamic> get details => _errorFields.details;

  static Error parse(final List<dynamic> message) {
    var fields = validateMessage(message, id, text, _validationSpec);

    return Error(
      ErrorFields(
        fields.messageType!,
        fields.requestID!,
        fields.uri!,
        args: fields.args,
        kwargs: fields.kwargs,
        details: fields.details,
      ),
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
