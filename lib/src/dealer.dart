import "package:wampproto/idgen.dart";
import "package:wampproto/messages.dart";
import "package:wampproto/src/types.dart";
import "package:wampproto/src/uris.dart";

const optionReceiveProgress = "receive_progress";
const optionProgress = "progress";

class PendingInvocation {
  PendingInvocation(this.requestID, this.callerID, this.calleeID, {required this.receiveProgress});

  final int requestID;
  final int callerID;
  final int calleeID;
  final bool receiveProgress;
}

class Dealer {
  final Map<String, Registration> _registrationsByProcedure = {};
  final Map<int, Map<int, Registration>> _registrationsBySession = {};
  final Map<int, PendingInvocation> _pendingCalls = {};
  final Map<int, SessionDetails> _sessions = {};

  final _idGen = SessionScopeIDGenerator();

  void addSession(SessionDetails details) {
    if (_registrationsBySession.containsKey(details.sessionID)) {
      throw Exception("cannot add session twice");
    }

    _registrationsBySession[details.sessionID] = {};
    _sessions[details.sessionID] = details;
  }

  void removeSession(int sid) {
    var registrations = _registrationsBySession.remove(sid);
    if (registrations == null) {
      throw Exception("cannot remove non-existing session");
    }

    registrations.forEach((key, value) {
      var registration = _registrationsByProcedure[value.procedure];
      if (registration != null) {
        if (registration.registrants.containsKey(sid)) {
          registration.registrants.remove(sid);
        }
        if (registration.registrants.isEmpty) {
          _registrationsByProcedure.remove(registration.procedure);
        }
      }
    });

    _sessions.remove(sid);
  }

  bool hasRegistration(String procedure) {
    return _registrationsByProcedure.containsKey(procedure);
  }

  MessageWithRecipient receiveMessage(int sessionID, Message message) {
    if (message is Call) {
      var registration = _registrationsByProcedure[message.uri];
      if (registration == null) {
        var error = Error(ErrorFields(Register.id, message.requestID, errNoSuchProcedure));
        return MessageWithRecipient(error, sessionID);
      }

      int calleeID = 0;
      for (final session in registration.registrants.keys) {
        calleeID = session;
        break;
      }

      var receiveProgress = message.options[optionReceiveProgress] ?? false;
      int requestID = _idGen.next();
      _pendingCalls[requestID] = PendingInvocation(
        message.requestID,
        sessionID,
        calleeID,
        receiveProgress: receiveProgress,
      );

      var invocation = Invocation(
        InvocationFields(
          requestID,
          registration.id,
          args: message.args,
          kwargs: message.kwargs,
          details: receiveProgress ? {optionReceiveProgress: receiveProgress} : {},
        ),
      );
      return MessageWithRecipient(invocation, calleeID);
    } else if (message is Yield) {
      PendingInvocation? invocation = _pendingCalls[message.requestID];

      if (invocation == null) {
        throw Exception("no pending calls for session $sessionID");
      }

      if (sessionID != invocation.calleeID) {
        throw Exception("received unexpected yield from session=$sessionID");
      }

      Map<String, dynamic> details = {};
      var receiveProgress = message.options[optionProgress] ?? false;
      if (receiveProgress && invocation.receiveProgress) {
        details[optionProgress] = receiveProgress;
      } else {
        _pendingCalls.remove(message.requestID);
      }
      var result =
          Result(ResultFields(invocation.requestID, args: message.args, kwargs: message.kwargs, details: details));
      return MessageWithRecipient(result, invocation.callerID);
    } else if (message is Register) {
      if (!_registrationsBySession.containsKey(sessionID)) {
        throw Exception("cannot register, session $sessionID doesn't exist");
      }

      var registrations = _registrationsByProcedure[message.uri];
      if (registrations == null) {
        registrations = Registration(_idGen.next(), message.uri, {sessionID: sessionID});
        _registrationsByProcedure[message.uri] = registrations;
        _registrationsBySession.putIfAbsent(sessionID, () => {})[registrations.id] = registrations;
      } else {
        // TODO: implement shared registrations.
        var error = Error(ErrorFields(Register.id, message.requestID, errProcedureAlreadyExists));
        return MessageWithRecipient(error, sessionID);
      }

      var registered = Registered(RegisteredFields(message.requestID, registrations.id));
      return MessageWithRecipient(registered, sessionID);
    } else if (message is UnRegister) {
      var registrations = _registrationsBySession[sessionID];
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
        _registrationsByProcedure.remove(registration.procedure);
      }
      _registrationsBySession[sessionID] = registrations;

      var unRegistered = UnRegistered(UnRegisteredFields(message.requestID));
      return MessageWithRecipient(unRegistered, sessionID);
    } else {
      throw Exception("message type not supported");
    }
  }
}
