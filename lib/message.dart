abstract class Message {
  factory Message.sender(String value, DateTime dateTime, MessageType type) =
      Sender;

  factory Message.receiver(String value, DateTime dateTime, MessageType type) =
      Receiver;

  get dateTime => dateTime;

  get value => value;

  get type => type;
}

class Sender implements Message {
  final String value;
  final DateTime dateTime;
  final MessageType type;

  Sender(this.value, this.dateTime, this.type);
}

class Receiver implements Message {
  final String value;
  final DateTime dateTime;
  final MessageType type;

  Receiver(this.value, this.dateTime, this.type);
}

enum MessageType { DEBUG_LOG, ERROR_LOG, DATA, COMMAND }
