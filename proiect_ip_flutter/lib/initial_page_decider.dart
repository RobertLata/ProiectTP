import 'package:flutter/material.dart';
import 'package:proiect_ip_flutter/bonded_device_page.dart';
import 'package:proiect_ip_flutter/log_in_page.dart';

class InitialPageDecider extends StatelessWidget {
  const InitialPageDecider({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Text('Initial Page Decider'),
            IconButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const LogInPage()));
                },
                icon: const Icon(Icons.one_k)),
            IconButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const SelectBondedDevice()));
                },
                icon: const Icon(Icons.two_k))
          ],
        ),
      ),
    );
  }
}
