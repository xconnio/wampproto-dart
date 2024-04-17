import "package:wampproto/messages.dart";

abstract class IClientAuthenticator {
  IClientAuthenticator(String method, String authID, [Map<String, dynamic>? authExtra])
      : _method = method,
        _authID = authID,
        _authExtra = authExtra ?? <String, dynamic>{};

  final String _method;
  final String _authID;
  final Map<String, dynamic>? _authExtra;

  String get authMethod => _method;
  String get authID => _authID;
  Map<String, dynamic>? get authExtra => _authExtra;

  Authenticate authenticate(Challenge challenge);
}
