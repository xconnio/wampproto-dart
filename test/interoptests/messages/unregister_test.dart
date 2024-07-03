import "package:pinenacl/encoding.dart";
import "package:test/test.dart";

import "package:wampproto/messages.dart";
import "package:wampproto/serializers.dart";

import "../helper.dart";

void main() {
  group("UnRegister", () {
    bool isEqual(UnRegister msg1, UnRegister msg2) =>
        msg1.requestID == msg2.requestID && msg1.registrationID == msg2.registrationID;

    test("JSONSerializer", () async {
      var msg = UnRegister(1, 1);
      var command = "message unregister ${msg.requestID} ${msg.registrationID} --serializer json";

      var output = await runCommand(command);

      var jsonSerializer = JSONSerializer();
      var message = jsonSerializer.deserialize(output) as UnRegister;
      expect(isEqual(message, msg), true);
    });

    test("CBORSerializer", () async {
      var msg = UnRegister(1, 1);
      var command = "message unregister ${msg.requestID} ${msg.registrationID} --serializer cbor --output hex";

      var output = await runCommand(command);
      var outputBytes = Base16Encoder.instance.decode(output.trim());

      var cborSerializer = CBORSerializer();
      var message = cborSerializer.deserialize(outputBytes) as UnRegister;
      expect(isEqual(message, msg), true);
    });

    test("MsgPackSerializer", () async {
      var msg = UnRegister(1, 1);
      var command = "message unregister ${msg.requestID} ${msg.registrationID} --serializer msgpack --output hex";

      var output = await runCommand(command);
      var outputBytes = Base16Encoder.instance.decode(output.trim());

      var msgPackSerializer = MsgPackSerializer();
      var message = msgPackSerializer.deserialize(outputBytes) as UnRegister;
      expect(isEqual(message, msg), true);
    });
  });
}
