import "package:wampproto/src/messages/message.dart";
import "package:wampproto/src/messages/util.dart";
import "package:wampproto/src/messages/validation_spec.dart";

abstract class IUnSubscribeFields {
  int get requestID;

  int get subscriptionID;
}

class UnSubscribeFields implements IUnSubscribeFields {
  UnSubscribeFields(this._requestID, this._subscriptionID);

  final int _requestID;
  final int _subscriptionID;

  @override
  int get requestID => _requestID;

  @override
  int get subscriptionID => _subscriptionID;
}

class UnSubscribe implements Message {
  UnSubscribe(this._unSubscribeFields);

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

  final IUnSubscribeFields _unSubscribeFields;

  int get requestID => _unSubscribeFields.requestID;

  int get subscriptionID => _unSubscribeFields.subscriptionID;

  static UnSubscribe parse(final List<dynamic> message) {
    var fields = validateMessage(message, id, text, _validationSpec);

    return UnSubscribe(UnSubscribeFields(fields.requestID!, fields.subscriptionID!));
  }

  @override
  List<dynamic> marshal() {
    return [id, requestID, subscriptionID];
  }

  @override
  int messageType() => id;
}
