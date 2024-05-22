import "package:test/test.dart";
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

    test("validateStringOrRaise", () {
      // valid string
      expect(validateStringOrRaise("test", "errorMsg", "field"), "test");

      // invalid string
      expect(() => validateStringOrRaise(123, "errorMsg", "field"), throwsException);
    });

    test("validateMapOrRaise", () {
      // valid map
      expect(validateMapOrRaise({"key": "value"}, "errorMsg", "field"), {"key": "value"});

      // invalid map
      expect(() => validateMapOrRaise(123, "errorMsg", "field"), throwsException);
    });

    test("validateListOrRaise", () {
      // valid list
      expect(validateListOrRaise([1, 2, 3], "errorMsg", "field"), [1, 2, 3]);

      // invalid list
      expect(() => validateListOrRaise(123, "errorMsg", "field"), throwsException);
    });

    test("validateRolesOrRaise", () {
      // valid roles
      expect(validateRolesOrRaise({"caller": {}, "callee": {}}, "errorMsg"), {"caller": {}, "callee": {}});

      // invalid roles
      expect(() => validateRolesOrRaise({"invalidRole": {}}, "errorMsg"), throwsException);
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
