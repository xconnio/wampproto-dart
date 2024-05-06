import "dart:typed_data";

import "package:test/test.dart";
import "package:wampproto/messages.dart";
import "package:wampproto/serializers.dart";

void main() {
  group("Serializer Tests", () {
    testSerializer(JSONSerializer());
    testSerializer(CBORSerializer());
    testSerializer(MsgPackSerializer());
  });
}

void testSerializer(Serializer serializer) {
  var name = serializer.runtimeType.toString();

  test("$name serialize and deserialize correctly", () {
    var hello = Hello.parse([
      1,
      "realm1",
      {
        "authid": "test",
        "roles": {
          "callee": {"allow_call": true},
        },
      },
    ]);

    var data = serializer.serialize(hello);
    Message obj = serializer.deserialize(data);
    Hello deserialized = obj as Hello;

    expect(deserialized, isA<Hello>(), reason: "Deserialized object should be a Hello message");
    expect(
      [
        deserialized.realm,
        deserialized.authID,
        deserialized.authExtra,
        deserialized.authMethods,
        deserialized.roles,
        deserialized.messageType(),
      ],
      equals([
        hello.realm,
        hello.authID,
        hello.authExtra,
        hello.authMethods,
        hello.roles,
        hello.messageType(),
      ]),
    );
  });

  test("$name invalid message", () {
    Object invalidMessage;
    if (serializer is JSONSerializer) {
      invalidMessage = 123;
    } else {
      invalidMessage = "invalid";
    }

    expect(() => serializer.deserialize(invalidMessage), throwsException);
  });

  test("$name invalid data", () {
    Object invalidData;
    if (serializer is JSONSerializer) {
      invalidData = "invalid";
    } else {
      invalidData = Uint8List.fromList([0x01, 0x02, 0x03]);
    }

    expect(() => serializer.deserialize(invalidData), throwsException);
  });
}
