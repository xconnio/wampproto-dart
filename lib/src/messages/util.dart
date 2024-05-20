import "package:wampproto/src/messages/validation_spec.dart";

final Set<String> allowedRoles = <String>{"callee", "caller", "publisher", "subscriber", "dealer", "broker"};

const minID = 1;
const maxID = 1 << 53;

class Fields {
  int? requestId;
  String? uri;
  List<dynamic>? args;
  Map<String, dynamic>? kwargs;

  int? sessionId;

  String? realm;
  String? authid;
  String? authrole;
  String? authmethod;
  List<String>? authmethods;
  Map<String, dynamic>? authextra;
  Map<String, dynamic>? roles;

  int? messageType;
  String? signature;
  String? reason;
  String? topic;

  Map<String, dynamic>? extra;
  Map<String, dynamic>? options;
  Map<String, dynamic>? details;

  int? subscriptionId;
  int? publicationId;

  int? registrationId;
}

String invalidDataTypeError({
  required String message,
  required int index,
  required Type expectedType,
  required String actualType,
}) {
  return "$message: value at index $index must be of type '$expectedType' but was '$actualType'";
}

String invalidRangeError({
  required String message,
  required int index,
  required String start,
  required String end,
  required String actual,
}) {
  return "$message: value at index $index must be between '$start' and '$end' but was '$actual'";
}

void sanityCheck(List<dynamic> wampMessage, int minLength, int maxLength, int expectedID, String name) {
  if (wampMessage.length < minLength) {
    throw ArgumentError("invalid message length ${wampMessage.length}, must be at least $minLength");
  }

  if (wampMessage.length > maxLength) {
    throw ArgumentError("invalid message length ${wampMessage.length}, must be at most $maxLength");
  }

  final messageID = wampMessage[0];
  if (messageID != expectedID) {
    throw ArgumentError("invalid message id $messageID for $name, expected $expectedID");
  }
}

String validateStringOrRaise(Object? string, String errorMsg, String field) {
  if (string == null) {
    throw ArgumentError("$field cannot be null for $errorMsg");
  }

  if (string is! String) {
    throw ArgumentError("$field must be of type string for $errorMsg");
  }

  return string;
}

int validateIntOrRaise(Object? value, String errorMsg, String field) {
  if (value == null) {
    throw ArgumentError("$field cannot be null for $errorMsg");
  }

  if (value is! int) {
    throw ArgumentError("$field must be of type int for $errorMsg");
  }

  return value;
}

Map<String, dynamic> validateMapOrRaise(Object? map, String errorMsg, String field) {
  if (map == null) {
    throw ArgumentError("$field cannot be null for $errorMsg");
  }

  if (map is! Map) {
    throw ArgumentError("$field must be of type map for $errorMsg");
  }

  return map.cast();
}

List<dynamic> validateListOrRaise(Object? list, String errorMsg, String field) {
  if (list == null) {
    throw ArgumentError("$field cannot be null for $errorMsg");
  }

  if (list is! List<dynamic>) {
    throw ArgumentError("$field must be of type list for $errorMsg");
  }

  return list;
}

Map<String, dynamic> validateRolesOrRaise(Object? roles, String errorMsg) {
  if (roles == null) {
    throw ArgumentError("roles cannot be null for $errorMsg");
  }

  if (roles is! Map) {
    throw ArgumentError("roles must be of type map for $errorMsg but was ${roles.runtimeType}");
  }

  for (final role in roles.keys) {
    if (!allowedRoles.contains(role)) {
      throw ArgumentError("invalid role '$role' in 'roles' details for $errorMsg");
    }
  }

  return roles.cast();
}

int validateSessionIDOrRaise(Object? sessionID, String errorMsg, [String? field]) {
  if (sessionID is! int) {
    throw ArgumentError("session ID must be an integer for $errorMsg");
  }

  // session id values lie between 1 and 2^53
  // https://wamp-proto.org/wamp_bp_latest_ietf.html#section-2.1.2-3
  if (sessionID < 0 || sessionID > 9007199254740992) {
    field ??= "Session ID";
    throw ArgumentError("invalid $field value for $errorMsg");
  }

  return sessionID;
}

String? validateInt(Object value, int index, String message) {
  if (value is! int) {
    return invalidDataTypeError(
      message: message,
      index: index,
      expectedType: int,
      actualType: value.runtimeType.toString(),
    );
  }
  return null;
}

String? validateID(Object value, int index, String message) {
  var error = validateInt(value, index, message);
  if (error != null) {
    return error;
  }
  var intValue = value as int;
  if (intValue < minID || intValue > maxID) {
    return invalidRangeError(
      message: message,
      index: index,
      start: minID.toString(),
      end: maxID.toString(),
      actual: intValue.toString(),
    );
  }
  return null;
}

String? validateRequestID(List<dynamic> msg, int index, Fields fields, String message) {
  var error = validateID(msg[index], index, message);
  if (error != null) {
    return error;
  }
  fields.requestId = msg[index];
  return null;
}

String? validateMap(Object value, int index, String message) {
  if (value is! Map) {
    return invalidDataTypeError(
      message: message,
      index: index,
      expectedType: Map,
      actualType: value.runtimeType.toString(),
    );
  }
  return null;
}

String? validateString(Object value, int index, String message) {
  if (value is! String) {
    return invalidDataTypeError(
      message: message,
      index: index,
      expectedType: String,
      actualType: value.runtimeType.toString(),
    );
  }
  return null;
}

String? validateOptions(List<dynamic> msg, int index, Fields fields, String message) {
  var error = validateMap(msg[index], index, message);
  if (error != null) {
    return error;
  }
  fields.options = msg[index];
  return null;
}

String? validateURI(List<dynamic> msg, int index, Fields fields, String message) {
  var error = validateString(msg[index], index, message);
  if (error != null) {
    return error;
  }
  fields.uri = msg[index];
  return null;
}

String? validateList(Object value, int index, String message) {
  if (value is! List) {
    return invalidDataTypeError(
      message: message,
      index: index,
      expectedType: List,
      actualType: value.runtimeType.toString(),
    );
  }
  return null;
}

String? validateArgs(List<dynamic> msg, int index, Fields fields, String message) {
  if (msg.length > index) {
    var error = validateList(msg[index], index, message);
    if (error != null) {
      return error;
    }
    fields.args = msg[index];
  }
  return null;
}

String? validateKwargs(List<dynamic> msg, int index, Fields fields, String message) {
  if (msg.length > index) {
    var error = validateMap(msg[index], index, message);
    if (error != null) {
      return error;
    }
    fields.kwargs = msg[index];
  }
  return null;
}

String? validateSignature(List<dynamic> msg, int index, Fields fields, String message) {
  var error = validateString(msg[index], index, message);
  if (error != null) {
    return error;
  }

  fields.signature = msg[index];
  return null;
}

Fields validateMessage(List<dynamic> msg, int type, String name, ValidationSpec valSpec) {
  sanityCheck(msg, valSpec.minLength, valSpec.maxLength, type, name);

  List<String> errors = [];
  Fields f = Fields();
  valSpec.spec.forEach((idx, func) {
    var error = func(msg, idx, f, valSpec.message);
    if (error != null) {
      errors.add(error);
    }
  });

  if (errors.isNotEmpty) {
    throw ArgumentError(errors.join(", "));
  }

  return f;
}
