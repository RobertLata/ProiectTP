import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:proiect_ip_flutter/orders_page.dart';

class OrderStatePage extends StatefulWidget {
  final bool isOrderFinished;
  final BluetoothDevice server;
  const OrderStatePage(
      {Key? key, required this.isOrderFinished, required this.server})
      : super(key: key);

  @override
  State<OrderStatePage> createState() => _OrderStatePageState();
}

class _OrderStatePageState extends State<OrderStatePage> {
  bool isRemote = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Center(
                child: Text(
                  widget.isOrderFinished
                      ? "The order is finished"
                      : "The order is unfinished",
                  style: TextStyle(
                      fontSize: 24,
                      color:
                          widget.isOrderFinished ? Colors.green : Colors.red),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
              child: Center(
                child: Text(
                  'Remote control:',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
            Center(
              child: Switch(
                activeColor: Colors.blue,
                activeTrackColor: Colors.green,
                inactiveThumbColor: Colors.blueGrey.shade600,
                inactiveTrackColor: Colors.grey.shade400,
                splashRadius: 50.0,
                value: isRemote,
                onChanged: (value) {
                  setState(() => isRemote = value);
                  final docPatient = FirebaseFirestore.instance
                      .collection('robot')
                      .doc('robotID');
                  docPatient.update({'isRemote': isRemote});
                },
              ),
            ),
            Visibility(
              visible: widget.isOrderFinished == false,
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
                child: Center(
                  child: Text(
                    'Crash report:',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ),
            Visibility(
              visible: widget.isOrderFinished == false,
              child: Center(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final docUser =
                    FirebaseFirestore.instance.collection('robot').doc('crashID');
                    final json = {
                      'crash': 'Crash',
                    };

                    await docUser.set(json);
                    const snackBar = SnackBar(
                      content: Text('A crash message has been sent'),
                      backgroundColor: Colors.redAccent,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  },
                  icon: const Icon(
                    Icons.send,
                    size: 20,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'Send',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent),
                ),
              ),
            ),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) =>
                          OrdersPage(server: widget.server)));
                },
                icon: const Icon(
                  Icons.arrow_back,
                  size: 20,
                  color: Colors.white,
                ),
                label: const Text(
                  'Back to orders',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
