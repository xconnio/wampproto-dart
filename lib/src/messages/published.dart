import "package:wampproto/src/messages/message.dart";
import "package:wampproto/src/messages/util.dart";
import "package:wampproto/src/messages/validation_spec.dart";

class Published implements Message {
  Published(this.requestID, this.publicationID);

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

  final int requestID;
  final int publicationID;

  static Published parse(final List<dynamic> message) {
    var fields = validateMessage(message, id, text, _validationSpec);

    return Published(fields.requestID!, fields.publicationID!);
  }

  @override
  List<dynamic> marshal() {
    return [id, requestID, publicationID];
  }

  @override
  int messageType() => id;
}
