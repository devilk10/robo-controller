import 'package:flutter/cupertino.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class RobotPage extends StatefulWidget {
  BluetoothDevice device;

  RobotPage(this.device, {super.key});

  @override
  State<StatefulWidget> createState() {
    return RobotPageState();
  }
}

class RobotPageState extends State<RobotPage> {
  @override
  Widget build(BuildContext context) {
    return Text(widget.device.name);
  }
}
