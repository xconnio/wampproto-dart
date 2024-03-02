abstract class Message {
  int messageType();

  List<dynamic> marshal();
}
