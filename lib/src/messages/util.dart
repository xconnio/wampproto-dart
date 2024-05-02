final Set<String> allowedRoles = <String>{"callee", "caller", "publisher", "subscriber", "dealer", "broker"};

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

  if (map is! Map<String, dynamic>) {
    throw ArgumentError("$field must be of type map for $errorMsg");
  }

  return map;
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

  if (roles is! Map<String, dynamic>) {
    throw ArgumentError("roles must be of type map for $errorMsg");
  }

  for (final role in roles.keys) {
    if (!allowedRoles.contains(role)) {
      throw ArgumentError("invalid role '$role' in 'roles' details for $errorMsg");
    }
  }
  return roles;
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
