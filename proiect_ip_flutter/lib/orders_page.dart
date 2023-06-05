import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:proiect_ip_flutter/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proiect_ip_flutter/robot_availability_page.dart';
import 'package:proiect_ip_flutter/models/order.dart';

class OrdersPage extends StatefulWidget {
  final BluetoothDevice server;
  const OrdersPage({Key? key, required this.server}) : super(key: key);

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  bool didPressOnOrder = false;
  int selectedIndex = -1;
  String _patientId = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: StreamBuilder<List<TreatmentOrder>>(
          stream: _readOrders(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(
                child: Text('Something went wrong. Please try again later!'),
              );
            } else if (snapshot.hasData) {
              final patients = snapshot.data!;
              return Scaffold(
                backgroundColor: Colors.white,
                bottomNavigationBar: ElevatedButton.icon(
                  onPressed: () {
                    FirebaseAuth.instance.signOut();
                    Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                            builder: (context) => const MainPage()),
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
                body: SafeArea(
                  child: ListView(
                    children: [
                      const Align(
                          alignment: Alignment.topRight,
                          child: Image(
                            image: AssetImage('images/MedX.jpeg'),
                            height: 100,
                            width: 100,
                          )),
                      !didPressOnOrder
                          ? const Padding(
                              padding: EdgeInsets.only(left: 20.0),
                              child: Text(
                                'Orders: ',
                                style: TextStyle(fontSize: 24),
                              ),
                            )
                          : const SizedBox(),
                      !didPressOnOrder
                          ? ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: patients.length,
                              itemBuilder: (context, index) =>
                                  _buildPatientInfo(patients[index], index))
                          : Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(20.0),
                                color: Colors.green,
                                child: Text(
                                  "Medicine: ${patients[selectedIndex].medicine}",
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 20),
                                ),
                              ),
                            ),
                      Visibility(
                        visible: didPressOnOrder,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 40.0),
                          child: Center(
                              child: Column(
                            children: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          RobotAvailabilityPage(
                                        server: widget.server,
                                        patientId: _patientId,
                                      ),
                                    ),
                                  );
                                },
                                style: TextButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor: Colors.blue),
                                child: const Text('Take the order'),
                              ),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    didPressOnOrder = false;
                                    selectedIndex = -1;
                                  });
                                },
                                style: TextButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor: Colors.blue),
                                child: const Text('Select another order'),
                              ),
                            ],
                          )),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          }),
    );
  }

  Stream<List<TreatmentOrder>> _readOrders() => FirebaseFirestore.instance
      .collection('orders')
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => TreatmentOrder.fromJson(doc.data()))
          .toList());

  Widget _buildPatientInfo(TreatmentOrder patient, int index) => !patient
          .isOrderFinished
      ? Padding(
          padding: const EdgeInsets.all(20.0),
          child: InkWell(
            onTap: () {
              setState(() {
                selectedIndex = index;
                didPressOnOrder = true;
                _patientId = patient.id;
              });
            },
            child: Container(
              color: Colors.blue,
              width: double.infinity,
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Text(
                    "First name: ${patient.patientFirstName}",
                    style: const TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  Text(
                    "Last name: ${patient.patientLastName}",
                    style: const TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  Text(
                    "Bed number: ${patient.bedNumber}",
                    style: const TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  Text(
                    "Is order finished: ${patient.isOrderFinished}",
                    style: const TextStyle(color: Colors.white, fontSize: 20),
                  )
                ],
              ),
            ),
          ),
        )
      : const SizedBox();
}
