import "package:wampproto/idgen.dart";
import "package:wampproto/messages.dart";
import "package:wampproto/src/types.dart";

class Broker {
  final Map<String, Subscription> _subscriptionsByTopic = {};
  final Map<int, Map<int, Subscription>> _subscriptionsBySession = {};
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
      var subscription = _subscriptionsByTopic[value.topic];
      if (subscription != null) {
        if (subscription.subscribers.containsKey(sid)) {
          subscription.subscribers.remove(sid);
        }

        if (subscription.subscribers.isEmpty) {
          _subscriptionsByTopic.remove(subscription.topic);
        }
      }
    });
  }

  bool hasSubscription(String topic) {
    return _subscriptionsByTopic.containsKey(topic);
  }

  MessageWithRecipient? receiveMessage(int sessionID, Message message) {
    if (message is Subscribe) {
      if (!_subscriptionsBySession.containsKey(sessionID)) {
        throw Exception("cannot subscribe, session $sessionID doesn't exist");
      }

      var subscription = _subscriptionsByTopic[message.topic];
      if (subscription == null) {
        subscription = Subscription(_idGen.next(), message.topic, {sessionID: sessionID});
        _subscriptionsByTopic[message.topic] = subscription;
      } else {
        subscription.subscribers[sessionID] = sessionID;
      }

      _subscriptionsBySession.putIfAbsent(sessionID, () => {})[subscription.id] = subscription;

      Subscribed subscribed = Subscribed(message.requestID, subscription.id);
      return MessageWithRecipient(subscribed, sessionID);
    } else if (message is UnSubscribe) {
      if (!_subscriptionsBySession.containsKey(sessionID)) {
        throw Exception("cannot unsubscribe, session $sessionID doesn't exist");
      }

      var subscriptions = _subscriptionsBySession[sessionID];
      if (subscriptions == null) {
        throw Exception("cannot unsubscribe, no subscription found");
      }

      var subscription = subscriptions[message.subscriptionID];
      if (subscription == null) {
        throw Exception("cannot unsubscribe, subscription $message.subscriptionID doesn't exist");
      }
      subscription.subscribers.remove(sessionID);
      if (subscription.subscribers.isEmpty) {
        _subscriptionsByTopic.remove(subscription.topic);
      }

      _subscriptionsBySession[sessionID]?.remove(message.subscriptionID);

      UnSubscribed unSubscribed = UnSubscribed(message.requestID);
      return MessageWithRecipient(unSubscribed, sessionID);
    } else {
      throw Exception("message type not supported");
    }
  }

  Publication receivePublish(int sessionId, Publish message) {
    print(_subscriptionsBySession.containsKey(sessionId));
    if (!_subscriptionsBySession.containsKey(sessionId)) {
      throw Exception("Cannot publish, session $sessionId doesn't exist");
    }

    var result = Publication(recipients: []);
    var publicationId = _idGen.next();

    var subscription = _subscriptionsByTopic[message.uri];
    if (subscription != null) {
      var event = Event(subscription.id, publicationId, args: message.args, kwargs: message.kwargs);
      result.event = event;
      result.recipients!.addAll(subscription.subscribers.keys);
    }

    var ack = message.options["acknowledge"] ?? false;
    if (ack) {
      var published = Published(message.requestID, publicationId);
      result.ack = MessageWithRecipient(published, sessionId);
    }

    return result;
  }
}
