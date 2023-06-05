import 'dart:convert';
import 'dart:typed_data';

import 'package:arrow_pad/arrow_pad.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:proiect_ip_flutter/order_state_page.dart';

class ChatPage extends StatefulWidget {
  final BluetoothDevice server;
  final String patientId;

  const ChatPage({Key? key, required this.server, required this.patientId})
      : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPage();
}

class Message {
  int whom;
  String text;

  Message(this.whom, this.text);
}

class _ChatPage extends State<ChatPage> {
  static const clientID = 0;
  BluetoothConnection? connection;

  List<Message> messages = <Message>[];
  String _messageBuffer = '';

  final TextEditingController textEditingController = TextEditingController();

  bool isConnecting = true;
  bool get isConnected => connection != null && connection!.isConnected;

  bool isDisconnecting = false;
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    BluetoothConnection.toAddress(widget.server.address).then((connection) {
      print('Connected to the device');
      connection = connection;
      setState(() {
        isConnecting = false;
        isDisconnecting = false;
      });

      connection.input?.listen(_onDataReceived).onDone(() {
        // Example: Detect which side closed the connection
        // There should be `isDisconnecting` flag to show are we are (locally)
        // in middle of disconnecting process, should be set before calling
        // `dispose`, `finish` or `close`, which all causes to disconnect.
        // If we except the disconnection, `onDone` should be fired as result.
        // If we didn't except this (no flag set), it means closing by remote.
        if (isDisconnecting) {
          print('Disconnecting locally!');
        } else {
          print('Disconnected remotely!');
        }
        if (mounted) {
          setState(() {});
        }
      });
    }).catchError((error) {
      print('Cannot connect, exception occurred');
      print(error);
    });

    _addUserEmail();
  }

  @override
  void dispose() {
    // Avoid memory leak (`setState` after dispose) and disconnect
    if (isConnected) {
      isDisconnecting = true;
      connection?.dispose();
      connection = null;
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
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
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
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
                      return _sendMessage('N');
                    } else if (direction == PressDirection.down) {
                      return _sendMessage('S');
                    } else if (direction == PressDirection.left) {
                      return _sendMessage('V');
                    } else if (direction == PressDirection.right) {
                      return _sendMessage('E');
                    }
                  },
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
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
                      final docPatient = FirebaseFirestore.instance
                          .collection('orders')
                          .doc(widget.patientId);
                      docPatient.update({'isOrderFinished': true});
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) => OrderStatePage(
                                isOrderFinished: true, server: widget.server)),
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
                      final docPatient = FirebaseFirestore.instance
                          .collection('orders')
                          .doc(widget.patientId);
                      docPatient.update({'isOrderFinished': false});
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) => OrderStatePage(
                                isOrderFinished: false, server: widget.server)),
                      );
                    },
                    style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.red),
                    child: const Text('Unfinished'),
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  Flexible(
                    child: Container(
                      margin: const EdgeInsets.only(left: 16.0),
                      child: TextField(
                        style: const TextStyle(fontSize: 15.0),
                        controller: textEditingController,
                        decoration: InputDecoration.collapsed(
                          hintText: isConnecting
                              ? 'Wait until connected...'
                              : isConnected
                                  ? 'Type your message...'
                                  : 'Chat got disconnected',
                          hintStyle: const TextStyle(color: Colors.grey),
                        ),
                        enabled: isConnected,
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(8.0),
                    child: IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: isConnected
                            ? () => _sendMessage(textEditingController.text)
                            : null),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void _sendMessage(String text) {
    text = text.trim();
    textEditingController.clear();

    if (text.isNotEmpty) {
      try {
        connection?.output.add(Uint8List.fromList(utf8.encode("$text\r\n")));
        connection?.output.allSent.then(
          (_) => setState(() {
            messages.add(Message(clientID, text));
          }),
        );
      } catch (e) {
        // Ignore error, but notify state
        setState(() {});
      }
    }
  }

  void _onDataReceived(Uint8List data) {
    // Allocate buffer for parsed data
    int backspacesCounter = 0;
    data.forEach((byte) {
      if (byte == 8 || byte == 127) {
        backspacesCounter++;
      }
    });
    Uint8List buffer = Uint8List(data.length - backspacesCounter);
    int bufferIndex = buffer.length;

    // Apply backspace control character
    backspacesCounter = 0;
    for (int i = data.length - 1; i >= 0; i--) {
      if (data[i] == 8 || data[i] == 127) {
        backspacesCounter++;
      } else {
        if (backspacesCounter > 0) {
          backspacesCounter--;
        } else {
          buffer[--bufferIndex] = data[i];
        }
      }
    }

    // Create message if there is new line character
    String dataString = String.fromCharCodes(buffer);
    int index = buffer.indexOf(13);
    if (~index != 0) {
      setState(() {
        messages.add(
          Message(
            1,
            backspacesCounter > 0
                ? _messageBuffer.substring(
                    0, _messageBuffer.length - backspacesCounter)
                : _messageBuffer + dataString.substring(0, index),
          ),
        );
        _messageBuffer = dataString.substring(index);
      });
    } else {
      _messageBuffer = (backspacesCounter > 0
          ? _messageBuffer.substring(
              0, _messageBuffer.length - backspacesCounter)
          : _messageBuffer + dataString);
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
}
