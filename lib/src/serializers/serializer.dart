import "package:wampproto/messages.dart";
import "package:wampproto/src/exception.dart";

Message toMessage(List<dynamic> message) {
  var messageType = message[0];
  if (messageType is! int) {
    throw ProtocolError("invalid message");
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
    case Unsubscribe.id:
      {
        return Unsubscribe.parse(message);
      }
    case Unsubscribed.id:
      {
        return Unsubscribed.parse(message);
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
    case Error.id:
      {
        return Error.parse(message);
      }
    case Cancel.id:
      {
        return Cancel.parse(message);
      }
    case Interrupt.id:
      {
        return Interrupt.parse(message);
      }

    default:
      {
        throw ProtocolError("unknown message type");
      }
  }
}

abstract class Serializer {
  Message deserialize(final Object message /*String|List<int>*/);

  Object serialize(final Message message);
}
