import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'message.dart';

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
                  onTap: _onBackPressed,
                  child: const Icon(Icons.arrow_back)),
            ),
            body: Column(
              children: [
                Flexible(
                    child: ListView.builder(
                  controller: _scrollController,
                  itemCount: _inputStream.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(
                          left: 15, top: 3, bottom: 3, right: 15),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.grey,
                              width: 1.0,
                            ),
                          ),
                        ),
                        child: Text(
                          _inputStream[index].value,
                          style: (_inputStream[index] is Sender)? const TextStyle(
                            fontSize: 16.0,
                            color: Colors.green,
                          ) : const TextStyle(
                            fontSize: 16.0,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    );
                  },
                )),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    margin: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Expanded(
                            child: TextField(
                          controller: _textController,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              hintText: "Type your command ..."),
                          // Todo remove expanded if send button is not required
                          onSubmitted: (String text) => {
                            setState(() {
                              _inputStream.add(Sender(text));
                              writeDataToDevice(text);
                              _textController.clear();
                            })
                          },
                        )),
                      ],
                    ),
                  ),
                )
              ],
            )));
  }

  Future<void> writeDataToDevice(String text) async {
    List<int> messageBytes = utf8.encode(text);
    print("imptan --> writing $text on ${_characteristic?.uuid} ");
    await _characteristic?.write(messageBytes);
    print("Message sent to HM10: $messageBytes");
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
      builder: (context) => AlertDialog(
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
      ),
    ).then((value) => value ?? false);
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
        print("imptan --->>>>>>> $decodeValue");
        if (decodeValue.isNotEmpty) {
          setState(() {
            _inputStream.add(Receiver(decodeValue));
            _scrollController
                .jumpTo(_scrollController.position.maxScrollExtent + 1);
          });
        }
      });
    }
  }
}