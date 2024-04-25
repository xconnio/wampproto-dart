import "package:wampproto/idgen.dart";
import "package:wampproto/messages.dart";
import "package:wampproto/src/types.dart";

class Broker {
  Map<String, Map<int, int>> subscriptionsByTopic = {};
  Map<int, Map<int, String>> subscriptionsBySession = {};
  SessionScopeIDGenerator idGen = SessionScopeIDGenerator();

  void addSession(int sid) {
    if (subscriptionsBySession.containsKey(sid)) {
      throw Exception("cannot add session twice");
    }

    subscriptionsBySession[sid] = {};
  }

  void removeSession(int sid) {
    var subscriptions = subscriptionsBySession.remove(sid);
    if (subscriptions == null) {
      throw Exception("cannot remove non-existing session");
    }

    subscriptions.forEach((key, value) {
      if (subscriptionsByTopic.containsKey(value)) {
        subscriptionsByTopic[value]?.remove(key);
        if (subscriptionsByTopic[value]?.isEmpty ?? false) {
          subscriptionsByTopic.remove(value);
        }
      }
    });
  }

  bool hasSubscriptions(String topic) {
    return subscriptionsByTopic[topic]?.isNotEmpty ?? false;
  }

  List<MessageWithRecipient>? receiveMessage(int sessionID, Message message) {
    if (message is Subscribe) {
      if (!subscriptionsBySession.containsKey(sessionID)) {
        throw Exception("cannot subscribe, session $sessionID doesn't exist");
      }

      int subscriptionID = idGen.next();
      subscriptionsBySession.putIfAbsent(sessionID, () => {})[subscriptionID] = message.topic;
      subscriptionsByTopic.putIfAbsent(message.topic, () => {})[subscriptionID] = sessionID;

      Subscribed subscribed = Subscribed(message.requestID, subscriptionID);
      return [MessageWithRecipient(subscribed, sessionID)];
    } else if (message is UnSubscribe) {
      if (!subscriptionsBySession.containsKey(sessionID)) {
        throw Exception("cannot unsubscribe, session $sessionID doesn't exist");
      }

      var subscriptions = subscriptionsBySession[sessionID];
      if (subscriptions == null) {
        throw Exception("cannot unsubscribe, no subscription found");
      }

      String? topic = subscriptions[message.subscriptionID];
      if (topic == null) {
        throw Exception("cannot unsubscribe, subscription $message.subscriptionID doesn't exist");
      }

      subscriptionsBySession[sessionID]?.remove(message.subscriptionID);
      subscriptionsByTopic[topic]?.remove(message.subscriptionID);

      UnSubscribed unSubscribed = UnSubscribed(message.requestID);
      return [MessageWithRecipient(unSubscribed, sessionID)];
    } else if (message is Publish) {
      if (!subscriptionsBySession.containsKey(sessionID)) {
        throw Exception("cannot publish, session $sessionID doesn't exist");
      }

      var subscriptions = subscriptionsByTopic[message.uri];
      if (subscriptions == null) {
        return null;
      }

      int publicationID = idGen.next();
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
