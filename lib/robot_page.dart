import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class RobotPage extends StatefulWidget {
  BluetoothDevice device;

  RobotPage(this.device, {super.key});

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
      appBar: AppBar(title: Text(widget.device.name)),
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
        List<int> value = await characteristic.read();
        print("imptan characteristic :  $value");

        for (BluetoothDescriptor d in characteristic.descriptors) {
          List<int> value = await d.read();
          print("imptan descriptors: $value");
        }
        characteristic.setNotifyValue(true);
        characteristic.value.listen((value) {
          // process the data from the input stream
          setState(() {
            widget.inputStream.add(value.toString());
          });
          print("imptan Received data: $value");
        });
      }
    }
  }
}
