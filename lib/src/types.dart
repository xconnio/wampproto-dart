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
