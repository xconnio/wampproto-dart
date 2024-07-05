import "package:pinenacl/encoding.dart";
import "package:test/test.dart";

import "package:wampproto/messages.dart";
import "package:wampproto/serializers.dart";

import "../helper.dart";

void main() {
  group("Unregistered", () {
    bool isEqual(Unregistered msg1, Unregistered msg2) => msg1.requestID == msg2.requestID;

    test("JSONSerializer", () async {
      var msg = Unregistered(1);
      var command = "message unregistered ${msg.requestID} --serializer json";

      var output = await runCommand(command);

      var jsonSerializer = JSONSerializer();
      var message = jsonSerializer.deserialize(output) as Unregistered;
      expect(isEqual(message, msg), true);
    });

    test("CBORSerializer", () async {
      var msg = Unregistered(1);
      var command = "message unregistered ${msg.requestID} --serializer cbor --output hex";

      var output = await runCommand(command);
      var outputBytes = Base16Encoder.instance.decode(output.trim());

      var cborSerializer = CBORSerializer();
      var message = cborSerializer.deserialize(outputBytes) as Unregistered;
      expect(isEqual(message, msg), true);
    });

    test("MsgPackSerializer", () async {
      var msg = Unregistered(1);
      var command = "message unregistered ${msg.requestID} --serializer msgpack --output hex";

      var output = await runCommand(command);
      var outputBytes = Base16Encoder.instance.decode(output.trim());

      var msgPackSerializer = MsgPackSerializer();
      var message = msgPackSerializer.deserialize(outputBytes) as Unregistered;
      expect(isEqual(message, msg), true);
    });
  });
}
