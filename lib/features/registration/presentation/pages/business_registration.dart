import 'package:flutter/material.dart';
import 'package:apodel_restorant/features/registration/models/business_registration_data.dart';
import 'package:apodel_restorant/features/registration/presentation/widgets/basic_information_step.dart';

class BusinessRegistration extends StatelessWidget {
  const BusinessRegistration({super.key});

  @override
  Widget build(BuildContext context) {
    return BasicInformationStep(registrationData: BusinessRegistrationData());
  }
}
