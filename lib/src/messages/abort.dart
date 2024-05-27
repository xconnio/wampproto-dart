import "package:wampproto/src/messages/message.dart";
import "package:wampproto/src/messages/util.dart";
import "package:wampproto/src/messages/validation_spec.dart";

abstract class IAbortFields {
  Map<String, dynamic> get details;

  String get reason;
}

class AbortFields implements IAbortFields {
  AbortFields(this._details, this._reason);

  final Map<String, dynamic> _details;
  final String _reason;

  @override
  Map<String, dynamic> get details => _details;

  @override
  String get reason => _reason;
}

class Abort implements Message {
  Abort(this._abortFields);

  static const int id = 3;

  static const String text = "ABORT";

  static final _validationSpec = ValidationSpec(
    minLength: 3,
    maxLength: 3,
    message: text,
    spec: {
      1: validateDetails,
      2: validateReason,
    },
  );

  final IAbortFields _abortFields;

  Map<String, dynamic> get details => _abortFields.details;

  String get reason => _abortFields.reason;

  static Abort parse(final List<dynamic> message) {
    var fields = validateMessage(message, id, text, _validationSpec);

    return Abort(AbortFields(fields.details!, fields.reason!));
  }

  @override
  List<dynamic> marshal() {
    return [id, details, reason];
  }

  @override
  int messageType() => id;
}
