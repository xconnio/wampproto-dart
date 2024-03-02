import 'package:wampproto/messages.dart';
import 'package:test/test.dart';

void main() {
  test("test parse", testParse);
}

void testParse() {
  var hello = Hello.parse([1, "realm1"]);
  expect(hello.realm, "realm1");
  expect(hello.messageType(), 1);
}
