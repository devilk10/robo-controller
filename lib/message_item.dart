import 'package:bot_brain/message.dart';
import 'package:bubble/bubble.dart';
import 'package:flutter/material.dart';

class MessageItem extends StatelessWidget {
  final Message message;

  MessageItem(this.message);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(left: 10, top: 2, bottom: 2, right: 10),
        child: Container(
            padding: const EdgeInsets.all(3),
            child: (message is Receiver)
                ? receivedMessage(message)
                : sentMessage(message)));
  }

  Widget receivedMessage(Message item) {
    return Bubble(
      color: Colors.grey[300],
      alignment: Alignment.topLeft,
      nip: BubbleNip.leftBottom,
      child: Text(item.value),
    );
  }

  Widget sentMessage(Message item) {
    return Bubble(
      color: Colors.blue[400],
      alignment: Alignment.topRight,
      nip: BubbleNip.rightBottom,
      child: Text(
        item.value,
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}
