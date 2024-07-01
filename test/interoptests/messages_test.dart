import "package:collection/collection.dart";
import "package:pinenacl/api.dart";
import "package:test/test.dart";

import "package:wampproto/messages.dart";
import "package:wampproto/serializers.dart";

import "helper.dart";

void main() {
  group("Messages", () {
    const equality = DeepCollectionEquality();
    const testProcedure = "io.xconn.test";

    var jsonSerializer = JSONSerializer();
    var cborSerializer = CBORSerializer();
    var msgPackSerializer = MsgPackSerializer();

    group("Call", () {
      bool isEqual(Call msg1, Call msg2) =>
          msg1.requestID == msg2.requestID &&
          msg1.uri == msg2.uri &&
          equality.equals(msg1.options, msg2.options) &&
          equality.equals(msg1.args, msg2.args) &&
          equality.equals(msg1.kwargs, msg2.kwargs);

      test("JSONSerializer", () async {
        var callMessage = Call(1, testProcedure);
        var command = "message call ${callMessage.requestID} ${callMessage.uri} --serializer json";

        var output = await runCommand(command);

        var message = jsonSerializer.deserialize(output) as Call;
        expect(isEqual(message, callMessage), true);
      });

      test("CBORSerializer", () async {
        var callMessage = Call(1, testProcedure, args: ["abc"]);
        var command = "message call ${callMessage.requestID} ${callMessage.uri} abc --serializer cbor --output hex";

        var output = await runCommand(command);
        var outputBytes = Base16Encoder.instance.decode(output.trim());

        var message = cborSerializer.deserialize(outputBytes) as Call;
        expect(isEqual(message, callMessage), true);
      });

      test("MsgPackSerializer", () async {
        var callMessage = Call(1, testProcedure, args: ["abc"], kwargs: {"a": 1});
        var command =
            "message call ${callMessage.requestID} ${callMessage.uri} abc -k a=1 --serializer msgpack --output hex";

        var output = await runCommand(command);
        var outputBytes = Base16Encoder.instance.decode(output.trim());

        var message = msgPackSerializer.deserialize(outputBytes) as Call;
        expect(isEqual(message, callMessage), true);
      });
    });
  });
}
