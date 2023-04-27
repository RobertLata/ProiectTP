import 'package:flutter/material.dart';
import 'package:proiect_ip_flutter/no_disponibility.dart';

import 'chat_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow,
      body: SafeArea(
          child: Column(
        children: [
          const Text('HomePage'),
          IconButton(
              onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const ChatPage())),
              icon: const Icon(Icons.chat)),
          IconButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const NoAvailability())),
              icon: const Icon(Icons.not_interested_sharp)),
        ],
      )),
    );
  }
}
