import 'package:bot_brain/robot_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothDeviceItem extends StatefulWidget {
  final ScanResult device;

  const BluetoothDeviceItem(this.device);

  @override
  State<StatefulWidget> createState() {
    return BluetoothDeviceItemState(device);
  }
}

class BluetoothDeviceItemState extends State<BluetoothDeviceItem> {
  final ScanResult device;

  BluetoothDeviceItemState(this.device);

  var _isConnecting = false;
  var _isConnected = false;

  Future<void> connect(ScanResult result) async {
    try {
      print("Connected to device: ${result.device.name}");
      await result.device.connect().then((value) {});
      //TODO stop scan
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => RobotPage(result.device)));
    } on PlatformException catch (e) {
      print("imptan - error");
      if (e.code != 'already_connected') {
        rethrow;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 70,
        child: Padding(
          padding: const EdgeInsets.only(top: 5, bottom: 5),
          child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Container(
                color: Colors.grey[100],
                height: 50,
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: <Widget>[
                    Container(
                        height: 75,
                        width: 75,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle, color: Colors.grey[500]),
                        child: Center(
                            child: Text(
                          "${device.rssi}",
                          style: const TextStyle(
                              color: Colors.white, fontSize: 15),
                        ))),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(device.device.name == ''
                              ? '(unknown device)'
                              : device.device.name),
                          Text(
                            device.device.id.toString(),
                            style: TextStyle(color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    ),
                    _isConnecting
                        ? const CircularProgressIndicator()
                        : TextButton(
                            child: Text(
                              _isConnected ? 'Connected' : 'Connect',
                              style: const TextStyle(color: Colors.blue),
                            ),
                            onPressed: () async {
                              setState(() {
                                _isConnecting = true;
                              });
                              connect(device);
                              setState(() {
                                _isConnected = true;
                              });
                              // widget.flutterBlue.stopScan();
                            },
                          ),
                  ],
                ),
              )),
        ));
  }
}
