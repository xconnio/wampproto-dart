import "package:wampproto/idgen.dart";
import "package:wampproto/messages.dart";
import "package:wampproto/src/types.dart";
import "package:wampproto/src/uris.dart";

class PendingInvocation {
  PendingInvocation(this.requestID, this.callerID, this.calleeID);

  int requestID;
  int callerID;
  int calleeID;
}

class Dealer {
  Map<String, Registration> registrationsByProcedure = {};
  Map<int, Map<int, Registration>> registrationsBySession = {};
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
      var registration = registrationsByProcedure[value.procedure];
      if (registration != null) {
        if (registration.registrants.containsKey(sid)) {
          registration.registrants.remove(sid);
        }
        if (registration.registrants.isEmpty) {
          registrationsByProcedure.remove(registration.procedure);
        }
      }
    });
  }

  bool hasRegistration(String procedure) {
    return registrationsByProcedure.containsKey(procedure);
  }

  MessageWithRecipient receiveMessage(int sessionID, Message message) {
    if (message is Call) {
      var registration = registrationsByProcedure[message.uri];
      if (registration == null) {
        throw Exception("procedure has no registration");
      }

      int calleeID = 0;
      for (final session in registration.registrants.keys) {
        calleeID = session;
        break;
      }

      int requestID = idGen.next();
      pendingCalls[requestID] = PendingInvocation(message.requestID, sessionID, calleeID);

      Invocation invocation = Invocation(requestID, registration.id, args: message.args, kwargs: message.kwargs);
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

      var registrations = registrationsByProcedure[message.uri];
      if (registrations == null) {
        var registration = Registration(idGen.next(), message.uri, {sessionID: sessionID});
        registrationsByProcedure[message.uri] = registration;
        registrationsBySession.putIfAbsent(sessionID, () => {})[registration.id] = registration;
      } else {
        // TODO: implement shared registrations.
        var registered = Error(Register.id, message.requestID, errProcedureAlreadyExists);
        return MessageWithRecipient(registered, sessionID);
      }

      Registered registered = Registered(message.requestID, registrations!.id);
      return MessageWithRecipient(registered, sessionID);
    } else if (message is UnRegister) {
      var registrations = registrationsBySession[sessionID];
      if (registrations == null) {
        throw Exception("cannot unregister, session $sessionID doesn't exist");
      }

      var registration = registrations[message.registrationID];
      if (registration == null || !registration.registrants.containsKey(sessionID)) {
        throw Exception("registration for session $sessionID doesn't exist");
      }
      registration.registrants.remove(sessionID);

      if (registration.registrants.isEmpty) {
        registrations.remove(message.registrationID);
        registrationsByProcedure.remove(registration.procedure);
      }
      registrationsBySession[sessionID] = registrations;

      UnRegistered unRegistered = UnRegistered(message.requestID);
      return MessageWithRecipient(unRegistered, sessionID);
    } else {
      throw Exception("message type not supported");
    }
  }
}
