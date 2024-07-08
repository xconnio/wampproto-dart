import "package:wampproto/src/messages/message.dart";
import "package:wampproto/src/messages/util.dart";
import "package:wampproto/src/messages/validation_spec.dart";

abstract class IInvocationFields {
  int get requestID;

  int get registrationID;

  List<dynamic>? get args;

  Map<String, dynamic>? get kwargs;

  Map<String, dynamic> get details;
}

class InvocationFields implements IInvocationFields {
  InvocationFields(
    this._requestID,
    this._registrationID, {
    List<dynamic>? args,
    Map<String, dynamic>? kwargs,
    Map<String, dynamic>? details,
  })  : _args = args,
        _kwargs = kwargs,
        _details = details ?? {};

  final int _requestID;
  final int _registrationID;
  final List<dynamic>? _args;
  final Map<String, dynamic>? _kwargs;
  final Map<String, dynamic> _details;

  @override
  int get requestID => _requestID;

  @override
  int get registrationID => _registrationID;

  @override
  List? get args => _args;

  @override
  Map<String, dynamic>? get kwargs => _kwargs;

  @override
  Map<String, dynamic> get details => _details;
}

class Invocation implements Message {
  Invocation(
    int requestID,
    int registrationID, {
    List<dynamic>? args,
    Map<String, dynamic>? kwargs,
    Map<String, dynamic>? details,
  }) {
    _invocationFields = InvocationFields(requestID, registrationID, args: args, kwargs: kwargs, details: details);
  }

  Invocation.withFields(this._invocationFields);

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

  late IInvocationFields _invocationFields;

  int get requestID => _invocationFields.requestID;

  int get registrationID => _invocationFields.registrationID;

  List<dynamic>? get args => _invocationFields.args;

  Map<String, dynamic>? get kwargs => _invocationFields.kwargs;

  Map<String, dynamic> get details => _invocationFields.details;

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
