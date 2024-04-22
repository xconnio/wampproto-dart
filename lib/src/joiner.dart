import "dart:typed_data";
import "package:wampproto/auth.dart";
import "package:wampproto/messages.dart";
import "package:wampproto/serializers.dart";
import "package:wampproto/src/auth/auth.dart";
import "package:wampproto/src/serializers/serializer.dart";
import "package:wampproto/src/types.dart";

final clientRoles = <String, Map<String, Map>>{
  "caller": {"features": {}},
  "callee": {"features": {}},
  "publisher": {"features": {}},
  "subscriber": {"features": {}},
};

class Joiner {
  Joiner(this._realm, Serializer? serializer, IClientAuthenticator? authenticator)
      : _serializer = serializer ?? JSONSerializer(),
        _authenticator = authenticator ?? AnonymousAuthenticator("");

  static const int stateNone = 0;
  static const int stateHelloSent = 1;
  static const int stateAuthenticateSent = 2;
  static const int stateJoined = 3;

  final String _realm;
  final Serializer _serializer;
  final IClientAuthenticator _authenticator;
  int _state = stateNone;
  SessionDetails? _sessionDetails;

  Uint8List sendHello() {
    final hello = Hello(
      _realm,
      clientRoles,
      _authenticator.authID,
      [_authenticator.authMethod],
      _authenticator.authExtra,
    );

    _state = stateHelloSent;
    return _serializer.serialize(hello);
  }

  Uint8List? receive(Uint8List data) {
    final receivedMessage = _serializer.deserialize(data);
    final toSend = receiveMessage(receivedMessage);
    if (toSend != null && toSend is Authenticate) {
      return _serializer.serialize(toSend);
    }

    return null;
  }

  Message? receiveMessage(Message msg) {
    if (msg is Welcome) {
      if (_state != stateHelloSent && _state != stateAuthenticateSent) {
        throw Exception("received welcome when it was not expected");
      }

      _sessionDetails = SessionDetails(msg.sessionID, _realm, msg.authID, msg.authRole);
      _state = stateJoined;
      return null;
    } else if (msg is Challenge) {
      if (_state != stateHelloSent) {
        throw Exception("received challenge when it was not expected");
      }

      final authenticate = _authenticator.authenticate(msg);
      _state = stateAuthenticateSent;
      return authenticate;
    } else if (msg is Abort) {
      throw Exception("received abort");
    } else {
      throw Exception("received unknown message");
    }
  }

  SessionDetails getSessionDetails() {
    if (_sessionDetails == null) {
      throw Exception("session is not set up yet");
    }

    return _sessionDetails!;
  }
}
