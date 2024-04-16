import "package:test/test.dart";
import "package:wampproto/messages.dart";
import "package:wampproto/serializers.dart";

void main() {
  test("test serialize and deserialize", testJson);
}

void testJson() {
  var hello = Hello.parse([1, "realm1"]);

  var serializer = JSONSerializer();
  var data = serializer.serialize(hello);

  var obj = serializer.deserialize(data);
  if (obj.messageType() != 1) {
    fail("message");
  }

  var deserialized = obj as Hello;

  expect(hello.realm, deserialized.realm);
  expect(hello.messageType(), deserialized.messageType());
}
