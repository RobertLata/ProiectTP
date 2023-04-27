import 'package:flutter/material.dart';
import 'package:proiect_ip_flutter/home_page.dart';

class SelectBondedDevice extends StatefulWidget {
  const SelectBondedDevice({Key? key}) : super(key: key);

  @override
  State<SelectBondedDevice> createState() => _SelectBondedDeviceState();
}

class _SelectBondedDeviceState extends State<SelectBondedDevice> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: SafeArea(
          child: Column(
        children: [
          const Text('BondedDevicePage'),
          IconButton(
              onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const HomePage())),
              icon: const Icon(Icons.home)),
        ],
      )),
    );
  }
}
