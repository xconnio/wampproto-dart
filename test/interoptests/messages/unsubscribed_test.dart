import "package:pinenacl/encoding.dart";
import "package:test/test.dart";

import "package:wampproto/messages.dart";
import "package:wampproto/serializers.dart";

import "../helper.dart";

void main() {
  group("Unsubscribed", () {
    bool isEqual(Unsubscribed msg1, Unsubscribed msg2) => msg1.requestID == msg2.requestID;

    test("JSONSerializer", () async {
      var msg = Unsubscribed(1);
      var command = "message unsubscribed ${msg.requestID} --serializer json";

      var output = await runCommand(command);

      var jsonSerializer = JSONSerializer();
      var message = jsonSerializer.deserialize(output) as Unsubscribed;
      expect(isEqual(message, msg), true);
    });

    test("CBORSerializer", () async {
      var msg = Unsubscribed(1);
      var command = "message unsubscribed ${msg.requestID} --serializer cbor --output hex";

      var output = await runCommand(command);
      var outputBytes = Base16Encoder.instance.decode(output.trim());

      var cborSerializer = CBORSerializer();
      var message = cborSerializer.deserialize(outputBytes) as Unsubscribed;
      expect(isEqual(message, msg), true);
    });

    test("MsgPackSerializer", () async {
      var msg = Unsubscribed(1);
      var command = "message unsubscribed ${msg.requestID} --serializer msgpack --output hex";

      var output = await runCommand(command);
      var outputBytes = Base16Encoder.instance.decode(output.trim());

      var msgPackSerializer = MsgPackSerializer();
      var message = msgPackSerializer.deserialize(outputBytes) as Unsubscribed;
      expect(isEqual(message, msg), true);
    });
  });
}
