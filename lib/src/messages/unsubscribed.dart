import "package:wampproto/src/messages/message.dart";
import "package:wampproto/src/messages/util.dart";
import "package:wampproto/src/messages/validation_spec.dart";

abstract class IUnsubscribedFields {
  int get requestID;
}

class UnsubscribedFields implements IUnsubscribedFields {
  UnsubscribedFields(this._requestID);

  final int _requestID;

  @override
  int get requestID => _requestID;
}

class Unsubscribed implements Message {
  Unsubscribed(int requestID) {
    _unsubscribedFields = UnsubscribedFields(requestID);
  }

  Unsubscribed.withFields(this._unsubscribedFields);

  static const int id = 35;

  static const String text = "UNSUBSCRIBED";

  static final _validationSpec = ValidationSpec(
    minLength: 2,
    maxLength: 2,
    message: text,
    spec: {
      1: validateRequestID,
    },
  );

  late IUnsubscribedFields _unsubscribedFields;

  int get requestID => _unsubscribedFields.requestID;

  static Unsubscribed parse(final List<dynamic> message) {
    var fields = validateMessage(message, id, text, _validationSpec);

    return Unsubscribed(fields.requestID!);
  }

  @override
  List<dynamic> marshal() {
    return [id, requestID];
  }

  @override
  int messageType() => id;
}
