import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

import 'bluetooth_connections_page.dart';

class DeviceRequestWidget extends StatefulWidget {
  const DeviceRequestWidget({Key? key}) : super(key: key);

  @override
  State<DeviceRequestWidget> createState() => _DeviceRequestWidgetState();
}

class _DeviceRequestWidgetState extends State<DeviceRequestWidget> {
  late final Future<bool?> _futureBluetoothRequest;
  @override
  void initState() {
    super.initState();
    _futureBluetoothRequest = _bluetoothRequestEnable();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool?>(
      future: _futureBluetoothRequest,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: SizedBox(
              height: double.infinity,
              child: Center(
                child: Icon(
                  Icons.bluetooth_disabled,
                  size: 200.0,
                  color: Colors.black12,
                ),
              ),
            ),
          );
        } else if (snapshot.hasData) {
          return const BluetoothConnections();
        } else if (snapshot.hasError) {
          return const Scaffold(
            body: SizedBox(
              height: double.infinity,
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.error,
                      size: 200.0,
                      color: Colors.black12,
                    ),
                    Text('Error when trying to find bluetooth devices'),
                  ],
                ),
              ),
            ),
          );
        }
        return const Scaffold(
          body: SizedBox(
            height: double.infinity,
            child: Center(
              child: Icon(
                Icons.bluetooth_disabled,
                size: 200.0,
                color: Colors.black12,
              ),
            ),
          ),
        );
      },
    );
  }

  Future<bool?> _bluetoothRequestEnable() async {
    try {
      return await FlutterBluetoothSerial.instance.requestEnable();
    } catch (e) {
      print('Error enabling Bluetooth: $e');
      return null;
    }
  }
}