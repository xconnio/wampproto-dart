import "dart:typed_data";

import "package:cbor/cbor.dart" as ncbor;
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
  Message deserialize(Object message) {
    Uint8List msgBytes = message is Uint8List ? message : throw Exception("Message is not a Uint8List");

    final decoded = const ncbor.CborDecoder().convert(msgBytes).toJson(substituteValue: msgBytes);
    if (decoded is! List) {
      throw Exception("bad type");
    }

    return toMessage(decoded);
  }
}
