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
  Message deserialize(Object message) {
    Uint8List msgBytes = message is Uint8List ? message : throw Exception("Message is not a Uint8List");

    final decoded = msgpack_dart.deserialize(msgBytes, toJSON: true);
    if (decoded is! List) {
      throw throw Exception("bad type");
    }

    return toMessage(decoded);
  }
}
