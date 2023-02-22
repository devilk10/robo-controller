import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

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
        home: MyHomePage(title: 'Bot Brain'),
      );
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;
  final FlutterBluePlus flutterBlue = FlutterBluePlus.instance;
  final List<ScanResult> devicesList = <ScanResult>[];

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  _MyHomePageState();

  _addDeviceTolist(final ScanResult device) {
    if (!widget.devicesList.contains(device)) {
      setState(() {
        widget.devicesList.add(device);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    widget.flutterBlue.scanResults.listen((results) {
      print("imptan - started listening");
      for (ScanResult result in results) {
        print('imptan - ${result.device.name} found! rssi: ${result.rssi}');
        _addDeviceTolist(result);
      }
    });
    widget.flutterBlue.startScan();
  }

  ListView _buildListViewOfDevices() {
    List<Widget> containers = <Widget>[];
    widget.devicesList.sort((a, b) => b.rssi - a.rssi);

    for (ScanResult device in widget.devicesList) {
      containers.add(SizedBox(
          height: 65,
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
                      TextButton(
                        child: const Text(
                          'Connect',
                          style: TextStyle(color: Colors.blue),
                        ),
                        onPressed: () async {
                          widget.flutterBlue.stopScan();
                        },
                      ),
                    ],
                  ),
                )),
          )));
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
        title: Text(widget.title),
      ),
      body: _buildListViewOfDevices());
}
