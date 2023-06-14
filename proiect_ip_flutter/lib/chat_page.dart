import 'dart:convert';
import 'dart:typed_data';

import 'package:arrow_pad/arrow_pad.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:proiect_ip_flutter/order_state_page.dart';

import 'no_disponibility.dart';

class ChatPage extends StatefulWidget {
  final BluetoothDevice server;
  final String patientId;
  final String patientLastName;
  final String medicineName;

  const ChatPage(
      {Key? key,
      required this.server,
      required this.patientId,
      required this.patientLastName,
      required this.medicineName})
      : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPage();
}

class _ChatPage extends State<ChatPage> {
  BluetoothConnection? deviceConnection;

  String _messageBuffer = '';

  bool didPressUp = false;
  bool didPressDown = false;
  bool didPressLeft = false;
  bool didPressRight = false;

  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _addUserEmail();
  }

  @override
  void dispose() {
    super.dispose();
  }

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
                    : SafeArea(
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Align(
                                  alignment: Alignment.topRight,
                                  child: Image(
                                    image: AssetImage('images/MedX.jpeg'),
                                    height: 100,
                                    width: 100,
                                  )),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20.0),
                                child: Text(
                                  'Welcome,\n${user!.email!}',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 18),
                                ),
                              ),
                              const SizedBox(
                                height: 50,
                              ),
                              Center(
                                child: ArrowPad(
                                  padding: const EdgeInsets.all(8.0),
                                  height: 220,
                                  width: 220,
                                  iconColor: Colors.white,
                                  innerColor: Colors.blue,
                                  outerColor: Colors.green,
                                  splashColor: Colors.greenAccent,
                                  hoverColor: Colors.green,
                                  onPressed: (direction) {
                                    if (direction == PressDirection.up) {
                                      didPressUp = true;
                                      return _sendMessage('n');
                                    } else if (direction ==
                                        PressDirection.down) {
                                      didPressDown = true;
                                      return _sendMessage('s');
                                    } else if (direction ==
                                        PressDirection.left) {
                                      didPressLeft = true;
                                      return _sendMessage('v');
                                    } else if (direction ==
                                        PressDirection.right) {
                                      didPressRight = true;
                                      return _sendMessage('e');
                                    }
                                  },
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 20.0, horizontal: 20.0),
                                child: Text(
                                  'Reports:',
                                  style: TextStyle(fontSize: 18),
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      final docPatient = FirebaseFirestore
                                          .instance
                                          .collection('orders')
                                          .doc(widget.patientId);
                                      docPatient
                                          .update({'isOrderFinished': true});
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                OrderStatePage(
                                                    isOrderFinished: true,
                                                    server: widget.server)),
                                      );
                                    },
                                    style: TextButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        backgroundColor: Colors.green),
                                    child: const Text('Finished'),
                                  ),
                                  const SizedBox(
                                    width: 50,
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      final docPatient = FirebaseFirestore
                                          .instance
                                          .collection('orders')
                                          .doc(widget.patientId);
                                      docPatient
                                          .update({'isOrderFinished': false});
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                OrderStatePage(
                                                    isOrderFinished: false,
                                                    server: widget.server)),
                                      );
                                    },
                                    style: TextButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        backgroundColor: Colors.red),
                                    child: const Text('Unfinished'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
              }
              return const Center(
                child: CircularProgressIndicator(),
              );
            }));
  }

  void _sendMessage(String text) {
    text = text.trim();

    if (text.isNotEmpty) {
      if (text != 'G;') {
        try {
          print('Sent data: ${Uint8List.fromList(utf8.encode("$text\r\n"))}');

          deviceConnection?.output
              .add(Uint8List.fromList(utf8.encode("$text\r\n")));
          deviceConnection?.output.allSent;
        } catch (e) {
          print(e.toString());
        }
      } else {
        try {
          print('Sent data: ${Uint8List.fromList(utf8.encode("$text"))}');

          deviceConnection?.output.add(Uint8List.fromList(utf8.encode(text)));
          deviceConnection?.output.allSent;
        } catch (e) {
          print(e.toString());
        }
      }
    }
  }

  Future<void> _addUserEmail() async {
    final docUser =
        FirebaseFirestore.instance.collection('robot').doc('userID');
    final json = {
      'robotUser': user!.email!,
    };

    await docUser.set(json);
  }

  Future<bool> _isRobotAvailable() async {
    bool fieldValue = true;
    String isOrderFinishedReceived = '';
    print('Address server is: ${widget.server.address}');
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

    FlutterBluetoothSerial.instance.state.then((state) {
      print("Current Bluetooth state: $state");
      if (state == BluetoothState.STATE_ON) {
        // Bluetooth is enabled, proceed with connection
        connectToDevice(isOrderFinishedReceived, fieldValue);
      } else {
        // Bluetooth is not enabled, request the user to enable it
        FlutterBluetoothSerial.instance.requestEnable().then((_) {
          connectToDevice(isOrderFinishedReceived, fieldValue);
        });
      }
    });

    FlutterBluetoothSerial.instance
        .onStateChanged()
        .listen((BluetoothState state) {
      print("Bluetooth state changed to: $state");
      if (state == BluetoothState.STATE_ON) {
        // Bluetooth is enabled, proceed with connection
        connectToDevice(isOrderFinishedReceived, fieldValue);
      }
    });

    return fieldValue;
  }

  void connectToDevice(String isOrderFinishedReceived, bool fieldValue) async {
    try {
      BluetoothConnection connection =
          await BluetoothConnection.toAddress(widget.server.address);
      print('Connected to the device');

      deviceConnection = connection;

      connection.input?.listen((Uint8List data) {
        // send data
        connection.output.add(Uint8List.fromList(utf8.encode("G;")));
        connection.output.allSent;
        print('Sent G;');
        if(didPressUp == true) {
          connection.output.add(Uint8List.fromList(utf8.encode("n")));
          connection.output.allSent;
          print('Sent n');
        }
        if(didPressDown == true) {
          connection.output.add(Uint8List.fromList(utf8.encode("s")));
          connection.output.allSent;
          print('Sent s');
        }
        if(didPressLeft == true) {
          connection.output.add(Uint8List.fromList(utf8.encode("v")));
          connection.output.allSent;
          print('Sent v');
        }
        if(didPressRight == true) {
          connection.output.add(Uint8List.fromList(utf8.encode("e")));
          connection.output.allSent;
          print('Sent e');
        }
        // receive data
        String incomingData = '';
        print('Data incoming: ${ascii.decode(data)}');
        incomingData = ascii.decode(data);
        if (incomingData.contains('8')) {
          final docPatient = FirebaseFirestore.instance
              .collection('orders')
              .doc(widget.patientId);
          docPatient.update({'isOrderFinished': true});
          print('Am modificat in db');
        }

        if (ascii.decode(data).contains('!')) {
          connection.finish(); // Closing connection
          print('Disconnecting by local host');
        }
      }).onDone(() {
        print('Disconnected by remote request');
      });
    } catch (exception) {
      print('Cannot connect, exception occurred: $exception');
    }
    if (fieldValue == false) {
      _sendMessage('G;');
      print('G;');
    } else {
      _sendMessage('A;');
      print('A;');
    }
  }
}
