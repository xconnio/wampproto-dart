import "package:wampproto/messages.dart";
import "package:wampproto/serializers.dart";
import "package:wampproto/src/dealer.dart";
import "package:wampproto/src/exception.dart";

class WAMPSession {
  WAMPSession({Serializer? serializer}) : _serializer = serializer ?? JSONSerializer();

  final Serializer _serializer;

  // data structures for RPC
  final Set<int> _callRequests = {};
  final Set<int> _registerRequests = {};
  final Set<int> _registrations = {};
  final Set<int> _invocationRequests = {};
  final Map<int, int> _unregisterRequests = {};

  // data structures for PubSub
  final Set<int> _publishRequests = {};
  final Set<int> _subscribeRequests = {};
  final Set<int> _subscriptions = {};
  final Map<int, int> _unsubscribeRequests = {};

  Object sendMessage(Message msg) {
    if (msg is Call) {
      _callRequests.add(msg.requestID);

      return _serializer.serialize(msg);
    } else if (msg is Register) {
      _registerRequests.add(msg.requestID);

      return _serializer.serialize(msg);
    } else if (msg is Unregister) {
      _unregisterRequests[msg.requestID] = msg.registrationID;

      return _serializer.serialize(msg);
    } else if (msg is Yield) {
      if (!_invocationRequests.contains(msg.requestID)) {
        throw ArgumentError("cannot yield for unknown invocation request");
      }
      bool progress = msg.options[optionProgress] ?? false;
      if (!progress) {
        _invocationRequests.remove(msg.requestID);
      }

      return _serializer.serialize(msg);
    } else if (msg is Publish) {
      if (msg.options.containsKey("acknowledge") && msg.options["acknowledge"]) {
        _publishRequests.add(msg.requestID);
      }

      return _serializer.serialize(msg);
    } else if (msg is Subscribe) {
      _subscribeRequests.add(msg.requestID);

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
      if (!_callRequests.contains(msg.requestID)) {
        throw ProtocolError("received RESULT for invalid request ID ${msg.requestID}");
      }
      bool progress = msg.details["progress"] ?? false;
      if (!progress) {
        _callRequests.remove(msg.requestID);
      }
      return msg;
    } else if (msg is Registered) {
      if (!_registerRequests.contains(msg.requestID)) {
        throw ProtocolError("received REGISTERED for invalid request ID ${msg.requestID}");
      }
      _registerRequests.remove(msg.requestID);

      _registrations.add(msg.registrationID);

      return msg;
    } else if (msg is Unregistered) {
      if (!_unregisterRequests.containsKey(msg.requestID)) {
        throw ProtocolError("received UNREGISTERED for invalid request ID ${msg.requestID}");
      }
      final registrationID = _unregisterRequests.remove(msg.requestID);

      if (!_registrations.contains(registrationID)) {
        throw ProtocolError("received UNREGISTERED for invalid registration ID $registrationID");
      }
      _registrations.remove(registrationID);

      return msg;
    } else if (msg is Invocation) {
      if (!_registrations.contains(msg.registrationID)) {
        throw ProtocolError("received INVOCATION for invalid registration ID ${msg.registrationID}");
      }
      _invocationRequests.add(msg.requestID);

      return msg;
    } else if (msg is Published) {
      if (!_publishRequests.contains(msg.requestID)) {
        throw ProtocolError("received PUBLISHED for invalid request ID ${msg.requestID}");
      }
      _publishRequests.remove(msg.requestID);

      return msg;
    } else if (msg is Subscribed) {
      if (!_subscribeRequests.contains(msg.requestID)) {
        throw ProtocolError("received SUBSCRIBED for invalid request ID ${msg.requestID}");
      }
      _subscribeRequests.remove(msg.requestID);

      _subscriptions.add(msg.subscriptionID);

      return msg;
    } else if (msg is Unsubscribed) {
      if (!_unsubscribeRequests.containsKey(msg.requestID)) {
        throw ProtocolError("received UNSUBSCRIBED for invalid request ID ${msg.requestID}");
      }
      final subscriptionID = _unsubscribeRequests.remove(msg.requestID);

      if (!_subscriptions.contains(subscriptionID)) {
        throw ProtocolError("received UNSUBSCRIBED for invalid subscription ID $subscriptionID");
      }
      _subscriptions.remove(subscriptionID);

      return msg;
    } else if (msg is Event) {
      if (!_subscriptions.contains(msg.subscriptionID)) {
        throw ProtocolError("received EVENT for invalid subscription ID ${msg.subscriptionID}");
      }

      return msg;
    } else if (msg is Error) {
      switch (msg.msgType) {
        case Call.id:
          if (!_callRequests.contains(msg.requestID)) {
            throw ProtocolError("received ERROR for invalid call request");
          }

          _callRequests.remove(msg.requestID);
          break;

        case Register.id:
          if (!_registerRequests.contains(msg.requestID)) {
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
          if (!_subscribeRequests.contains(msg.requestID)) {
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
          if (!_publishRequests.contains(msg.requestID)) {
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
