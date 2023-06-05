import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class BluetoothDeviceListEntry extends StatelessWidget {
  final Function() onTap;
  final BluetoothDevice device;
  final bool enabled;
  final int rssi;

  const BluetoothDeviceListEntry(
      {Key? key,
      required this.onTap,
      required this.device,
      required this.rssi,
      required this.enabled})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: const Icon(Icons.devices),
      title: Text(device.name ?? "Unknown device"),
      subtitle: Text(device.address.toString()),
      trailing: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(backgroundColor: Colors.greenAccent),
        child: const Text(
          'Connect',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
