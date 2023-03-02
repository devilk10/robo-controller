abstract class Message {
  factory Message.sender(String value) = Sender;
  factory Message.receiver(String value) = Receiver;
  get value;
}

class Sender implements Message {
  final String value;
  Sender(this.value);
}

class Receiver implements Message {
  final String value;
  Receiver(this.value);
}
