import "package:wampproto/src/messages/message.dart";
import "package:wampproto/src/messages/util.dart";
import "package:wampproto/src/messages/validation_spec.dart";

abstract class IChallengeFields {
  String get authMethod;

  Map<String, dynamic> get extra;
}

class ChallengeFields implements IChallengeFields {
  ChallengeFields(this._authMethod, this._extra);

  final String _authMethod;

  final Map<String, dynamic> _extra;

  @override
  String get authMethod => _authMethod;

  @override
  Map<String, dynamic> get extra => _extra;
}

class Challenge implements Message {
  Challenge(String authMethod, Map<String, dynamic> extra) {
    _challengeFields = ChallengeFields(authMethod, extra);
  }

  Challenge.withFields(this._challengeFields);

  static const int id = 4;

  static const String text = "CHALLENGE";

  static final _validationSpec = ValidationSpec(
    minLength: 3,
    maxLength: 3,
    message: text,
    spec: {
      1: validateAuthMethod,
      2: validateExtra,
    },
  );

  late IChallengeFields _challengeFields;

  String get authMethod => _challengeFields.authMethod;

  Map<String, dynamic> get extra => _challengeFields.extra;

  static Challenge parse(final List<dynamic> message) {
    var fields = validateMessage(message, id, text, _validationSpec);

    return Challenge(fields.authmethod!, fields.extra!);
  }

  @override
  List<dynamic> marshal() {
    return [id, authMethod, extra];
  }

  @override
  int messageType() => id;
}
