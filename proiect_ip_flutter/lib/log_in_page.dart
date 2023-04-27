import 'package:flutter/material.dart';
import 'package:proiect_ip_flutter/bonded_device_page.dart';

class LogInPage extends StatefulWidget {
  const LogInPage({Key? key}) : super(key: key);

  @override
  State<LogInPage> createState() => _LogInPageState();
}

class _LogInPageState extends State<LogInPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red,
      body: SafeArea(
          child: Column(
        children: [
          const Text('LogInPage'),
          IconButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const SelectBondedDevice())),
              icon: const Icon(Icons.device_hub)),
        ],
      )),
    );
  }
}
