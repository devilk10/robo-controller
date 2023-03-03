import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'message.dart';
import 'message_item.dart';

class RobotPage extends StatefulWidget {
  BluetoothDevice device;

  RobotPage(this.device);

  @override
  State<StatefulWidget> createState() => RobotPageState(device);
}

class RobotPageState extends State<RobotPage> {
  final TextEditingController _textController = TextEditingController();
  final List<Message> _inputStream = <Message>[];

  BluetoothDevice device;

  final ScrollController _scrollController = ScrollController();

  BluetoothCharacteristic? _characteristic;

  RobotPageState(this.device);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _onBackPressed,
        child: Scaffold(
            appBar: AppBar(
              title: Text(device.name),
              leading: GestureDetector(
                  onTap: _onBackPressed, child: const Icon(Icons.arrow_back)),
            ),
            body: Column(
              children: [
                Flexible(
                    child: ListView.builder(
                  controller: _scrollController,
                  itemCount: _inputStream.length,
                  itemBuilder: (context, index) =>
                      MessageItem(_inputStream[index]),
                )),
                sendMessageBox()
              ],
            )));
  }

  Align sendMessageBox() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: const EdgeInsets.all(16.0),
        child: TextField(
          controller: _textController,
          decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              hintText: "Type your command ..."),
          onSubmitted: (String text) => sendMessage(text),
        ),
      ),
    );
  }

  void sendMessage(String text) {
    return setState(() {
      _textController.clear();
      addToLocalList(Sender(text, DateTime.now(), MessageType.COMMAND));
      writeDataToDevice(text);
    });
  }

  Future<void> writeDataToDevice(String text) async {
    print(
        "imptan --->>> writing $text on ${_characteristic?.uuid.toString().substring(4, 8)} ");
    List<int> messageBytes = utf8.encode(text);
    await _characteristic?.write(messageBytes);
  }

  @override
  void initState() {
    super.initState();
    subscribeStream();
  }

  Future<void> subscribeStream() async {
    var hasCharacteristic = await setCharacteristic();
    hasCharacteristic ? listenCharacteristicData(_characteristic!) : null;
  }

  Future<bool> _onBackPressed() {
    return showDialog(
      context: context,
      builder: (context) => alertDialog(context),
    ).then((value) => value ?? false);
  }

  AlertDialog alertDialog(BuildContext context) {
    return AlertDialog(
      title: const Text(
          'This will disconnect the device, do you really want to exit ?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('No'),
        ),
        TextButton(
          onPressed: () {
            device.disconnect();
            Navigator.pop(context, true);
            return Navigator.pop(context, true);
          },
          child: const Text('Yes'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<bool> setCharacteristic() async {
    List<BluetoothService> services = await device.discoverServices();
    for (BluetoothService service in services) {
      for (BluetoothCharacteristic characteristic in service.characteristics) {
        if (characteristic.uuid.toString() ==
            '0000ffe1-0000-1000-8000-00805f9b34fb') {
          print(
              "imptan --->>> connected to ${characteristic.uuid.toString().substring(4, 8)}");
          _characteristic = characteristic;
          return true;
        }
      }
    }
    return false;
  }

  Future<void> listenCharacteristicData(
      BluetoothCharacteristic characteristic) async {
    {
      await characteristic.setNotifyValue(true);
      StreamSubscription notificationStream;
      notificationStream = characteristic.value.listen((value) {
        var decodeValue = utf8.decode(value);
        print(
            "imptan --->>> received from ${characteristic.uuid.toString().substring(4, 8)} - $decodeValue");
        if (decodeValue.isNotEmpty) {
          addToLocalList(messageHandler(decodeValue)!);
        }
      });
    }
  }

  Receiver? messageHandler(String decodedMessage) {
    var type = decodedMessage.substring(
        decodedMessage.lastIndexOf("_") + 1, decodedMessage.length);
    String trimmedText = decodedMessage.substring(0, decodedMessage.length - 2);
    switch (type) {
      case 'D':
        return Receiver(trimmedText, DateTime.now(), MessageType.DATA);
      case 'E':
        return Receiver(trimmedText, DateTime.now(), MessageType.ERROR_LOG);
      case 'G':
        return Receiver(trimmedText, DateTime.now(), MessageType.DEBUG_LOG);
    }
    return null;
  }

  void addToLocalList(Message message) {
    setState(() {
      _inputStream.add(message);
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent + 1);
    });
  }
}
