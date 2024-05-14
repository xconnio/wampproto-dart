import "package:wampproto/messages.dart";

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

class Subscription {
  Subscription(this.id, this.topic, this.subscribers);

  final int id;
  final String topic;
  final Map<int, int> subscribers;
}

class Publication {
  Publication({this.event, this.recipients, this.ack});

  Event? event;
  List<int>? recipients;
  MessageWithRecipient? ack;
}
