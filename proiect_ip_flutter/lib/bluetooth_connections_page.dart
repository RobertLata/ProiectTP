import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:proiect_ip_flutter/orders_page.dart';

import 'bonded_device_page.dart';
import 'main.dart';

class BluetoothConnections extends StatelessWidget {
  const BluetoothConnections({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        centerTitle: true,
        title: const Text(
          'Bluetooth Connections',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SelectBondedDevicePage(
              onChatPage: (device1) {
                BluetoothDevice device = device1;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return OrdersPage(server: device);
                    },
                  ),
                );
              },
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const MainPage()),
                  (route) => false);
            },
            icon: const Icon(
              Icons.arrow_back,
              size: 20,
              color: Colors.white,
            ),
            label: const Text(
              'Sign out',
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: Colors.blue),
          ),
        ],
      ),
    ));
  }
}
