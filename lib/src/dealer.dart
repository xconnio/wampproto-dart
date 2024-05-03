import "package:wampproto/idgen.dart";
import "package:wampproto/messages.dart";
import "package:wampproto/src/types.dart";

class Dealer {
  Map<String, Map<int, int>> registrationsByProcedure = {};
  Map<int, Map<int, String>> registrationsBySession = {};
  Map<int, Map<int, int>> pendingCalls = {};

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

      int callee = 0;
      int registration = 0;

      registrations.forEach((regID, session) {
        registration = regID;
        callee = session;
        return;
      });

      pendingCalls.putIfAbsent(callee, () => {})[message.requestID] = sessionID;
      Invocation invocation = Invocation(message.requestID, registration, args: message.args, kwargs: message.kwargs);
      return MessageWithRecipient(invocation, callee);
    } else if (message is Yield) {
      var calls = pendingCalls[sessionID];
      if (calls == null || calls.isEmpty) {
        throw Exception("no pending calls for session $sessionID");
      }

      int caller = calls[message.requestID] ?? (throw Exception("no pending calls for session $sessionID"));

      pendingCalls[sessionID]?.remove(message.requestID);
      Result result = Result(message.requestID, args: message.args, kwargs: message.kwargs);
      return MessageWithRecipient(result, caller);
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
