import "package:wampproto/src/messages/message.dart";
import "package:wampproto/src/messages/util.dart";
import "package:wampproto/src/messages/validation_spec.dart";

abstract class IYieldFields {
  int get requestID;

  List<dynamic>? get args;

  Map<String, dynamic>? get kwargs;

  Map<String, dynamic> get options;
}

class YieldFields implements IYieldFields {
  YieldFields(
    this._requestID, {
    List<dynamic>? args,
    Map<String, dynamic>? kwargs,
    Map<String, dynamic>? options,
  })  : _args = args,
        _kwargs = kwargs,
        _options = options ?? {};

  final int _requestID;
  final List<dynamic>? _args;
  final Map<String, dynamic>? _kwargs;
  final Map<String, dynamic> _options;

  @override
  int get requestID => _requestID;

  @override
  List? get args => _args;

  @override
  Map<String, dynamic>? get kwargs => _kwargs;

  @override
  Map<String, dynamic> get options => _options;
}

class Yield implements Message {
  Yield(int requestID, {List<dynamic>? args, Map<String, dynamic>? kwargs, Map<String, dynamic>? options}) {
    _yieldFields = YieldFields(requestID, args: args, kwargs: kwargs, options: options);
  }

  Yield.withYield(this._yieldFields);

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

  late IYieldFields _yieldFields;

  int get requestID => _yieldFields.requestID;

  List<dynamic>? get args => _yieldFields.args;

  Map<String, dynamic>? get kwargs => _yieldFields.kwargs;

  Map<String, dynamic> get options => _yieldFields.options;

  static Yield parse(final List<dynamic> message) {
    var fields = validateMessage(message, id, text, _validationSpec);

    return Yield(fields.requestID!, args: fields.args, kwargs: fields.kwargs, options: fields.options);
  }

  @override
  List<dynamic> marshal() {
    List<dynamic> message = [id, requestID, options];
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
