import "dart:io";

import "package:test/test.dart";

Future<String> runCommand(String command) async {
  ProcessResult result = await Process.run("wampproto", command.split(" "));
  expect(result.exitCode, 0, reason: result.stderr);

  return result.stdout;
}
