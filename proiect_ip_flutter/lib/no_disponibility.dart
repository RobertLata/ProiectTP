import 'package:flutter/material.dart';

class NoAvailability extends StatelessWidget {
  const NoAvailability({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const Align(
                alignment: Alignment.topRight,
                child: Image(
                  image: AssetImage('images/MedX.jpeg'),
                  height: 100,
                  width: 100,
                )),
            const Center(
              child: Text('WayR0 is not available at the moment'),
            ),
            const Center(
              child: Text('Remote mode active'),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 40.0),
              child: Center(
                  child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blue),
                child: const Text('Go back'),
              )),
            ),
          ],
        ),
      ),
    );
  }
}
