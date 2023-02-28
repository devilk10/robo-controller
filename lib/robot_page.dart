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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.device.name), actions: <Widget>[
        TextButton(
          child: Text("Connect"),
          onPressed: () {
            // listenStream();
          },
        ),
      ]),
      body: ListView.builder(
        itemCount: widget.inputStream.length,
        itemBuilder: (context, index) {
          return Padding(
            padding:
                const EdgeInsets.only(left: 15, top: 3, bottom: 3, right: 15),
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
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    listenStream();
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
            setState(() {
              widget.inputStream.add(utf8.decode(value));
            });
            print("imptan - input is -----> ${utf8.decode(value)}");
          });
        }
      }
    }
  }
}
