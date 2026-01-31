import 'package:flutter/material.dart';
import 'package:apodel_restorant/features/registration/models/business_registration_data.dart';

class PartnerPlanStep extends StatelessWidget {
  final BusinessRegistrationData registrationData;

  const PartnerPlanStep({super.key, required this.registrationData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Partner Plan')),
      body: SafeArea(child: Center(child: Text('Hi - Partner Plan Step'))),
    );
  }
}
