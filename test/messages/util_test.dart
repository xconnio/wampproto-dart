import "package:test/test.dart";
import "package:wampproto/messages.dart";
import "package:wampproto/src/messages/util.dart";
import "package:wampproto/src/messages/validation_spec.dart";

void main() {
  group("Validation Tests", () {
    test("sanityCheck", () {
      // valid message
      expect(() => sanityCheck([1, 2, 3], 2, 4, 1, "TestMessage"), returnsNormally);

      // invalid length
      expect(() => sanityCheck([1], 2, 4, 1, "TestMessage"), throwsException);
      expect(() => sanityCheck([1, 2, 3, 4, 5], 2, 4, 1, "TestMessage"), throwsException);

      // invalid message ID
      expect(() => sanityCheck([2, 2, 3], 2, 4, 1, "TestMessage"), throwsException);
    });

    test("validateInt", () {
      // valid int
      expect(validateInt(123, 0, "message"), isNull);

      // invalid int
      expect(validateInt("string", 0, "message"), isNotNull);
    });

    test("validateID", () {
      // valid ID
      expect(validateID(123, 0, "message"), isNull);

      // invalid ID
      expect(validateID("string", 0, "message"), isNotNull);
      expect(validateID(0, 0, "message"), isNotNull);
    });

    test("validateRequestID", () {
      // valid requestID
      Fields fields = Fields();
      expect(validateRequestID([123], 0, fields, "message"), isNull);
      expect(fields.requestID, 123);

      // invalid requestID
      expect(validateRequestID(["string"], 0, fields, "message"), isNotNull);
    });

    test("validateMap", () {
      // valid map
      expect(validateMap({"key": "value"}, 0, "message"), isNull);

      // invalid map
      expect(validateMap("string", 0, "message"), isNotNull);
    });

    test("validateString", () {
      // valid string
      expect(validateString("string", 0, "message"), isNull);

      // invalid string
      expect(validateString(123, 0, "message"), isNotNull);
    });

    test("validateOptions", () {
      Fields fields = Fields();
      // valid options
      expect(
        validateOptions(
          [
            {"key": "value"},
          ],
          0,
          fields,
          "message",
        ),
        isNull,
      );
      expect(fields.options, {"key": "value"});

      // invalid options
      expect(validateOptions(["string"], 0, fields, "message"), isNotNull);
    });

    test("validateURI", () {
      Fields fields = Fields();
      // valid URI
      expect(validateURI(["uri"], 0, fields, "message"), isNull);
      expect(fields.uri, "uri");

      // invalid URI
      expect(validateURI([123], 0, fields, "message"), isNotNull);
    });

    test("validateList", () {
      // valid list
      expect(validateList([1, 2, 3], 0, "message"), isNull);

      // invalid list
      expect(validateList("string", 0, "message"), isNotNull);
    });

    test("validateRoles", () {
      // valid roles
      var result = validateRoles({"callee": {}, "caller": {}}, "TestMessage");
      expect(result, isNull);

      // empty roles
      result = validateRoles({}, "TestMessage");
      expect(result, isNull);

      // null roles
      result = validateRoles(null, "TestMessage");
      expect(result, "roles cannot be null for TestMessage");

      // invalid roles type
      result = validateRoles("not_a_map", "TestMessage");
      expect(result, "roles must be of type map for TestMessage but was String for TestMessage");

      // invalid roles
      result = validateRoles({"invalid_role": {}}, "TestMessage");
      expect(result, "invalid role 'invalid_role' in 'roles' details for TestMessage");
    });

    test("validateArgs", () {
      Fields fields = Fields();

      // valid args
      expect(
        validateArgs(
          [
            [1, 2, 3],
          ],
          0,
          fields,
          "message",
        ),
        isNull,
      );
      expect(fields.args, [1, 2, 3]);

      // invalid args
      expect(validateArgs(["string"], 0, fields, "message"), isNotNull);
    });

    test("validateKwargs", () {
      Fields fields = Fields();

      // valid kwargs
      expect(
        validateKwargs(
          [
            {"key": "value"},
          ],
          0,
          fields,
          "message",
        ),
        isNull,
      );
      expect(fields.kwargs, {"key": "value"});

      // invalid kwargs
      expect(validateKwargs(["string"], 0, fields, "message"), isNotNull);
    });

    test("validateSignature", () {
      Fields fields = Fields();
      // valid signature
      expect(validateSignature(["signature"], 0, fields, "message"), isNull);
      expect(fields.signature, "signature");

      // invalid signature
      expect(validateSignature([123], 0, fields, "message"), isNotNull);
    });

    test("validateExtra", () {
      Fields fields = Fields();
      // valid extra
      expect(
        validateExtra(
          [
            {"key": "value"},
          ],
          0,
          fields,
          "message",
        ),
        isNull,
      );
      expect(fields.extra, {"key": "value"});

      // invalid extra
      expect(validateExtra(["string"], 0, fields, "message"), isNotNull);
    });

    test("validateDetails", () {
      Fields fields = Fields();

      // valid details
      expect(
        validateDetails(
          [
            {"key": "value"},
          ],
          0,
          fields,
          "message",
        ),
        isNull,
      );
      expect(fields.details, {"key": "value"});

      // invalid details
      expect(validateDetails(["string"], 0, fields, "message"), isNotNull);

      // valid Hello message
      var validHelloDetails = [
        {
          "authid": "user123",
          "authmethods": ["password"],
          "roles": {},
          "authextra": {},
        },
      ];
      expect(validateDetails(validHelloDetails, 0, fields, Hello.text), isNull);

      // valid Welcome details
      var validWelcomeDetails = [
        {"authid": "user123", "authrole": "admin", "authmethod": "password", "roles": {}, "authextra": {}},
      ];
      expect(validateDetails(validWelcomeDetails, 0, fields, Welcome.text), isNull);

      // authmethods is not a list for Hello message
      var invalidAuthMethods = [
        {"authid": "user123", "authmethods": "not_a_list", "roles": {}, "authextra": {}},
      ];
      var invalidAuthMethodsResult = validateDetails(invalidAuthMethods, 0, fields, Hello.text);
      expect(invalidAuthMethodsResult, "authmethods must be of type list in details for ${Hello.text}");

      // authrole is not a string for Welcome message
      var invalidAuthRole = [
        {"authid": "user123", "authrole": 123, "authmethod": "password", "roles": {}, "authextra": {}},
      ];
      var invalidAuthRoleResult = validateDetails(invalidAuthRole, 0, fields, Welcome.text);
      expect(invalidAuthRoleResult, "authrole must be of type string in details for ${Welcome.text}");

      // authmethod is not a string for Welcome message
      var invalidAuthMethod = [
        {"authid": "user123", "authrole": "admin", "authmethod": 123, "roles": {}, "authextra": {}},
      ];
      var invalidAuthMethodResult = validateDetails(invalidAuthMethod, 0, fields, Welcome.text);
      expect(invalidAuthMethodResult, "authmethod must be of type string in details for ${Welcome.text}");

      // invalid roles
      var invalidRoles = [
        {
          "authid": "user123",
          "authmethods": ["password"],
          "roles": "not_a_map",
          "authextra": {},
        },
      ];
      var invalidRolesResult = validateDetails(invalidRoles, 0, fields, Hello.text);
      expect(invalidRolesResult, "roles must be of type map for HELLO but was String for ${Hello.text}");

      // invalid authextra
      var invalidAuthExtra = [
        {
          "authid": "user123",
          "authmethods": ["password"],
          "roles": {},
          "authextra": "not_a_map",
        },
      ];
      var invalidAuthExtraResult = validateDetails(invalidAuthExtra, 0, fields, Hello.text);
      expect(invalidAuthExtraResult, "authextra must be of type Map in details for ${Hello.text}");

      // invalid authid
      var invalidAuthID = [
        {
          "authid": 123,
          "authmethods": ["password"],
          "roles": {},
          "authextra": {},
        },
      ];
      var resultInvalidAuthID = validateDetails(invalidAuthID, 0, fields, Hello.text);
      expect(resultInvalidAuthID, "authid must be of type string in details for ${Hello.text}");
    });

    test("validateReason", () {
      Fields fields = Fields();
      // valid reason
      expect(validateReason(["reason"], 0, fields, "message"), isNull);
      expect(fields.reason, "reason");

      // invalid reason
      expect(validateReason([123], 0, fields, "message"), isNotNull);
    });

    test("validateAuthMethod", () {
      // valid authMethod
      Fields fields = Fields();
      expect(validateAuthMethod(["authMethod"], 0, fields, "message"), isNull);
      expect(fields.authmethod, "authMethod");

      //invalid authMethod
      expect(validateAuthMethod([123], 0, fields, "message"), isNotNull);
    });

    test("validateMessageType", () {
      Fields fields = Fields();
      // valid messageType
      expect(validateMessageType([1], 0, fields, "message"), isNull);
      expect(fields.messageType, 1);

      // invalid messageType
      expect(validateMessageType(["string"], 0, fields, "message"), isNotNull);
    });

    test("validateSubscriptionID", () {
      Fields fields = Fields();
      // valid subscriptionID
      expect(validateSubscriptionID([123], 0, fields, "message"), isNull);
      expect(fields.subscriptionID, 123);

      // invalid subscriptionID
      expect(validateSubscriptionID(["string"], 0, fields, "message"), isNotNull);
    });

    test("validatePublicationID", () {
      Fields fields = Fields();
      // valid publicationID
      expect(validatePublicationID([123], 0, fields, "message"), isNull);
      expect(fields.publicationID, 123);

      // invalid publicationID
      expect(validatePublicationID(["string"], 0, fields, "message"), isNotNull);
    });

    test("validateRegistrationID ", () {
      Fields fields = Fields();
      // valid registrationID
      expect(validateRegistrationID([12345], 0, fields, "message"), isNull);
      expect(fields.registrationID, 12345);

      // invalid registrationID (type)
      expect(validateRegistrationID(["not an ID"], 0, fields, "message"), isNotNull);

      // invalid registrationID (range)
      expect(validateRegistrationID([0], 0, fields, "message"), isNotNull);
      expect(validateRegistrationID([1 << 54], 0, fields, "message"), isNotNull);
    });

    test("validateSessionID", () {
      Fields fields = Fields();
      // valid sessionID
      expect(validateSessionID([123], 0, fields, "message"), isNull);
      expect(fields.sessionID, 123);

      // invalid sessionID
      expect(validateSessionID(["string"], 0, fields, "message"), isNotNull);
    });

    test("validateTopic", () {
      Fields fields = Fields();
      // valid topic
      expect(validateTopic(["topic"], 0, fields, "message"), isNull);
      expect(fields.topic, "topic");

      // invalid topic
      expect(validateTopic([123], 0, fields, "message"), isNotNull);
    });

    test("validateRealm", () {
      Fields fields = Fields();
      // valid realm
      expect(validateRealm(["realm"], 0, fields, "message"), isNull);
      expect(fields.realm, "realm");

      // invalid realm
      expect(validateRealm([123], 0, fields, "message"), isNotNull);
    });

    test("validateMessage", () {
      // valid message
      var spec = ValidationSpec(
        minLength: 2,
        maxLength: 3,
        message: "TestMessage",
        spec: {
          0: validateRequestID,
          1: validateURI,
        },
      );

      expect(() => validateMessage([1, "uri"], 1, "TestMessage", spec), returnsNormally);

      // invalid message
      var specInvalid = ValidationSpec(
        minLength: 2,
        maxLength: 3,
        message: "TestMessage",
        spec: {
          0: validateRequestID,
          1: validateURI,
        },
      );

      expect(() => validateMessage([1, 123], 1, "TestMessage", specInvalid), throwsException);
    });
  });
}
