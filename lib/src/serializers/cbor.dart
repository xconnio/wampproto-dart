import "dart:typed_data";

import "package:cbor/simple.dart";
import "package:wampproto/src/messages/message.dart";
import "package:wampproto/src/serializers/serializer.dart";

class CBORSerializer implements Serializer {
  @override
  Uint8List serialize(Message message) {
    final encoded = cbor.encode(message.marshal());
    return Uint8List.fromList(encoded);
  }

  @override
  Message deserialize(Uint8List message) {
    final decoded = cbor.decode(message);
    if (decoded is! List) {
      throw "bad type";
    }

    return toMessage(decoded);
  }
}
