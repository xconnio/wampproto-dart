import "package:test/test.dart";

import "package:wampproto/acceptor.dart";
import "package:wampproto/auth.dart";
import "package:wampproto/joiner.dart";
import "package:wampproto/messages.dart";
import "package:wampproto/serializers.dart";

const realm = "realm1";
const authID = "foo";
const ticket = "fooTicket";
const secret = "barSecret";
const privateKey = "175604dcce3944595dad640da1676d5e1e1a3950f872f177b1269981140f1c5d";
const publicKey = "8096cadfd3af87662d4c6589605801c1e2841c4e2cf3d6c30fb187c09c76c5ac";
final authenticator = Authenticator();

// Custom authenticator implementation
class Authenticator extends IServerAuthenticator {
  @override
  Response authenticate(Request request) {
    if (request is AnonymousRequest) {
      if (request.realm == realm && request.authID == authID) {
        return Response(request.authID, "anonymous");
      }

      throw Exception("invalid realm");
    } else if (request is TicketRequest) {
      if (request.ticket == ticket) {
        return Response(request.authID, "anonymous");
      }

      throw Exception("invalid ticket");
    } else if (request is WAMPCRARequest) {
      if (request.realm == realm && request.authID == authID) {
        return WAMPCRAResponse(request.authID, "anonymous", secret);
      }

      throw Exception("invalid authID");
    } else if (request is CryptoSignRequest) {
      if (request.publicKey == publicKey) {
        return Response(request.authID, "anonymous");
      }

      throw Exception("unknown publikey");
    }
    throw Exception("invalid auth method");
  }

  @override
  List<String> methods() => ["cryptosign", "ticket", "wampcra", "anonymous"];
}

void main() {
  group("Authentication Tests", () {
    test("AnonymousAuth", () {
      // Setup for anonymous authentication test
      var anonymousAuthenticator = AnonymousAuthenticator(authID);
      final serializer = JSONSerializer();
      final joiner = Joiner(realm, serializer: serializer, authenticator: anonymousAuthenticator);
      final acceptor = Acceptor(serializer: serializer, authenticator: authenticator);

      final hello = joiner.sendHello();

      // Process and verify the HELLO message
      final welcomeMap = acceptor.receive(hello);
      final welcome = serializer.deserialize(welcomeMap.key);

      expect(welcome, isA<Welcome>());
      expect(welcomeMap.value, true);

      // Ensure no additional messages are received
      final payload = joiner.receive(welcomeMap.key);
      expect(payload, null);

      // Verify session details are available
      final sessionDetails = joiner.getSessionDetails();
      expect(sessionDetails, isNotNull);
    });

    test("TicketAuth", () {
      var ticketAuthenticator = TicketAuthenticator(ticket, authID);
      testAuth(ticketAuthenticator);
    });

    test("TicketAuthInvalidTicket", () {
      var ticketAuthenticator = TicketAuthenticator("invalid", authID);
      expect(() => testAuth(ticketAuthenticator), throwsException);
    });

    test("CRAAuth", () {
      var craAuthenticator = WAMPCRAAuthenticator(secret, authID, {"challenge": "test"});
      testAuth(craAuthenticator);
    });

    test("CRAAuthInvalidSecret", () {
      var craAuthenticator = WAMPCRAAuthenticator("invalid", authID, {"challenge": "test"});
      expect(() => testAuth(craAuthenticator), throwsException);
    });

    test("CRAAuthInvalidAuthID", () {
      var craAuthenticator = WAMPCRAAuthenticator(secret, "invalid", {"challenge": "test"});
      expect(() => testAuth(craAuthenticator), throwsException);
    });

    test("CryptoSignAuth", () {
      var cryptoSignAuthenticator = CryptoSignAuthenticator(authID, privateKey);
      testAuth(cryptoSignAuthenticator);
    });

    test("CryptoSignAuthInvalidKey", () {
      var cryptoSignAuthenticator =
          CryptoSignAuthenticator(authID, "2e9bef98114241d2226996cf09faf87dad892643a7c5fde186783470bce21df3");
      expect(() => testAuth(cryptoSignAuthenticator), throwsException);
    });
  });
}

void testAuth(IClientAuthenticator clientAuthenticator) {
  final serializer = JSONSerializer();
  final joiner = Joiner(realm, serializer: serializer, authenticator: clientAuthenticator);
  final acceptor = Acceptor(serializer: serializer, authenticator: authenticator);

  final hello = joiner.sendHello();

  // Process and verify the CHALLENGE message
  final challengeMap = acceptor.receive(hello);
  final challenge = serializer.deserialize(challengeMap.key);

  expect(challenge, isA<Challenge>());
  expect(challengeMap.value, false);

  // Authenticate and verify the response
  final authenticated = joiner.receive(challengeMap.key);
  expect(authenticated, isNotNull);

  // Process and verify the WELCOME message
  final welcomeMap = acceptor.receive(authenticated!);
  final welcome = serializer.deserialize(welcomeMap.key);

  expect(welcome, isA<Welcome>());
  expect(welcomeMap.value, true);

  // Ensure no additional messages are received
  final payload = joiner.receive(welcomeMap.key);
  expect(payload, null);

  // Verify session details are available
  final sessionDetails = joiner.getSessionDetails();
  expect(sessionDetails, isNotNull);
}
