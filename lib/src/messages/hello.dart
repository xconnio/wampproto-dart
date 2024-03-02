import 'message.dart';

class Hello extends Message {
  static int id = 1;

  final String realm;
  final Map<String, Map<String, bool>> roles;
  final String authID;
  final List<String> authMethods;

  Hello(this.realm, this.roles, this.authID, this.authMethods) : super(Hello.id);

  static Hello parse(List<dynamic> message) {
    if (message.length < 2) {
      throw ArgumentError("invalid hello message");
    }

    final type = message[0];
    if (type is! int) {
      throw ArgumentError("message type must be an int");
    }

    if (type != Hello.id) {
      throw ArgumentError("invalid message type: must be ${Hello.id}, was $type");
    }

    final realm = message[1];
    if (realm is! String) {
      throw ArgumentError("realm name must be a string");
    }

    return Hello(realm, {}, "", []);
  }

  List<dynamic> marshal() {
    Map<String, dynamic> details = {};
    details["roles"] = roles;
    details["authid"] = authID;
    details["authmethods"] = authMethods;

    return [id, realm, details];
  }
}
