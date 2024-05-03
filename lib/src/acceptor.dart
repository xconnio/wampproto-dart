import "dart:math";

import "package:pinenacl/ed25519.dart";
import "package:wampproto/auth.dart";
import "package:wampproto/messages.dart";
import "package:wampproto/serializers.dart";
import "package:wampproto/src/types.dart";

final routerRoles = <String, Map<String, Map>>{
  "dealer": {},
  "broker": {},
};

int getSessionID() {
  return Random().nextInt(1 << 32);
}

class Acceptor {
  Acceptor({Serializer? serializer, IServerAuthenticator? authenticator})
      : _serializer = serializer ?? JSONSerializer(),
        _authenticator = authenticator ?? AnonymousServerAuthenticator();

  static const int stateNone = 0;
  static const int stateHelloReceived = 1;
  static const int stateChallengeSent = 2;
  static const int stateWelcomeSent = 3;
  static const int stateErrored = 4;

  static const String ticket = "ticket";
  static const String wampcra = "wampcra";
  static const String anonymous = "anonymous";
  static const String cryptosign = "cryptosign";

  final Serializer _serializer;
  final IServerAuthenticator _authenticator;
  int _state = stateNone;
  final int _sessionID = getSessionID();

  late String _authMethod;
  late Hello _hello;
  late Response _response;
  SessionDetails? _sessionDetails;

  late String _publicKey;
  late String _challenge;
  late String _secret;

  MapEntry<Uint8List, bool> receive(Uint8List data) {
    final receivedMessage = _serializer.deserialize(data);
    final toSend = receiveMessage(receivedMessage);

    return MapEntry(_serializer.serialize(toSend!), toSend is Welcome);
  }

  Message? receiveMessage(Message msg) {
    if (_state == stateWelcomeSent) {
      throw ArgumentError("session was established, not expecting any new messages");
    }

    if (msg is Hello) {
      if (_state != stateNone) {
        throw Exception("unknown state");
      }

      String method = anonymous;
      if (msg.authMethods.isNotEmpty) {
        method = msg.authMethods[0];
      }

      _authMethod = method;
      _hello = msg;

      switch (method) {
        case anonymous:
          Request request = Request(method, msg.realm, msg.authID, msg.authExtra);
          Response response = _authenticator.authenticate(request);
          _state = stateWelcomeSent;

          Welcome welcome = Welcome(_sessionID, routerRoles, response.authID, response.authRole, method, authExtra: {});
          _sessionDetails = SessionDetails(_sessionID, msg.realm, welcome.authID, welcome.authRole);

          return welcome;

        case cryptosign:
          if (!msg.authExtra.containsKey("pubkey")) {
            throw Exception("authextra must contain pubkey for $cryptosign");
          }

          String publicKey = msg.authExtra["pubkey"];
          CryptoSignRequest request = CryptoSignRequest(msg.realm, msg.authID, msg.authExtra, publicKey);
          _response = _authenticator.authenticate(request);
          _publicKey = publicKey;

          String challenge = generateCryptoSignChallenge();
          _state = stateChallengeSent;

          return Challenge(method, {"challenge": challenge});

        case wampcra:
          Request request = Request(method, msg.realm, msg.authID, msg.authExtra);
          Response response = _authenticator.authenticate(request);
          if (response is! WAMPCRAResponse) {
            throw Exception("invalid response type for WAMPCRA");
          }

          _response = response;
          _secret = response.secret;

          String challenge = generateWampCRAChallenge(_sessionID, _response.authID, _response.authRole, "dynamic");
          _state = stateChallengeSent;
          _challenge = challenge;

          return Challenge(method, {"challenge": challenge});

        case ticket:
          _state = stateChallengeSent;

          return Challenge(method, {});

        default:
          throw Exception("unknown method");
      }
    } else if (msg is Authenticate) {
      if (_state != stateChallengeSent) {
        throw Exception("unknown state");
      }

      switch (_authMethod) {
        case cryptosign:
          verifyCryptoSignSignature(msg.signature, Base16Encoder.instance.decode(_publicKey));
          _state = stateWelcomeSent;

          Welcome welcome =
              Welcome(_sessionID, routerRoles, _response.authID, _response.authRole, cryptosign, authExtra: {});
          _sessionDetails = SessionDetails(welcome.sessionID, _hello.realm, welcome.authID, welcome.authRole);

          return welcome;

        case wampcra:
          verifyWampCRASignature(msg.signature, _challenge, Base16Encoder.instance.decode(_secret));
          _state = stateWelcomeSent;

          Welcome welcome =
              Welcome(_sessionID, routerRoles, _response.authID, _response.authRole, wampcra, authExtra: {});
          _sessionDetails = SessionDetails(welcome.sessionID, _hello.realm, welcome.authID, welcome.authRole);

          return welcome;

        case ticket:
          TicketRequest request = TicketRequest(_hello.realm, _hello.authID, _hello.authExtra, msg.signature);
          Response response = _authenticator.authenticate(request);
          _state = stateWelcomeSent;

          Welcome welcome = Welcome(_sessionID, routerRoles, response.authID, response.authRole, ticket, authExtra: {});
          _sessionDetails = SessionDetails(welcome.sessionID, _hello.realm, welcome.authID, welcome.authRole);

          return welcome;
      }
    } else if (msg is Abort) {
      _state = stateErrored;

      return null;
    } else {
      throw Exception("unknown message");
    }

    return null;
  }

  SessionDetails getSessionDetails() {
    if (_sessionDetails == null) {
      throw Exception("session is not setup yet");
    }

    return _sessionDetails!;
  }
}
