import "dart:convert";

import "package:test/test.dart";

import "package:wampproto/messages.dart";
import "package:wampproto/serializers.dart";
import "package:wampproto/session.dart";
import "package:wampproto/src/uris.dart";

void main() {
  Serializer serializer = JSONSerializer();
  final session = WAMPSession(serializer: serializer);

  group("sendMessage & receiveMessage", () {
    test("send Register message and receive Registered message", () {
      final register = Register(2, "io.xconn.test");
      var toSend = session.sendMessage(register);
      expect(toSend, '[${Register.id},${register.requestID},${register.options},"${register.uri}"]');

      final registered = Registered(2, 3);
      var received = session.receiveMessage(registered);
      expect(received, equals(registered));
    });

    test("send Call message and receive Result", () {
      final call = Call(10, "io.xconn.test");
      var toSend = session.sendMessage(call);
      expect(toSend, '[${Call.id},${call.requestID},${call.options},"${call.uri}"]');

      final result = Result(10);
      var received = session.receiveMessage(result);
      expect(received, equals(result));
    });

    test("receive Invocation and send Yield for that invocation", () {
      final invocation = Invocation(4, 3);
      var toSend = session.receiveMessage(invocation);
      expect(toSend, equals(invocation));

      final yield = Yield(4);
      var received = session.sendMessage(yield);
      expect(received, "[70,4,{}]");
    });

    test("send UnRegister message and receive UnRegistered message", () {
      final unregister = UnRegister(3, 3);
      var toSend = session.sendMessage(unregister);
      expect(toSend, "[${UnRegister.id},${unregister.requestID},${unregister.registrationID}]");

      final unregistered = UnRegistered(3);
      var received = session.receiveMessage(unregistered);
      expect(received, equals(unregistered));
    });

    test("send Publish message with acknowledge true and receive Published message", () {
      final publish = Publish(6, "topic", options: {"acknowledge": true});
      var toSend = session.sendMessage(publish);
      expect(toSend, '[${Publish.id},${publish.requestID},${jsonEncode(publish.options)},"${publish.uri}"]');

      final published = Published(6, 6);
      var received = session.receiveMessage(published);
      expect(received, equals(published));
    });

    test("send Subscribe message, receive Subscribed message and receive Event for subscription", () {
      final subscribe = Subscribe(SubscribeFields(7, "topic"));
      var toSend = session.sendMessage(subscribe);
      expect(toSend, '[${Subscribe.id},${subscribe.requestID},${subscribe.options},"${subscribe.topic}"]');

      final subscribed = Subscribed(SubscribedFields(7, 8));
      var received = session.receiveMessage(subscribed);
      expect(received, equals(subscribed));

      final event = Event(8, 6);
      var receivedEvent = session.receiveMessage(event);
      expect(receivedEvent, equals(event));
    });

    test("send UnSubscribe message and receive UnSubscribed message", () {
      final unsubscribe = UnSubscribe(UnSubscribeFields(8, 8));
      var toSend = session.sendMessage(unsubscribe);
      expect(toSend, "[${UnSubscribe.id},${unsubscribe.requestID},${unsubscribe.subscriptionID}]");

      final unsubscribed = UnSubscribed(UnSubscribedFields(8));
      var received = session.receiveMessage(unsubscribed);
      expect(received, equals(unsubscribed));
    });
  });

  test("send error message correctly", () {
    final error = Error(Invocation.id, 10, errProcedureAlreadyExists);
    var toSend = session.sendMessage(error);
    expect(toSend, '[${Error.id},${Invocation.id},${error.requestID},${error.details},"${error.uri}"]');
  });

  group("receive error message correctly", () {
    test("send Call message and receive Error for that Call", () {
      final call = Call(1, "io.xconn.test");
      session.sendMessage(call);

      final callErr = Error(Call.id, call.requestID, errInvalidArgument);
      var received = session.receiveMessage(callErr);
      expect(received, callErr);
    });

    test("send Register message and receive Error for that Register", () {
      final register = Register(2, "io.xconn.test");
      session.sendMessage(register);

      final registerErr = Error(Register.id, register.requestID, errInvalidArgument);
      var received = session.receiveMessage(registerErr);
      expect(received, registerErr);
    });

    test("send UnRegister message and receive Error for that UnRegister", () {
      final unregister = UnRegister(3, 3);
      session.sendMessage(unregister);

      final unregisterErr = Error(UnRegister.id, unregister.requestID, errInvalidArgument);
      var received = session.receiveMessage(unregisterErr);
      expect(received, unregisterErr);
    });

    test("send Subscribe message and receive Error for that Subscribe", () {
      final subscribe = Subscribe(SubscribeFields(7, "topic"));
      session.sendMessage(subscribe);

      final subscribeError = Error(Subscribe.id, subscribe.requestID, errInvalidURI);
      var received = session.receiveMessage(subscribeError);
      expect(received, subscribeError);
    });

    test("send UnSubscribe message and receive Error for that UnSubscribe", () {
      final unsubscribe = UnSubscribe(UnSubscribeFields(8, 8));
      session.sendMessage(unsubscribe);

      final unsubscribeError = Error(UnSubscribe.id, unsubscribe.requestID, errInvalidURI);
      var received = session.receiveMessage(unsubscribeError);
      expect(received, unsubscribeError);
    });

    test("send Publish message and receive Error for that Publish", () {
      final publish = Publish(6, "topic", options: {"acknowledge": true});
      session.sendMessage(publish);

      final publishErr = Error(Publish.id, publish.requestID, errInvalidURI);
      var received = session.receiveMessage(publishErr);
      expect(received, publishErr);
    });
  });

  test("exceptions", () {
    // send Yield for unknown invocation
    final invalidYield = Yield(5);
    expect(() => session.sendMessage(invalidYield), throwsArgumentError);

    // send error for invalid message
    final invalidError = Error(Register.id, 10, errProcedureAlreadyExists);
    expect(() => session.sendMessage(invalidError), throwsArgumentError);

    // send invalid message
    final invalidMessage = Registered(11, 12);
    expect(() => session.sendMessage(invalidMessage), throwsException);

    // receive invalid message
    expect(() => session.receiveMessage(Register(100, "io.xconn.test")), throwsException);

    // receive error for invalid message
    expect(() => session.receiveMessage(Error(Registered.id, 100, errInvalidArgument)), throwsException);

    // receive error invalid Call id
    expect(() => session.receiveMessage(Error(Call.id, 100, errInvalidArgument)), throwsException);

    // receive error Register id
    expect(() => session.receiveMessage(Error(Register.id, 100, errInvalidArgument)), throwsException);

    // receive error invalid UnRegister id
    expect(() => session.receiveMessage(Error(UnRegister.id, 100, errInvalidArgument)), throwsException);

    // receive error invalid Subscribe id
    expect(() => session.receiveMessage(Error(Subscribe.id, 100, errInvalidArgument)), throwsException);

    // receive error invalid UnSubscribe id
    expect(() => session.receiveMessage(Error(UnSubscribe.id, 100, errInvalidArgument)), throwsException);

    // receive error invalid Publish id
    expect(() => session.receiveMessage(Error(Publish.id, 100, errInvalidArgument)), throwsException);
  });
}
