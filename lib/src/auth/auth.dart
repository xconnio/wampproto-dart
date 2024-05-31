import "package:wampproto/messages.dart";

abstract class IClientAuthenticator {
  IClientAuthenticator(String method, String authID, [Map<String, dynamic>? authExtra])
      : _method = method,
        _authID = authID,
        authExtra = authExtra ?? <String, dynamic>{};

  final String _method;
  final String _authID;
  Map<String, dynamic>? authExtra;

  String get authMethod => _method;

  String get authID => _authID;

  Authenticate authenticate(Challenge challenge);
}

abstract class IServerAuthenticator {
  List<String> methods();

  Response authenticate(Request request);
}

class AnonymousServerAuthenticator implements IServerAuthenticator {
  static const String anonymous = "anonymous";

  @override
  Response authenticate(Request request) {
    return Response(request.authID, anonymous);
  }

  @override
  List<String> methods() => [anonymous];
}

class Response {
  Response(this._authID, this._authRole);

  final String _authID;
  final String _authRole;

  String get authID => _authID;

  String get authRole => _authRole;
}

class WAMPCRAResponse extends Response {
  WAMPCRAResponse(super._authID, super._authRole, this._secret);

  final String _secret;

  String get secret => _secret;
}

abstract class Request {
  Request(this._method, this._realm, this._authID, this._authExtra);

  final String _method;
  final String _realm;
  final String _authID;
  final Map<String, dynamic> _authExtra;

  String get method => _method;

  String get realm => _realm;

  String get authID => _authID;

  Map<String, dynamic> get authExtra => _authExtra;
}

class AnonymousRequest extends Request {
  AnonymousRequest(String realm, String authID, Map<String, dynamic> authExtra) : super(type, realm, authID, authExtra);

  static const String type = "anonymous";
}

class CryptoSignRequest extends Request {
  CryptoSignRequest(String realm, String authID, Map<String, dynamic> authExtra, this._publicKey)
      : super(type, realm, authID, authExtra);

  static const String type = "cryptosign";
  final String _publicKey;

  String get publicKey => _publicKey;
}

class WAMPCRARequest extends Request {
  WAMPCRARequest(String realm, String authID, Map<String, dynamic> authExtra) : super(type, realm, authID, authExtra);

  static const String type = "wampcra";
}

class TicketRequest extends Request {
  TicketRequest(String realm, String authID, Map<String, dynamic> authExtra, this._ticket)
      : super(type, realm, authID, authExtra);

  static const String type = "ticket";
  final String _ticket;

  String get ticket => _ticket;
}
