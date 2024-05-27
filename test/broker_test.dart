import "package:test/test.dart";

import "package:wampproto/broker.dart";
import "package:wampproto/messages.dart";
import "package:wampproto/src/messages/call.dart";
import "package:wampproto/src/messages/publish.dart";
import "package:wampproto/src/messages/subscribe.dart";
import "package:wampproto/src/messages/unsubscribe.dart";
import "package:wampproto/src/types.dart";

void main() {
  group("Broker", () {
    final Broker broker = Broker();
    const topicName = "io.xconn.test";

    test("add and remove session", () {
      var details = SessionDetails(1, "realm1", "authid", "authrole");
      broker.addSession(details);

      // adding duplicate session should throw an exception
      expect(() => broker.addSession(details), throwsException);

      broker.removeSession(1);

      // removing non-existing session should throw an exception
      expect(() => broker.removeSession(3), throwsException);
    });

    test("subscribing to a topic", () {
      var details = SessionDetails(1, "realm1", "authid", "authrole");
      broker.addSession(details);

      var subscribe = Subscribe(SubscribeFields(1, topicName));
      var messagesWithRecipient = broker.receiveMessage(1, subscribe);
      expect(messagesWithRecipient!.recipient, 1);
      expect(messagesWithRecipient.message, isA<Subscribed>());

      // check subscription by topic
      var hasSubscription = broker.hasSubscription(topicName);
      expect(hasSubscription, isTrue);

      // subscribe with invalid sessionID
      expect(() => broker.receiveMessage(2, subscribe), throwsException);
    });

    test("unsubscribing from a topic", () {
      var unSubscribe = UnSubscribe(UnSubscribeFields(1, 1));
      var messagesWithRecipient = broker.receiveMessage(1, unSubscribe);
      expect(messagesWithRecipient!.recipient, 1);
      expect(messagesWithRecipient.message, isA<UnSubscribed>());

      // check subscription by topic
      var hasSubscription = broker.hasSubscription(topicName);
      expect(hasSubscription, isFalse);

      // unsubscribe with invalid sessionID
      expect(() => broker.receiveMessage(2, unSubscribe), throwsException);

      // unsubscribe with invalid subscriptionID
      var invalidUnSubscribe = UnSubscribe(UnSubscribeFields(1, 2));
      expect(() => broker.receiveMessage(1, invalidUnSubscribe), throwsException);

      // unsubscribe with non-existing subscriptionID
      expect(() => broker.receiveMessage(1, unSubscribe), throwsException);
    });

    test("publishing to a topic", () {
      var subscribe = Subscribe(SubscribeFields(1, topicName));
      broker.receiveMessage(1, subscribe);

      var publish = Publish(PublishFields(1, topicName, args: [1, 2, 3]));
      var messagesWithRecipient = broker.receivePublish(1, publish);
      expect(messagesWithRecipient.recipients!.length, 1);
      expect(messagesWithRecipient.event, isA<Event>());
      expect(messagesWithRecipient.ack, null);

      // publish message to a topic with no subscribers
      var publishNoSubscriber = Publish(PublishFields(2, "topic1", args: [1, 2, 3]));
      var messages = broker.receivePublish(1, publishNoSubscriber);
      expect(messages.recipients!.length, 0);
      expect(messages.event, null);
      expect(messages.ack, null);

      // publish with acknowledge true
      var publishAcknowledge = Publish(PublishFields(2, topicName, args: [1, 2, 3], options: {"acknowledge": true}));
      var msgWithRecipient = broker.receivePublish(1, publishAcknowledge);
      expect(msgWithRecipient.recipients!.length, 1);
      expect(msgWithRecipient.event, isA<Event>());
      expect(msgWithRecipient.ack, isA<MessageWithRecipient>());

      // publish message to invalid sessionID
      expect(() => broker.receivePublish(5, publish), throwsException);
    });

    test("receive invalid message", () {
      var call = Call(CallFields(1, topicName));
      expect(() => broker.receiveMessage(1, call), throwsException);
    });
  });
}
