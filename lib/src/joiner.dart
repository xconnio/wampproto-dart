import "package:wampproto/auth.dart";
import "package:wampproto/messages.dart";
import "package:wampproto/serializers.dart";
import "package:wampproto/src/exception.dart";
import "package:wampproto/src/types.dart";

final clientRoles = <String, Map<String, Map>>{
  "caller": {"features": {}},
  "callee": {"features": {}},
  "publisher": {"features": {}},
  "subscriber": {"features": {}},
};

class Joiner {
  Joiner(this._realm, {Serializer? serializer, IClientAuthenticator? authenticator})
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

  Object sendHello() {
    final hello = Hello(
      _realm,
      clientRoles,
      _authenticator.authID,
      [_authenticator.authMethod],
      authExtra: _authenticator.authExtra,
    );

    _state = stateHelloSent;
    return _serializer.serialize(hello);
  }

  Object? receive(Object data) {
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
        throw ProtocolError("received welcome when it was not expected");
      }

      _sessionDetails = SessionDetails(msg.sessionID, _realm, msg.authID, msg.authRole);
      _state = stateJoined;
      return null;
    } else if (msg is Challenge) {
      if (_state != stateHelloSent) {
        throw ProtocolError("received challenge when it was not expected");
      }

      final authenticate = _authenticator.authenticate(msg);
      _state = stateAuthenticateSent;
      return authenticate;
    } else if (msg is Abort) {
      throw ApplicationError(msg.reason, args: msg.args, kwargs: msg.kwargs);
    } else {
      throw ProtocolError("received ${msg.runtimeType} message and session is not established yet");
    }
  }

  SessionDetails getSessionDetails() {
    if (_sessionDetails == null) {
      throw SessionNotReady("session is not set up yet");
    }

    return _sessionDetails!;
  }
}
