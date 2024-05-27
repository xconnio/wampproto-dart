import "package:wampproto/src/messages/message.dart";
import "package:wampproto/src/messages/util.dart";
import "package:wampproto/src/messages/validation_spec.dart";

abstract class ISubscribeFields {
  int get requestID;

  String get topic;

  Map<String, dynamic> get options;
}

class SubscribeFields implements ISubscribeFields {
  SubscribeFields(
    this._requestID,
    this._topic, {
    Map<String, dynamic>? options,
  }) : _options = options ?? {};

  final int _requestID;
  final String _topic;
  final Map<String, dynamic> _options;

  @override
  int get requestID => _requestID;

  @override
  String get topic => _topic;

  @override
  Map<String, dynamic> get options => _options;
}

class Subscribe implements Message {
  Subscribe(this._subscribeFields);

  static const int id = 32;

  static const String text = "SUBSCRIBE";

  static final _validationSpec = ValidationSpec(
    minLength: 4,
    maxLength: 4,
    message: text,
    spec: {
      1: validateRequestID,
      2: validateOptions,
      3: validateTopic,
    },
  );

  final ISubscribeFields _subscribeFields;

  int get requestID => _subscribeFields.requestID;

  String get topic => _subscribeFields.topic;

  Map<String, dynamic> get options => _subscribeFields.options;

  static Subscribe parse(final List<dynamic> message) {
    var fields = validateMessage(message, id, text, _validationSpec);

    return Subscribe(SubscribeFields(fields.requestID!, fields.topic!, options: fields.options));
  }

  @override
  List<dynamic> marshal() {
    return [id, requestID, options, topic];
  }

  @override
  int messageType() => id;
}
