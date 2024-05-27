import "package:wampproto/src/messages/message.dart";
import "package:wampproto/src/messages/util.dart";
import "package:wampproto/src/messages/validation_spec.dart";

abstract class IGoodbyeFields {
  Map<String, dynamic> get details;

  String get reason;
}

class GoodbyeFields implements IGoodbyeFields {
  GoodbyeFields(this._details, this._reason);

  final Map<String, dynamic> _details;
  final String _reason;

  @override
  Map<String, dynamic> get details => _details;

  @override
  String get reason => _reason;
}

class Goodbye implements Message {
  Goodbye(this._goodbyeFields);

  static const int id = 6;

  static const String text = "GOODBYE";

  static final _validationSpec = ValidationSpec(
    minLength: 3,
    maxLength: 3,
    message: text,
    spec: {
      1: validateDetails,
      2: validateReason,
    },
  );

  final IGoodbyeFields _goodbyeFields;

  Map<String, dynamic> get details => _goodbyeFields.details;

  String get reason => _goodbyeFields.reason;

  static Goodbye parse(final List<dynamic> message) {
    var fields = validateMessage(message, id, text, _validationSpec);

    return Goodbye(GoodbyeFields(fields.details!, fields.reason!));
  }

  @override
  List<dynamic> marshal() {
    return [id, details, reason];
  }

  @override
  int messageType() => id;
}
