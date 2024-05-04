import "package:test/test.dart";
import "package:wampproto/messages.dart";
import "package:wampproto/src/serializers/msgpack.dart";

void main() {
  test("test serialize and deserialize", testMsgPack);
}

void testMsgPack() {
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

  var serializer = MsgPackSerializer();
  var data = serializer.serialize(hello);

  var obj = serializer.deserialize(data);
  if (obj.messageType() != 1) {
    fail("message");
  }

  var deserialized = obj as Hello;

  expect(hello.realm, deserialized.realm);
  expect(hello.messageType(), deserialized.messageType());
}
