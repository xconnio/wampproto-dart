import "package:wampproto/src/messages/message.dart";
import "package:wampproto/src/messages/util.dart";
import "package:wampproto/src/messages/validation_spec.dart";

abstract class ICancelFields {
  int get requestID;

  Map<String, dynamic> get options;
}

class CancelFields implements ICancelFields {
  CancelFields(this._requestID, {Map<String, dynamic>? options}) : _options = options ?? {};

  final int _requestID;
  final Map<String, dynamic> _options;

  @override
  int get requestID => _requestID;

  @override
  Map<String, dynamic> get options => _options;
}

class Cancel implements Message {
  Cancel(this._cancelFields);

  static const int id = 49;

  static const String text = "CANCEL";

  static final _validationSpec = ValidationSpec(
    minLength: 3,
    maxLength: 3,
    message: text,
    spec: {
      1: validateRequestID,
      2: validateOptions,
    },
  );

  final ICancelFields _cancelFields;

  int get requestID => _cancelFields.requestID;

  Map<String, dynamic> get options => _cancelFields.options;

  static Cancel parse(final List<dynamic> message) {
    var fields = validateMessage(message, id, text, _validationSpec);

    return Cancel(CancelFields(fields.requestID!, options: fields.options));
  }

  @override
  List<dynamic> marshal() {
    return [id, requestID, options];
  }

  @override
  int messageType() => id;
}
