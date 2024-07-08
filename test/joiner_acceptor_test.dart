import "package:test/test.dart";

import "package:wampproto/acceptor.dart";
import "package:wampproto/auth.dart";
import "package:wampproto/joiner.dart";
import "package:wampproto/messages.dart";
import "package:wampproto/serializers.dart";

class Authenticator extends IServerAuthenticator {
  @override
  Response authenticate(Request request) {
    switch (request.method) {
      case "anonymous":
        return Response(request.authID, "anonymous");
      case "ticket":
        return Response(request.authID, "anonymous");
      case "wampcra":
        return WAMPCRAResponse(request.authID, "anonymous", "password");
      case "cryptosign":
        return Response(request.authID, "anonymous");

      default:
        throw ArgumentError("invalid auth method");
    }
  }

  @override
  List<String> methods() {
    return ["cryptosign", "ticket", "wampcra", "anonymous"];
  }
}

const realm = "realm1";

void main() {
  var authenticator = Authenticator();
  test("AnonymousAuth", () {
    var serializer = JSONSerializer();
    var joiner = Joiner(realm, serializer: serializer, authenticator: AnonymousAuthenticator(""));
    var acceptor = Acceptor(serializer: serializer, authenticator: authenticator);

    var hello = joiner.sendHello();

    var welcomeMap = acceptor.receive(hello);
    var welcome = serializer.deserialize(welcomeMap.key);
    expect(welcome, isA<Welcome>());
    expect(welcomeMap.value, true);

    var welcomeJoiner = joiner.receive(welcomeMap.key);
    expect(welcomeJoiner, null);

    var sessionDetails = joiner.getSessionDetails();
    expect(sessionDetails, isNotNull);
  });

  test("TicketAuth", () => testAuth(authenticator, TicketAuthenticator("", "test")));

  test("CRAAuth", () => testAuth(authenticator, WAMPCRAAuthenticator("password", "test", {"challenge": "test"})));

  test(
    "CryptoSignAuth",
    () => testAuth(
      authenticator,
      CryptoSignAuthenticator("authID", "6d9b906ad60d1f4dd796dbadcc2e2252310565ccdc6fe10b289df5684faf2a46"),
    ),
  );
}

void testAuth(Authenticator authenticator, IClientAuthenticator clientAuthenticator) {
  var serializer = JSONSerializer();
  var joiner = Joiner(realm, serializer: serializer, authenticator: clientAuthenticator);
  var acceptor = Acceptor(serializer: serializer, authenticator: authenticator);

  var hello = joiner.sendHello();

  var challengeMap = acceptor.receive(hello);
  var challenge = serializer.deserialize(challengeMap.key);
  expect(challenge, isA<Challenge>());
  expect(challengeMap.value, false);

  var authenticated = joiner.receive(challengeMap.key);
  expect(authenticated, isNotNull);

  var welcomeMap = acceptor.receive(authenticated!);
  var welcome = serializer.deserialize(welcomeMap.key);
  expect(welcome, isA<Welcome>());
  expect(welcomeMap.value, true);

  var welcomeJoiner = joiner.receive(welcomeMap.key);
  expect(welcomeJoiner, null);
  expect(joiner.getSessionDetails(), isNotNull);

  var sessionDetails = joiner.getSessionDetails();
  expect(sessionDetails, isNotNull);
}
