abstract class Message {
  factory Message.sender(String value, DateTime dateTime) = Sender;

  factory Message.receiver(String value, DateTime dateTime) = Receiver;

  get dateTime => dateTime;
  get value => value;
}

class Sender implements Message {
  final String value;
  final DateTime dateTime;
  Sender(this.value, this.dateTime);
}

class Receiver implements Message {
  final String value;
  final DateTime dateTime;

  Receiver(this.value, this.dateTime);
}
