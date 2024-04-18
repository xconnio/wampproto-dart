import "dart:typed_data";
import "package:wampproto/auth.dart";
import "package:wampproto/messages.dart";
import "package:wampproto/serializers.dart";
import "package:wampproto/src/auth/auth.dart";
import "package:wampproto/src/messages/message.dart";
import "package:wampproto/src/serializers/serializer.dart";
import "package:wampproto/src/types.dart";

final clientRoles = <String, Map<String, Map>>{
  "caller": {"features": {}},
  "callee": {"features": {}},
  "publisher": {"features": {}},
  "subscriber": {"features": {}},
};

class Joiner {
  Joiner(this.realm, Serializer? serializer, IClientAuthenticator? authenticator)
      : serializer = serializer ?? JSONSerializer(),
        authenticator = authenticator ?? AnonymousAuthenticator("");

  static const int stateNone = 0;
  static const int stateHelloSent = 1;
  static const int stateAuthenticateSent = 2;
  static const int stateJoined = 3;

  final String realm;
  final Serializer serializer;
  final IClientAuthenticator authenticator;
  int state = stateNone;
  SessionDetails? sessionDetails;

  Uint8List sendHello() {
    final hello = Hello(realm, clientRoles, authenticator.authID, [authenticator.authMethod], authenticator.authExtra);

    state = stateHelloSent;
    return serializer.serialize(hello);
  }

  Uint8List? receive(Uint8List data) {
    final receivedMessage = serializer.deserialize(data);
    final toSend = receiveMessage(receivedMessage);
    if (toSend != null && toSend is Authenticate) {
      return serializer.serialize(toSend);
    }

    return null;
  }

  Message? receiveMessage(Message msg) {
    if (msg is Welcome) {
      if (state != stateHelloSent && state != stateAuthenticateSent) {
        throw Exception("received welcome when it was not expected");
      }

      sessionDetails = SessionDetails(msg.sessionID, realm, msg.authID, msg.authRole);
      state = stateJoined;
      return null;
    } else if (msg is Challenge) {
      if (state != stateHelloSent) {
        throw Exception("received challenge when it was not expected");
      }

      final authenticate = authenticator.authenticate(msg);
      state = stateAuthenticateSent;
      return authenticate;
    } else if (msg is Abort) {
      throw Exception("received abort");
    } else {
      throw Exception("received unknown message");
    }
  }

  SessionDetails getSessionDetails() {
    if (sessionDetails == null) {
      throw Exception("session is not set up yet");
    }

    return sessionDetails!;
  }
}
