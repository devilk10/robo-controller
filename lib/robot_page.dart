import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class RobotPage extends StatefulWidget {
  BluetoothDevice device;

  RobotPage(this.device);

  final List<String> inputStream = <String>[];

  @override
  State<StatefulWidget> createState() {
    return RobotPageState();
  }
}

class RobotPageState extends State<RobotPage> {
  final TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _onBackPressed,
        child: Scaffold(
            appBar: AppBar(
              title: Text(widget.device.name),
              actions: <Widget>[
                TextButton(
                  child: Text("Connect"),
                  onPressed: () {
                    // listenStream();
                  },
                ),
              ],
              leading: GestureDetector(
                  child: Icon(Icons.arrow_back), onTap: _onBackPressed),
            ),
            body: Column(
              children: [
                Flexible(
                    child: ListView.builder(
                  itemCount: widget.inputStream.length,
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
                          widget.inputStream[index],
                          style: const TextStyle(
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
                        )),
                        IconButton(
                            icon: const Icon(Icons.send),
                            onPressed: () => {
                                  setState(() {
                                    _textController.clear();
                                  })
                                })
                      ],
                    ),
                  ),
                )
              ],
            )));
  }

  @override
  void initState() {
    super.initState();
    listenStream();
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
              widget.device.disconnect();
              Navigator.pop(context, true);
              return Navigator.pop(context, true);
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    ).then((value) => value ?? false);
  }

  Future<void> listenStream() async {
    List<BluetoothService> services = await widget.device.discoverServices();

    for (BluetoothService service in services) {
      for (BluetoothCharacteristic characteristic in service.characteristics) {
        if (characteristic.uuid.toString() ==
            '0000ffe1-0000-1000-8000-00805f9b34fb') {
          await characteristic.setNotifyValue(true);
          StreamSubscription notificationStream;
          notificationStream = characteristic.value.listen((value) {
            var decodeValue = utf8.decode(value);
            if (decodeValue.isNotEmpty) {
              setState(() {
                widget.inputStream.add(decodeValue);
              });
            }
          });
        }
      }
    }
  }
}
