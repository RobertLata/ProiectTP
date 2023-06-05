import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:proiect_ip_flutter/no_disponibility.dart';

import 'chat_page.dart';

class RobotAvailabilityPage extends StatelessWidget {
  final BluetoothDevice server;
  final String patientId;
  const RobotAvailabilityPage(
      {Key? key, required this.server, required this.patientId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: FutureBuilder<bool>(
            future: _isRobotAvailable(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(
                  child: Text('Something went wrong. Please try again later!'),
                );
              } else if (snapshot.hasData) {
                return snapshot.data == true
                    ? const NoAvailability()
                    : ChatPage(
                        server: server,
                        patientId: patientId,
                      );
              }
              return const Center(
                child: CircularProgressIndicator(),
              );
            }));
  }

  Future<bool> _isRobotAvailable() async {
    bool fieldValue = false;

    try {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('robot') // Replace with your collection name
          .doc('robotID') // Replace with your document ID
          .get();

      if (documentSnapshot.exists) {
        // Document exists
        fieldValue = documentSnapshot.get('isRemote');
        // Use the field value as needed
        print('Field value: $fieldValue');
      } else {
        // Document does not exist
        print('Document does not exist');
      }
    } catch (error) {
      print('Error accessing field value: $error');
    }
    return fieldValue;
  }
}
