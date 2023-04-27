import 'package:flutter/material.dart';

class NoAvailability extends StatelessWidget {
  const NoAvailability({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.orange,
      body: SafeArea(child: Text('No availability')),
    );
  }
}
