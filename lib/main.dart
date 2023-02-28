import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:bot_brain/blutooth_device_item.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Bot Brain',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: MyHomePage(),
      );
}

class MyHomePage extends StatefulWidget {
  final FlutterBluePlus flutterBlue = FlutterBluePlus.instance;
  final List<ScanResult> devicesList = <ScanResult>[];

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  _MyHomePageState();

  bool _bluetoothEnabled = false;

  void checkBluetoothPermission() async {
    // Check Bluetooth permission
    FlutterBluePlus.instance.state.listen((event) {
      setState(() {
        _bluetoothEnabled = event == BluetoothState.on;
      });
    });

    if (!_bluetoothEnabled) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Permissions Required'),
          content: const Text(
              'This app requires Bluetooth and Nearby Devices permissions to function properly.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Platform.isAndroid ? FlutterBluePlus.instance.turnOn() : null;
                Navigator.of(context).pop();
              },
              child: Text(Platform.isAndroid ? "TURN ON" : "OK"),
            ),
          ],
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    checkBluetoothPermission();
  }

  ListView _buildListViewOfDevices() {
    List<Widget> containers = <Widget>[];
    widget.devicesList.sort((a, b) => b.rssi - a.rssi);

    for (ScanResult device in widget.devicesList) {
      containers.add(BluetoothDeviceItem(device));
    }

    return ListView(
      padding: const EdgeInsets.all(8),
      children: <Widget>[
        ...containers,
      ],
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: const Text("Bot Brain"),
        actions: [
          IconButton(
              onPressed: startScanningDevices, icon: const Icon(Icons.refresh))
        ],
      ),
      body: _bluetoothEnabled
          ? _buildListViewOfDevices()
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Bluetooth Enabled: $_bluetoothEnabled'),
              ],
            ));

  void startScanningDevices() {
    checkBluetoothPermission();
    setState(() {
      widget.devicesList.clear();
    });
    widget.flutterBlue.startScan(timeout: const Duration(seconds: 5));
    widget.flutterBlue.scanResults.listen((results) {
      for (var element in results) {
        if (!widget.devicesList.contains(element)) {
          setState(() {
            widget.devicesList.add(element);
          });
        }
      }
    });
  }
}