import "package:wampproto/src/messages/message.dart";
import "package:wampproto/src/messages/util.dart";
import "package:wampproto/src/messages/validation_spec.dart";

abstract class ISubscribedFields {
  int get requestID;

  int get subscriptionID;
}

class SubscribedFields implements ISubscribedFields {
  SubscribedFields(this._requestID, this._subscriptionID);

  final int _requestID;
  final int _subscriptionID;

  @override
  int get requestID => _requestID;

  @override
  int get subscriptionID => _subscriptionID;
}

class Subscribed implements Message {
  Subscribed(int requestID, int subscriptionID) {
    _subscribedFields = SubscribedFields(requestID, subscriptionID);
  }

  Subscribed.withFields(this._subscribedFields);

  static const int id = 33;

  static const String text = "SUBSCRIBED";

  static final _validationSpec = ValidationSpec(
    minLength: 3,
    maxLength: 3,
    message: text,
    spec: {
      1: validateRequestID,
      2: validateSubscriptionID,
    },
  );

  late ISubscribedFields _subscribedFields;

  int get requestID => _subscribedFields.requestID;

  int get subscriptionID => _subscribedFields.subscriptionID;

  static Subscribed parse(final List<dynamic> message) {
    var fields = validateMessage(message, id, _validationSpec);

    return Subscribed(fields.requestID!, fields.subscriptionID!);
  }

  @override
  List<dynamic> marshal() {
    return [id, requestID, subscriptionID];
  }

  @override
  int messageType() => id;
}
