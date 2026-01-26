import 'package:flutter/material.dart';

class BasicInformation extends StatelessWidget {
  const BasicInformation({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Regjistro Restorantin')),
      body: SafeArea(child: Center(child: Text('WELCOME'))),
    );
  }
}
