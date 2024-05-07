import "package:wampproto/idgen.dart";
import "package:wampproto/messages.dart";
import "package:wampproto/src/types.dart";

class PendingInvocation {
  PendingInvocation(this.requestID, this.callerID, this.calleeID);

  int requestID;
  int callerID;
  int calleeID;
}

class Dealer {
  Map<String, Map<int, int>> registrationsByProcedure = {};
  Map<int, Map<int, String>> registrationsBySession = {};
  Map<int, PendingInvocation> pendingCalls = {};

  SessionScopeIDGenerator idGen = SessionScopeIDGenerator();

  void addSession(int sid) {
    if (registrationsBySession.containsKey(sid)) {
      throw Exception("cannot add session twice");
    }

    registrationsBySession[sid] = {};
  }

  void removeSession(int sid) {
    var registrations = registrationsBySession.remove(sid);
    if (registrations == null) {
      throw Exception("cannot remove non-existing session");
    }

    registrations.forEach((key, value) {
      registrationsByProcedure[value]?.remove(key);
      if (registrationsByProcedure[value]?.isEmpty ?? false) {
        registrationsByProcedure.remove(value);
      }
    });
  }

  bool hasRegistration(String procedure) {
    return registrationsByProcedure[procedure]?.isNotEmpty ?? false;
  }

  MessageWithRecipient receiveMessage(int sessionID, Message message) {
    if (message is Call) {
      var registrations = registrationsByProcedure[message.uri];
      if (registrations == null || registrations.isEmpty) {
        throw Exception("procedure has no registrations");
      }

      int calleeID = 0;
      int registration = 0;

      registrations.forEach((regID, session) {
        registration = regID;
        calleeID = session;
        return;
      });

      int requestID = idGen.next();
      pendingCalls[requestID] = PendingInvocation(message.requestID, sessionID, calleeID);

      Invocation invocation = Invocation(requestID, registration, args: message.args, kwargs: message.kwargs);
      return MessageWithRecipient(invocation, calleeID);
    } else if (message is Yield) {
      PendingInvocation? invocation = pendingCalls.remove(message.requestID);

      if (invocation == null) {
        throw Exception("no pending calls for session $sessionID");
      }

      if (sessionID != invocation.calleeID) {
        throw Exception("received unexpected yield from session=$sessionID");
      }

      Result result = Result(invocation.requestID, args: message.args, kwargs: message.kwargs);
      return MessageWithRecipient(result, invocation.callerID);
    } else if (message is Register) {
      if (!registrationsBySession.containsKey(sessionID)) {
        throw Exception("cannot register, session $sessionID doesn't exist");
      }

      int registrationID = idGen.next();
      registrationsByProcedure.putIfAbsent(message.uri, () => {})[registrationID] = sessionID;
      registrationsBySession.putIfAbsent(sessionID, () => {})[registrationID] = message.uri;

      Registered registered = Registered(message.requestID, registrationID);
      return MessageWithRecipient(registered, sessionID);
    } else if (message is UnRegister) {
      if (!registrationsBySession.containsKey(sessionID)) {
        throw Exception("cannot unregister, session $sessionID doesn't exist");
      }

      var registrations = registrationsBySession[sessionID];
      if (registrations == null || !registrations.containsKey(message.registrationID)) {
        throw Exception("registration for session $sessionID doesn't exist");
      }
      var procedure = registrations[message.registrationID];

      registrationsBySession[sessionID]?.remove(message.registrationID);
      registrationsByProcedure[procedure]?.remove(message.registrationID);

      UnRegistered unRegistered = UnRegistered(message.requestID);
      return MessageWithRecipient(unRegistered, sessionID);
    } else {
      throw Exception("message type not supported");
    }
  }
}
