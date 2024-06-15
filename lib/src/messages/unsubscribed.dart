import "package:wampproto/src/messages/message.dart";
import "package:wampproto/src/messages/util.dart";
import "package:wampproto/src/messages/validation_spec.dart";

abstract class IUnSubscribedFields {
  int get requestID;
}

class UnSubscribedFields implements IUnSubscribedFields {
  UnSubscribedFields(this._requestID);

  final int _requestID;

  @override
  int get requestID => _requestID;
}

class UnSubscribed implements Message {
  UnSubscribed(int requestID) {
    _unSubscribedFields = UnSubscribedFields(requestID);
  }

  UnSubscribed.withFields(this._unSubscribedFields);

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

  late IUnSubscribedFields _unSubscribedFields;

  int get requestID => _unSubscribedFields.requestID;

  static UnSubscribed parse(final List<dynamic> message) {
    var fields = validateMessage(message, id, text, _validationSpec);

    return UnSubscribed(fields.requestID!);
  }

  @override
  List<dynamic> marshal() {
    return [id, requestID];
  }

  @override
  int messageType() => id;
}
