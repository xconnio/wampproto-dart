import "package:wampproto/src/messages/message.dart";
import "package:wampproto/src/messages/util.dart";
import "package:wampproto/src/messages/validation_spec.dart";

abstract class IAbortFields {
  Map<String, dynamic> get details;

  String get reason;

  List<dynamic>? get args;

  Map<String, dynamic>? get kwargs;
}

class AbortFields implements IAbortFields {
  AbortFields(
    this._details,
    this._reason, {
    List<dynamic>? args,
    Map<String, dynamic>? kwargs,
  })  : _args = args,
        _kwargs = kwargs;

  final Map<String, dynamic> _details;
  final String _reason;

  final List<dynamic>? _args;
  final Map<String, dynamic>? _kwargs;

  @override
  Map<String, dynamic> get details => _details;

  @override
  String get reason => _reason;

  @override
  List? get args => _args;

  @override
  Map<String, dynamic>? get kwargs => _kwargs;
}

class Abort implements Message {
  Abort(Map<String, dynamic> details, String reason, {List<dynamic>? args, Map<String, dynamic>? kwargs}) {
    _abortFields = AbortFields(details, reason, args: args, kwargs: kwargs);
  }

  Abort.withFields(this._abortFields);

  static const int id = 3;

  static const String text = "ABORT";

  static final _validationSpec = ValidationSpec(
    minLength: 3,
    maxLength: 5,
    message: text,
    spec: {
      1: validateDetails,
      2: validateReason,
      3: validateArgs,
      4: validateKwargs,
    },
  );

  late IAbortFields _abortFields;

  Map<String, dynamic> get details => _abortFields.details;

  String get reason => _abortFields.reason;

  List<dynamic>? get args => _abortFields.args;

  Map<String, dynamic>? get kwargs => _abortFields.kwargs;

  static Abort parse(final List<dynamic> message) {
    var fields = validateMessage(message, id, _validationSpec);

    return Abort(fields.details!, fields.reason!, args: fields.args, kwargs: fields.kwargs);
  }

  @override
  List<dynamic> marshal() {
    List<dynamic> message = [id, details, reason];

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
