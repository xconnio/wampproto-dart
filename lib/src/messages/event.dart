import "package:wampproto/src/messages/message.dart";
import "package:wampproto/src/messages/util.dart";
import "package:wampproto/src/messages/validation_spec.dart";

abstract class IEventFields {
  int get subscriptionID;

  int get publicationID;

  List<dynamic> get args;

  Map<String, dynamic> get kwargs;

  Map<String, dynamic> get details;
}

class EventFields implements IEventFields {
  EventFields(
    this._subscriptionID,
    this._publicationID, {
    List<dynamic>? args,
    Map<String, dynamic>? kwargs,
    Map<String, dynamic>? details,
  })  : _args = args ?? [],
        _kwargs = kwargs ?? {},
        _details = details ?? {};

  final int _subscriptionID;
  final int _publicationID;
  final List<dynamic> _args;
  final Map<String, dynamic> _kwargs;
  final Map<String, dynamic> _details;

  @override
  int get subscriptionID => _subscriptionID;

  @override
  int get publicationID => _publicationID;

  @override
  List get args => _args;

  @override
  Map<String, dynamic> get kwargs => _kwargs;

  @override
  Map<String, dynamic> get details => _details;
}

class Event implements Message {
  Event(this._eventFields);

  static const int id = 36;

  static const String text = "EVENT";

  static final _validationSpec = ValidationSpec(
    minLength: 4,
    maxLength: 6,
    message: text,
    spec: {
      1: validateSubscriptionID,
      2: validatePublicationID,
      3: validateDetails,
      4: validateArgs,
      5: validateKwargs,
    },
  );

  final IEventFields _eventFields;

  int get subscriptionID => _eventFields.subscriptionID;

  int get publicationID => _eventFields.publicationID;

  List<dynamic> get args => _eventFields.args;

  Map<String, dynamic> get kwargs => _eventFields.kwargs;

  Map<String, dynamic> get details => _eventFields.details;

  static Event parse(final List<dynamic> message) {
    var fields = validateMessage(message, id, text, _validationSpec);

    return Event(
      EventFields(
        fields.subscriptionID!,
        fields.publicationID!,
        args: fields.args,
        kwargs: fields.kwargs,
        details: fields.details,
      ),
    );
  }

  @override
  List<dynamic> marshal() {
    List<dynamic> message = [id, subscriptionID, publicationID, details];
    if (args.isNotEmpty) {
      message.add(args);
    }

    if (kwargs.isNotEmpty) {
      if (args.isEmpty) {
        message.add([]);
      }
      message.add(kwargs);
    }

    return message;
  }

  @override
  int messageType() => id;
}
