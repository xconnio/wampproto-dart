import "package:wampproto/idgen.dart";
import "package:wampproto/messages.dart";
import "package:wampproto/src/types.dart";

class Broker {
  final Map<String, Map<int, int>> _subscriptionsByTopic = {};
  final Map<int, Map<int, String>> _subscriptionsBySession = {};
  final _idGen = SessionScopeIDGenerator();

  void addSession(int sid) {
    if (_subscriptionsBySession.containsKey(sid)) {
      throw Exception("cannot add session twice");
    }

    _subscriptionsBySession[sid] = {};
  }

  void removeSession(int sid) {
    var subscriptions = _subscriptionsBySession.remove(sid);
    if (subscriptions == null) {
      throw Exception("cannot remove non-existing session");
    }

    subscriptions.forEach((key, value) {
      if (_subscriptionsByTopic.containsKey(value)) {
        _subscriptionsByTopic[value]?.remove(key);
        if (_subscriptionsByTopic[value]?.isEmpty ?? false) {
          _subscriptionsByTopic.remove(value);
        }
      }
    });
  }

  bool hasSubscriptions(String topic) {
    return _subscriptionsByTopic[topic]?.isNotEmpty ?? false;
  }

  List<MessageWithRecipient>? receiveMessage(int sessionID, Message message) {
    if (message is Subscribe) {
      if (!_subscriptionsBySession.containsKey(sessionID)) {
        throw Exception("cannot subscribe, session $sessionID doesn't exist");
      }

      int subscriptionID = _idGen.next();
      _subscriptionsBySession.putIfAbsent(sessionID, () => {})[subscriptionID] = message.topic;
      _subscriptionsByTopic.putIfAbsent(message.topic, () => {})[subscriptionID] = sessionID;

      Subscribed subscribed = Subscribed(message.requestID, subscriptionID);
      return [MessageWithRecipient(subscribed, sessionID)];
    } else if (message is UnSubscribe) {
      if (!_subscriptionsBySession.containsKey(sessionID)) {
        throw Exception("cannot unsubscribe, session $sessionID doesn't exist");
      }

      var subscriptions = _subscriptionsBySession[sessionID];
      if (subscriptions == null) {
        throw Exception("cannot unsubscribe, no subscription found");
      }

      String? topic = subscriptions[message.subscriptionID];
      if (topic == null) {
        throw Exception("cannot unsubscribe, subscription $message.subscriptionID doesn't exist");
      }

      _subscriptionsBySession[sessionID]?.remove(message.subscriptionID);
      _subscriptionsByTopic[topic]?.remove(message.subscriptionID);

      UnSubscribed unSubscribed = UnSubscribed(message.requestID);
      return [MessageWithRecipient(unSubscribed, sessionID)];
    } else if (message is Publish) {
      if (!_subscriptionsBySession.containsKey(sessionID)) {
        throw Exception("cannot publish, session $sessionID doesn't exist");
      }

      var subscriptions = _subscriptionsByTopic[message.uri];
      if (subscriptions == null) {
        return null;
      }

      int publicationID = _idGen.next();
      List<MessageWithRecipient> result = [];

      subscriptions.forEach((subscriptionID, recipientID) {
        Event event = Event(subscriptionID, publicationID, args: message.args, kwargs: message.kwargs);
        result.add(MessageWithRecipient(event, recipientID));
      });

      return result;
    } else {
      throw Exception("message type not supported");
    }
  }
}
