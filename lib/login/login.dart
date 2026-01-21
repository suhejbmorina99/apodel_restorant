import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Apodel Restorant'),
        backgroundColor: Colors.amber,
        automaticallyImplyLeading: false, // prevents back icon
        scrolledUnderElevation:
            0, // scrolledUnderElevation: 0 = no shadow when scrolled appBar
        elevation: 0, // no shadow in static appBar
      ),
      resizeToAvoidBottomInset:
          true, // prevents the keyboard from overlapping the UI
      body: Text('Test'),
    );
  }
}
