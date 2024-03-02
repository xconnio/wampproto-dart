import 'dart:convert';
import 'dart:typed_data';

import 'package:wampproto/src/messages/message.dart';
import 'package:wampproto/src/serializers/serializer.dart';

class JsonSerializer implements Serializer {
  @override
  Uint8List serialize(Message message) {
    var jsonString = jsonEncode(message.marshal());
    return Uint8List.fromList(jsonString.codeUnits);
  }

  @override
  Message deserialize(Uint8List message) {
    String s = String.fromCharCodes(message);

    List<dynamic> wampMessage = jsonDecode(s);
    return toMessage(wampMessage);
  }
}
