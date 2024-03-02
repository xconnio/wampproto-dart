import "dart:convert";
import "dart:typed_data";

import "package:wampproto/src/messages/message.dart";
import "package:wampproto/src/serializers/serializer.dart";

class JsonSerializer implements Serializer {
  @override
  Uint8List serialize(final Message message) {
    var jsonString = jsonEncode(message.marshal());
    return Uint8List.fromList(jsonString.codeUnits);
  }

  @override
  Message deserialize(final Uint8List message) {
    final String s = String.fromCharCodes(message);

    final List<dynamic> wampMessage = jsonDecode(s);
    return toMessage(wampMessage);
  }
}
