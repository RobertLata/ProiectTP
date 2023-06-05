import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

import 'bluetooth_device.dart';

class SelectBondedDevicePage extends StatefulWidget {
  /// If true, on page start there is performed discovery upon the bonded devices.
  /// Then, if they are not available, they would be disabled from the selection.
  final bool checkAvailability;
  final Function onChatPage;

  const SelectBondedDevicePage(
      {this.checkAvailability = true, required this.onChatPage});

  @override
  State<SelectBondedDevicePage> createState() => _SelectBondedDevicePage();
}

enum _DeviceAvailability {
  no,
  maybe,
  yes,
}

class _DeviceWithAvailability extends BluetoothDevice {
  BluetoothDevice device;
  _DeviceAvailability availability;
  int rssi;

  _DeviceWithAvailability(
      {required this.device, required this.availability, required this.rssi})
      : super(address: '');
}

class _SelectBondedDevicePage extends State<SelectBondedDevicePage> {
  List<_DeviceWithAvailability> devices = <_DeviceWithAvailability>[];

  // Availability
  StreamSubscription<BluetoothDiscoveryResult>? _discoveryStreamSubscription;
  late bool _isDiscovering = widget.checkAvailability;

  @override
  void initState() {
    super.initState();

    if (_isDiscovering) {
      _startDiscovery();
    }

    // Setup a list of the bonded devices
    FlutterBluetoothSerial.instance
        .getBondedDevices()
        .then((List<BluetoothDevice> bondedDevices) {
      setState(() {
        devices = bondedDevices
            .map(
              (device) => _DeviceWithAvailability(
                device: device,
                availability: widget.checkAvailability
                    ? _DeviceAvailability.maybe
                    : _DeviceAvailability.yes,
                rssi: 0,
              ),
            )
            .toList();
      });
    });
  }

  void _startDiscovery() {
    _discoveryStreamSubscription =
        FlutterBluetoothSerial.instance.startDiscovery().listen(
      (r) {
        setState(() {
          Iterator i = devices.iterator;
          while (i.moveNext()) {
            var device = i.current;
            if (device.device == r.device) {
              device.availability = _DeviceAvailability.yes;
              device.rssi = r.rssi;
            }
          }
        });
      },
      onError: (error) {
        // Handle error
        print('Bluetooth discovery error: $error');
        setState(() {
          _isDiscovering = false;
        });
      },
      onDone: () {
        setState(() {
          _isDiscovering = false;
        });
      },
    );
  }

  @override
  void dispose() {
    // Avoid memory leak (`setState` after dispose) and cancel discovery
    _discoveryStreamSubscription?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<BluetoothDeviceListEntry> list = devices
        .map(
          (device) => BluetoothDeviceListEntry(
            device: device.device,
            rssi: device.rssi,
            enabled: device.availability == _DeviceAvailability.yes,
            onTap: () {
              widget.onChatPage(device.device);
            },
          ),
        )
        .toList();
    return ListView(
      children: list,
    );
  }
}
