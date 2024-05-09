import "package:test/test.dart";

import "package:wampproto/broker.dart";
import "package:wampproto/messages.dart";

void main() {
  group("Broker", () {
    final Broker broker = Broker();
    const topicName = "io.xconn.test";

    test("add and remove session", () {
      broker.addSession(1);

      // adding duplicate session should throw an exception
      expect(() => broker.addSession(1), throwsException);

      broker.removeSession(1);

      // removing non-existing session should throw an exception
      expect(() => broker.removeSession(3), throwsException);
    });

    test("subscribing to a topic", () {
      broker.addSession(1);

      var subscribe = Subscribe(1, topicName);
      var messagesWithRecipient = broker.receiveMessage(1, subscribe);
      expect(messagesWithRecipient!.length, 1);
      expect(messagesWithRecipient[0].recipient, 1);
      expect(messagesWithRecipient[0].message, isA<Subscribed>());

      // check subscription by topic
      var hasSubscription = broker.hasSubscriptions(topicName);
      expect(hasSubscription, isTrue);

      // subscribe with invalid sessionID
      expect(() => broker.receiveMessage(2, subscribe), throwsException);
    });

    test("unsubscribing from a topic", () {
      var unSubscribe = UnSubscribe(1, 1);
      var messagesWithRecipient = broker.receiveMessage(1, unSubscribe);
      expect(messagesWithRecipient!.length, 1);
      expect(messagesWithRecipient[0].recipient, 1);
      expect(messagesWithRecipient[0].message, isA<UnSubscribed>());

      // check subscription by topic
      var hasSubscription = broker.hasSubscriptions(topicName);
      expect(hasSubscription, isFalse);

      // unsubscribe with invalid sessionID
      expect(() => broker.receiveMessage(2, unSubscribe), throwsException);

      // unsubscribe with invalid subscriptionID
      var invalidUnSubscribe = UnSubscribe(1, 2);
      expect(() => broker.receiveMessage(1, invalidUnSubscribe), throwsException);

      // unsubscribe with non-existing subscriptionID
      expect(() => broker.receiveMessage(1, unSubscribe), throwsException);
    });

    test("publishing to a topic", () {
      var subscribe = Subscribe(1, topicName);
      broker.receiveMessage(1, subscribe);

      var publish = Publish(1, topicName, args: [1, 2, 3]);
      var messagesWithRecipient = broker.receiveMessage(1, publish);
      expect(messagesWithRecipient!.length, 1);
      expect(messagesWithRecipient[0].recipient, 1);
      expect(messagesWithRecipient[0].message, isA<Event>());

      // publish message to a topic with no subscribers
      var publishNoSubscriber = Publish(2, "topic1", args: [1, 2, 3]);
      var messages = broker.receiveMessage(1, publishNoSubscriber);
      expect(messages, isNull);

      // publish message to invalid sessionID
      expect(() => broker.receiveMessage(3, publish), throwsException);
    });

    test("receive invalid message", () {
      var call = Call(1, topicName);
      expect(() => broker.receiveMessage(1, call), throwsException);
    });
  });
}
