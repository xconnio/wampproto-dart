import "package:wampproto/messages.dart";
import "package:wampproto/serializers.dart";
import "package:wampproto/src/exception.dart";

class WAMPSession {
  WAMPSession({Serializer? serializer}) : _serializer = serializer ?? JSONSerializer();

  final Serializer _serializer;

  // data structures for RPC
  final Map<int, int> _callRequests = {};
  final Map<int, int> _registerRequests = {};
  final Map<int, int> _registrations = {};
  final Map<int, int> _invocationRequests = {};
  final Map<int, int> _unregisterRequests = {};

  // data structures for PubSub
  final Map<int, int> _publishRequests = {};
  final Map<int, int> _subscribeRequests = {};
  final Map<int, int> _subscriptions = {};
  final Map<int, int> _unsubscribeRequests = {};

  Object sendMessage(Message msg) {
    if (msg is Call) {
      _callRequests[msg.requestID] = msg.requestID;

      return _serializer.serialize(msg);
    } else if (msg is Register) {
      _registerRequests[msg.requestID] = msg.requestID;

      return _serializer.serialize(msg);
    } else if (msg is Unregister) {
      _unregisterRequests[msg.requestID] = msg.registrationID;

      return _serializer.serialize(msg);
    } else if (msg is Yield) {
      if (!_invocationRequests.containsKey(msg.requestID)) {
        throw ArgumentError("cannot yield for unknown invocation request");
      }
      _invocationRequests.remove(msg.requestID);

      return _serializer.serialize(msg);
    } else if (msg is Publish) {
      if (msg.options.containsKey("acknowledge") && msg.options["acknowledge"]) {
        _publishRequests[msg.requestID] = msg.requestID;
      }

      return _serializer.serialize(msg);
    } else if (msg is Subscribe) {
      _subscribeRequests[msg.requestID] = msg.requestID;

      return _serializer.serialize(msg);
    } else if (msg is Unsubscribe) {
      _unsubscribeRequests[msg.requestID] = msg.subscriptionID;

      return _serializer.serialize(msg);
    } else if (msg is Error) {
      if (msg.msgType != Invocation.id) {
        throw ArgumentError("send only supported for invocation error");
      }

      var data = _serializer.serialize(msg);
      _invocationRequests.remove(msg.requestID);
      return data;
    } else if (msg is Goodbye) {
      return _serializer.serialize(msg);
    }
    throw ProtocolError("unknown message ${msg.runtimeType}");
  }

  Message receive(Object data) {
    final msg = _serializer.deserialize(data);
    return receiveMessage(msg);
  }

  Message receiveMessage(Message msg) {
    if (msg is Result) {
      if (!_callRequests.containsKey(msg.requestID)) {
        throw ProtocolError("received RESULT for invalid request ID ${msg.requestID}");
      }
      _callRequests.remove(msg.requestID);

      return msg;
    } else if (msg is Registered) {
      if (!_registerRequests.containsKey(msg.requestID)) {
        throw ProtocolError("received REGISTERED for invalid request ID ${msg.requestID}");
      }
      _registerRequests.remove(msg.requestID);

      _registrations[msg.registrationID] = msg.registrationID;

      return msg;
    } else if (msg is Unregistered) {
      if (!_unregisterRequests.containsKey(msg.requestID)) {
        throw ProtocolError("received UNREGISTERED for invalid request ID ${msg.requestID}");
      }
      final registrationID = _unregisterRequests.remove(msg.requestID);

      if (!_registrations.containsKey(registrationID)) {
        throw ProtocolError("received UNREGISTERED for invalid registration ID $registrationID");
      }
      _registrations.remove(registrationID);

      return msg;
    } else if (msg is Invocation) {
      if (!_registrations.containsKey(msg.registrationID)) {
        throw ProtocolError("received INVOCATION for invalid registration ID ${msg.registrationID}");
      }
      _invocationRequests[msg.requestID] = msg.requestID;

      return msg;
    } else if (msg is Published) {
      if (!_publishRequests.containsKey(msg.requestID)) {
        throw ProtocolError("received PUBLISHED for invalid request ID ${msg.requestID}");
      }
      _publishRequests.remove(msg.requestID);

      return msg;
    } else if (msg is Subscribed) {
      if (!_subscribeRequests.containsKey(msg.requestID)) {
        throw ProtocolError("received SUBSCRIBED for invalid request ID ${msg.requestID}");
      }
      _subscribeRequests.remove(msg.requestID);

      _subscriptions[msg.subscriptionID] = msg.subscriptionID;

      return msg;
    } else if (msg is Unsubscribed) {
      if (!_unsubscribeRequests.containsKey(msg.requestID)) {
        throw ProtocolError("received UNSUBSCRIBED for invalid request ID ${msg.requestID}");
      }
      final subscriptionID = _unsubscribeRequests.remove(msg.requestID);

      if (!_subscriptions.containsKey(subscriptionID)) {
        throw ProtocolError("received UNSUBSCRIBED for invalid subscription ID $subscriptionID");
      }
      _subscriptions.remove(subscriptionID);

      return msg;
    } else if (msg is Event) {
      if (!_subscriptions.containsKey(msg.subscriptionID)) {
        throw ProtocolError("received EVENT for invalid subscription ID ${msg.subscriptionID}");
      }

      return msg;
    } else if (msg is Error) {
      switch (msg.msgType) {
        case Call.id:
          if (!_callRequests.containsKey(msg.requestID)) {
            throw ProtocolError("received ERROR for invalid call request");
          }

          _callRequests.remove(msg.requestID);
          break;

        case Register.id:
          if (!_registerRequests.containsKey(msg.requestID)) {
            throw ProtocolError("received ERROR for invalid register request");
          }

          _registerRequests.remove(msg.requestID);
          break;

        case Unregister.id:
          if (!_unregisterRequests.containsKey(msg.requestID)) {
            throw ProtocolError("received ERROR for invalid unregister request");
          }

          _unregisterRequests.remove(msg.requestID);
          break;

        case Subscribe.id:
          if (!_subscribeRequests.containsKey(msg.requestID)) {
            throw ProtocolError("received ERROR for invalid subscribe request");
          }

          _subscribeRequests.remove(msg.requestID);
          break;

        case Unsubscribe.id:
          if (!_unsubscribeRequests.containsKey(msg.requestID)) {
            throw ProtocolError("received ERROR for invalid unsubscribe request");
          }

          _unsubscribeRequests.remove(msg.requestID);
          break;

        case Publish.id:
          if (!_publishRequests.containsKey(msg.requestID)) {
            throw ProtocolError("received ERROR for invalid publish request");
          }

          _publishRequests.remove(msg.requestID);
          break;

        default:
          throw ProtocolError("unknown error message type ${msg.runtimeType}");
      }

      return msg;
    } else if (msg is Goodbye) {
      return msg;
    }

    throw ProtocolError("unknown message ${msg.runtimeType}");
  }
}
