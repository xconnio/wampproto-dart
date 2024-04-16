import "dart:typed_data";

import "package:msgpack_dart/msgpack_dart.dart" as msgpack_dart;

import "package:wampproto/src/messages/message.dart";
import "package:wampproto/src/serializers/serializer.dart";

class MsgPackSerializer implements Serializer {
  @override
  Uint8List serialize(Message message) {
    final encoded = msgpack_dart.serialize(message.marshal());
    return Uint8List.fromList(encoded);
  }

  @override
  Message deserialize(Uint8List message) {
    final decoded = msgpack_dart.deserialize(message);
    if (decoded is! List) {
      throw "bad type";
    }

    return toMessage(decoded);
  }
}
