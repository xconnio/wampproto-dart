import "package:wampproto/src/messages/message.dart";
import "package:wampproto/src/messages/util.dart";
import "package:wampproto/src/messages/validation_spec.dart";

abstract class IUnsubscribeFields {
  int get requestID;

  int get subscriptionID;
}

class UnsubscribeFields implements IUnsubscribeFields {
  UnsubscribeFields(this._requestID, this._subscriptionID);

  final int _requestID;
  final int _subscriptionID;

  @override
  int get requestID => _requestID;

  @override
  int get subscriptionID => _subscriptionID;
}

class Unsubscribe implements Message {
  Unsubscribe(int requestID, int subscriptionID) {
    _unsubscribeFields = UnsubscribeFields(requestID, subscriptionID);
  }

  Unsubscribe.withFields(this._unsubscribeFields);

  static const int id = 34;

  static const String text = "UNSUBSCRIBE";

  static final _validationSpec = ValidationSpec(
    minLength: 3,
    maxLength: 3,
    message: text,
    spec: {
      1: validateRequestID,
      2: validateSubscriptionID,
    },
  );

  late IUnsubscribeFields _unsubscribeFields;

  int get requestID => _unsubscribeFields.requestID;

  int get subscriptionID => _unsubscribeFields.subscriptionID;

  static Unsubscribe parse(final List<dynamic> message) {
    var fields = validateMessage(message, id, _validationSpec);

    return Unsubscribe(fields.requestID!, fields.subscriptionID!);
  }

  @override
  List<dynamic> marshal() {
    return [id, requestID, subscriptionID];
  }

  @override
  int messageType() => id;
}
