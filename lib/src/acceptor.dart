import "package:pinenacl/ed25519.dart";
import "package:wampproto/auth.dart";
import "package:wampproto/messages.dart";
import "package:wampproto/serializers.dart";
import "package:wampproto/src/exception.dart";
import "package:wampproto/src/idgen.dart";
import "package:wampproto/src/types.dart";
import "package:wampproto/src/uris.dart";

final routerRoles = <String, Map<String, Map>>{
  "dealer": {},
  "broker": {},
};

class Acceptor {
  Acceptor({Serializer? serializer, IServerAuthenticator? authenticator})
      : _serializer = serializer ?? JSONSerializer(),
        _authenticator = authenticator ?? AnonymousServerAuthenticator();

  static const int stateNone = 0;
  static const int stateHelloReceived = 1;
  static const int stateChallengeSent = 2;
  static const int stateWelcomeSent = 3;
  static const int stateAborted = 4;

  static const String ticket = "ticket";
  static const String wampcra = "wampcra";
  static const String anonymous = "anonymous";
  static const String cryptosign = "cryptosign";

  final Serializer _serializer;
  final IServerAuthenticator _authenticator;
  int _state = stateNone;
  final int _sessionID = generateSessionID();

  late String _authMethod;
  late Hello _hello;
  late Response _response;
  SessionDetails? _sessionDetails;

  late String _publicKey;
  late String _challenge;
  late String _secret;

  MapEntry<Object, bool> receive(Object data) {
    final receivedMessage = _serializer.deserialize(data);
    final toSend = receiveMessage(receivedMessage);

    var isFinal = toSend is Welcome || toSend is Abort;
    return MapEntry(_serializer.serialize(toSend!), isFinal);
  }

  Message? receiveMessage(Message msg) {
    if (_state == stateWelcomeSent) {
      throw ProtocolError("session was established, not expecting any new messages");
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
          AnonymousRequest request = AnonymousRequest(msg.realm, msg.authID, msg.authExtra);
          Response response;
          try {
            response = _authenticator.authenticate(request);
          } on Exception catch (e) {
            return Abort({}, errAuthenticationFailed, args: [e.toString()]);
          } on Error catch (e) {
            return Abort({}, errAuthenticationFailed, args: [e.toString()]);
          }

          _state = stateWelcomeSent;

          Welcome welcome = Welcome(_sessionID, routerRoles, response.authID, response.authRole, method, authExtra: {});
          _sessionDetails = SessionDetails(_sessionID, msg.realm, welcome.authID, welcome.authRole);

          return welcome;

        case cryptosign:
          if (!msg.authExtra.containsKey("pubkey")) {
            throw ProtocolError("authextra must contain pubkey for $cryptosign");
          }

          String publicKey = msg.authExtra["pubkey"];
          CryptoSignRequest request = CryptoSignRequest(msg.realm, msg.authID, msg.authExtra, publicKey);
          try {
            _response = _authenticator.authenticate(request);
          } on Exception catch (e) {
            return Abort({}, errAuthenticationFailed, args: [e.toString()]);
          } on Error catch (e) {
            return Abort({}, errAuthenticationFailed, args: [e.toString()]);
          }

          _publicKey = publicKey;

          String challenge = generateCryptoSignChallenge();
          _state = stateChallengeSent;

          return Challenge(method, {"challenge": challenge});

        case wampcra:
          WAMPCRARequest request = WAMPCRARequest(msg.realm, msg.authID, msg.authExtra);
          Response response;
          try {
            response = _authenticator.authenticate(request);
          } on Exception catch (e) {
            return Abort({}, errAuthenticationFailed, args: [e.toString()]);
          } on Error catch (e) {
            return Abort({}, errAuthenticationFailed, args: [e.toString()]);
          }

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
          throw ProtocolError("unknown auth method '$method'");
      }
    } else if (msg is Authenticate) {
      if (_state != stateChallengeSent) {
        throw Exception("unknown state");
      }

      switch (_authMethod) {
        case cryptosign:
          var isVerified = verifyCryptoSignSignature(msg.signature, Base16Encoder.instance.decode(_publicKey));
          if (!isVerified) {
            _state = stateAborted;
            return Abort({}, errAuthenticationFailed);
          }
          _state = stateWelcomeSent;

          Welcome welcome =
              Welcome(_sessionID, routerRoles, _response.authID, _response.authRole, cryptosign, authExtra: {});
          _sessionDetails = SessionDetails(welcome.sessionID, _hello.realm, welcome.authID, welcome.authRole);

          return welcome;

        case wampcra:
          var isVerified = verifyWampCRASignature(msg.signature, _challenge, Uint8List.fromList(_secret.codeUnits));
          if (!isVerified) {
            _state = stateAborted;
            return Abort({}, errAuthenticationFailed);
          }
          _state = stateWelcomeSent;

          Welcome welcome =
              Welcome(_sessionID, routerRoles, _response.authID, _response.authRole, wampcra, authExtra: {});
          _sessionDetails = SessionDetails(welcome.sessionID, _hello.realm, welcome.authID, welcome.authRole);

          return welcome;

        case ticket:
          TicketRequest request = TicketRequest(_hello.realm, _hello.authID, _hello.authExtra, msg.signature);
          Response response;
          try {
            response = _authenticator.authenticate(request);
          } on Exception catch (e) {
            return Abort({}, errAuthenticationFailed, args: [e.toString()]);
          } on Error catch (e) {
            return Abort({}, errAuthenticationFailed, args: [e.toString()]);
          }

          _state = stateWelcomeSent;

          Welcome welcome = Welcome(_sessionID, routerRoles, response.authID, response.authRole, ticket, authExtra: {});
          _sessionDetails = SessionDetails(welcome.sessionID, _hello.realm, welcome.authID, welcome.authRole);

          return welcome;
      }
    } else if (msg is Abort) {
      _state = stateAborted;

      return null;
    } else {
      throw ProtocolError("received ${msg.runtimeType} message and session is not established yet");
    }

    return null;
  }

  bool isAborted() {
    return _state == stateAborted;
  }

  SessionDetails getSessionDetails() {
    if (_sessionDetails == null) {
      throw SessionNotReady("session is not setup yet");
    }

    return _sessionDetails!;
  }
}
