import "dart:typed_data";

import "package:wampproto/messages.dart";

import "package:wampproto/src/messages/message.dart";

Message toMessage(List<dynamic> message) {
  var messageType = message[0];
  if (messageType is! int) {
    throw "invalid message";
  }

  switch (messageType) {
    case Hello.id:
      {return Hello.parse(message);}
    default:
      {
        throw "unknown message type";
      }
  }
}

abstract class Serializer {
  Message deserialize(final Uint8List message);
  Uint8List serialize(final Message message);
}
