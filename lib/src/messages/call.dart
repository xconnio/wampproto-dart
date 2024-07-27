import "package:wampproto/src/messages/message.dart";
import "package:wampproto/src/messages/util.dart";
import "package:wampproto/src/messages/validation_spec.dart";

abstract class ICallFields {
  int get requestID;

  String get uri;

  List<dynamic>? get args;

  Map<String, dynamic>? get kwargs;

  Map<String, dynamic> get options;
}

class CallFields implements ICallFields {
  CallFields(
    this._requestID,
    this._uri, {
    List<dynamic>? args,
    Map<String, dynamic>? kwargs,
    Map<String, dynamic>? options,
  })  : _args = args,
        _kwargs = kwargs,
        _options = options ?? {};

  final int _requestID;
  final String _uri;
  final List<dynamic>? _args;
  final Map<String, dynamic>? _kwargs;
  final Map<String, dynamic> _options;

  @override
  int get requestID => _requestID;

  @override
  String get uri => _uri;

  @override
  List? get args => _args;

  @override
  Map<String, dynamic>? get kwargs => _kwargs;

  @override
  Map<String, dynamic> get options => _options;
}

class Call implements Message {
  Call(int requestID, String uri, {List<dynamic>? args, Map<String, dynamic>? kwargs, Map<String, dynamic>? options}) {
    _callFields = CallFields(requestID, uri, args: args, kwargs: kwargs, options: options);
  }

  Call.withFields(this._callFields);

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

  late ICallFields _callFields;

  int get requestID => _callFields.requestID;

  String get uri => _callFields.uri;

  List<dynamic>? get args => _callFields.args;

  Map<String, dynamic>? get kwargs => _callFields.kwargs;

  Map<String, dynamic> get options => _callFields.options;

  static Call parse(final List<dynamic> message) {
    var fields = validateMessage(message, id, _validationSpec);

    return Call(fields.requestID!, fields.uri!, args: fields.args, kwargs: fields.kwargs, options: fields.options);
  }

  @override
  List<dynamic> marshal() {
    List<dynamic> message = [id, requestID, options, uri];
    if (args != null) {
      message.add(args);
    }

    if (kwargs != null) {
      if (args == null) {
        message.add([]);
      }
      message.add(kwargs);
    }

    return message;
  }

  @override
  int messageType() => id;
}
