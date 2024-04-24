import "package:wampproto/src/messages/message.dart";

class SessionDetails {
  SessionDetails(this.sessionId, this.realm, this.authid, this.authrole);

  final int sessionId;
  final String realm;
  final String authid;
  final String authrole;
}

class MessageWithRecipient {
  MessageWithRecipient(this.message, this.recipient);

  Message message;
  int recipient;
}
