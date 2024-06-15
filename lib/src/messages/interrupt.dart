import "package:wampproto/src/messages/message.dart";
import "package:wampproto/src/messages/util.dart";
import "package:wampproto/src/messages/validation_spec.dart";

abstract class IInterruptFields {
  int get requestID;

  Map<String, dynamic> get options;
}

class InterruptFields implements IInterruptFields {
  InterruptFields(this._requestID, {Map<String, dynamic>? options}) : _options = options ?? {};

  final int _requestID;
  final Map<String, dynamic> _options;

  @override
  int get requestID => _requestID;

  @override
  Map<String, dynamic> get options => _options;
}

class Interrupt implements Message {
  Interrupt(int requestID, {Map<String, dynamic>? options}) {
    _interruptFields = InterruptFields(requestID, options: options);
  }

  Interrupt.withFields(this._interruptFields);

  static const int id = 69;

  static const String text = "INTERRUPT";

  static final _validationSpec = ValidationSpec(
    minLength: 3,
    maxLength: 3,
    message: text,
    spec: {
      1: validateRequestID,
      2: validateOptions,
    },
  );

  late IInterruptFields _interruptFields;

  int get requestID => _interruptFields.requestID;

  Map<String, dynamic> get options => _interruptFields.options;

  static Interrupt parse(final List<dynamic> message) {
    var fields = validateMessage(message, id, text, _validationSpec);

    return Interrupt(fields.requestID!, options: fields.options);
  }

  @override
  List<dynamic> marshal() {
    return [id, requestID, options];
  }

  @override
  int messageType() => id;
}
