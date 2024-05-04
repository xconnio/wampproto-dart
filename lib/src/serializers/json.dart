import "dart:convert";

import "package:wampproto/src/messages/message.dart";
import "package:wampproto/src/serializers/serializer.dart";

class JSONSerializer implements Serializer {
  @override
  String serialize(final Message message) {
    var jsonString = jsonEncode(message.marshal());
    return jsonString;
  }

  @override
  Message deserialize(final Object message) {
    String msg = message is String ? message : throw Exception("Message is not a String");

    final List<dynamic> wampMessage = jsonDecode(msg);
    return toMessage(wampMessage);
  }
}
