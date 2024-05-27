import "package:wampproto/src/messages/message.dart";
import "package:wampproto/src/messages/util.dart";
import "package:wampproto/src/messages/validation_spec.dart";

abstract class IPublishedFields {
  int get requestID;

  int get publicationID;
}

class PublishedFields implements IPublishedFields {
  PublishedFields(this._requestID, this._publicationID);

  final int _requestID;
  final int _publicationID;

  @override
  int get requestID => _requestID;

  @override
  int get publicationID => _publicationID;
}

class Published implements Message {
  Published(this._publishedFields);

  static const int id = 17;

  static const String text = "PUBLISHED";

  static final _validationSpec = ValidationSpec(
    minLength: 3,
    maxLength: 3,
    message: text,
    spec: {
      1: validateRequestID,
      2: validatePublicationID,
    },
  );

  final PublishedFields _publishedFields;

  int get requestID => _publishedFields.requestID;

  int get publicationID => _publishedFields.publicationID;

  static Published parse(final List<dynamic> message) {
    var fields = validateMessage(message, id, text, _validationSpec);

    return Published(PublishedFields(fields.requestID!, fields.publicationID!));
  }

  @override
  List<dynamic> marshal() {
    return [id, requestID, publicationID];
  }

  @override
  int messageType() => id;
}
