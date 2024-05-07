import "package:wampproto/src/messages/message.dart";

class SessionDetails {
  SessionDetails(this.sessionID, this.realm, this.authid, this.authrole);

  final int sessionID;
  final String realm;
  final String authid;
  final String authrole;
}

class MessageWithRecipient {
  MessageWithRecipient(this.message, this.recipient);

  Message message;
  int recipient;
}

class Registration {
  Registration(this.id, this.procedure, this.registrants, {this.invocationPolicy});

  final int id;
  final String procedure;
  final Map<int, int> registrants;
  final String? invocationPolicy;
}
