import "dart:typed_data";

import "package:wampproto/messages.dart";

Message toMessage(List<dynamic> message) {
  var messageType = message[0];
  if (messageType is! int) {
    throw "invalid message";
  }

  switch (messageType) {
    case Hello.id:
      {
        return Hello.parse(message);
      }
    case Welcome.id:
      {
        return Welcome.parse(message);
      }
    case Abort.id:
      {
        return Abort.parse(message);
      }
    case Challenge.id:
      {
        return Challenge.parse(message);
      }
    case Authenticate.id:
      {
        return Authenticate.parse(message);
      }
    case Goodbye.id:
      {
        return Goodbye.parse(message);
      }
    case Call.id:
      {
        return Call.parse(message);
      }
    case Invocation.id:
      {
        return Invocation.parse(message);
      }
    case Yield.id:
      {
        return Yield.parse(message);
      }
    case Result.id:
      {
        return Result.parse(message);
      }
    case Register.id:
      {
        return Register.parse(message);
      }
    case Registered.id:
      {
        return Registered.parse(message);
      }
    case UnRegister.id:
      {
        return UnRegister.parse(message);
      }
    case UnRegistered.id:
      {
        return UnRegistered.parse(message);
      }
    case Subscribe.id:
      {
        return Subscribe.parse(message);
      }
    case Subscribed.id:
      {
        return Subscribed.parse(message);
      }
    case UnSubscribe.id:
      {
        return UnSubscribe.parse(message);
      }
    case UnSubscribed.id:
      {
        return UnSubscribed.parse(message);
      }
    case Publish.id:
      {
        return Publish.parse(message);
      }
    case Published.id:
      {
        return Published.parse(message);
      }
    case Event.id:
      {
        return Event.parse(message);
      }

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
