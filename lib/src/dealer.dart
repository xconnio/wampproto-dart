import "package:meta/meta.dart";
import "package:wampproto/idgen.dart";
import "package:wampproto/messages.dart";
import "package:wampproto/src/types.dart";
import "package:wampproto/src/uris.dart";

const optionReceiveProgress = "receive_progress";
const optionProgress = "progress";

class PendingInvocation {
  PendingInvocation(
    this.requestID,
    this.callerID,
    this.calleeID, {
    required this.progress,
    required this.receiveProgress,
  });

  final int requestID;
  final int callerID;
  final int calleeID;
  final bool progress;
  final bool receiveProgress;
}

@immutable
class CallMap {
  const CallMap(this.callerID, this.callID);

  final int callerID;
  final int callID;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CallMap && runtimeType == other.runtimeType && callerID == other.callerID && callID == other.callID;

  @override
  int get hashCode => callerID.hashCode ^ callID.hashCode;
}

class Dealer {
  final Map<String, Registration> _registrationsByProcedure = {};
  final Map<int, Map<int, Registration>> _registrationsBySession = {};
  final Map<int, PendingInvocation> _pendingCalls = {};
  final Map<int, SessionDetails> _sessions = {};
  final Map<CallMap, int> _callToInvocationId = {};

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

  void _addCall(int callId, int invocationId, int callerId, int calleeId, bool progress, bool receiveProgress) {
    _pendingCalls[invocationId] =
        PendingInvocation(callId, callerId, calleeId, progress: progress, receiveProgress: receiveProgress);
    _callToInvocationId[CallMap(callerId, callId)] = invocationId;
  }

  MessageWithRecipient receiveMessage(int sessionID, Message message) {
    if (message is Call) {
      var registration = _registrationsByProcedure[message.uri];
      if (registration == null) {
        var error = Error(Register.id, message.requestID, errNoSuchProcedure);
        return MessageWithRecipient(error, sessionID);
      }

      int calleeID = 0;
      for (final session in registration.registrants.keys) {
        calleeID = session;
        break;
      }

      var receiveProgress = message.options[optionReceiveProgress] ?? false;
      var progress = message.options[optionProgress] ?? false;
      int? invocationID;
      if (progress) {
        invocationID = _callToInvocationId[CallMap(sessionID, message.requestID)];
        if (invocationID == null) {
          invocationID = _idGen.next();
          _addCall(message.requestID, invocationID, sessionID, calleeID, progress, receiveProgress);
        }
      } else {
        invocationID = _idGen.next();
        _addCall(message.requestID, invocationID, sessionID, calleeID, progress, receiveProgress);
      }

      Map<String, dynamic> details = {};
      if (receiveProgress) {
        details[optionReceiveProgress] = true;
      }

      if (progress) {
        details[optionProgress] = true;
      }

      var invocation = Invocation(
        invocationID,
        registration.id,
        args: message.args,
        kwargs: message.kwargs,
        details: details,
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
        _callToInvocationId.remove(CallMap(invocation.callerID, invocation.requestID));
      }
      var result = Result(invocation.requestID, args: message.args, kwargs: message.kwargs, details: details);
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
        var error = Error(Register.id, message.requestID, errProcedureAlreadyExists);
        return MessageWithRecipient(error, sessionID);
      }

      var registered = Registered(message.requestID, registrations.id);
      return MessageWithRecipient(registered, sessionID);
    } else if (message is Unregister) {
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

      var unregistered = Unregistered(message.requestID);
      return MessageWithRecipient(unregistered, sessionID);
    } else if (message is Error) {
      if (message.msgType != Invocation.id) {
        throw Exception("dealer: only expected to receive error in response to invocation");
      }

      var pending = _pendingCalls[message.requestID];
      if (pending == null) {
        throw Exception("dealer: no pending invocation for ${message.requestID}");
      }

      _pendingCalls.remove(message.requestID);

      var errMessage = Error(
        Call.id,
        pending.requestID,
        message.uri,
        args: message.args,
        kwargs: message.kwargs,
        details: message.details,
      );

      return MessageWithRecipient(errMessage, pending.callerID);
    } else {
      throw Exception("message type not supported");
    }
  }
}
