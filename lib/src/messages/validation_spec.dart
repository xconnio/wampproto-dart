import "package:wampproto/src/messages/util.dart";

class ValidationSpec {
  ValidationSpec({
    required this.minLength,
    required this.maxLength,
    required this.message,
    required this.spec,
  });

  final int minLength;
  final int maxLength;
  final String message;
  final Map<int, String? Function(List<dynamic> message, int index, Fields fields, String msgType)> spec;
}
