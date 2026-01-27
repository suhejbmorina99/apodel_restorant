import 'package:apodel_restorant/features/registration/presentation/widgets/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:apodel_restorant/features/registration/models/business_registration_data.dart';

class CuisineSelectionStep extends StatefulWidget {
  final BusinessRegistrationData registrationData;

  const CuisineSelectionStep({super.key, required this.registrationData});

  @override
  State<CuisineSelectionStep> createState() => _CuisineSelectionStepState();
}

class _CuisineSelectionStepState extends State<CuisineSelectionStep> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedCuisine;

  final List<String> _cuisines = [
    'Shqiptare',
    'Italiane',
    'Mesdhetare',
    'Amerikane',
    'Kineze',
    'Indiane',
    'Meksikane',
    'Japoneze',
    'Turke',
    'E përzier',
    'Tjetër',
  ];

  @override
  void initState() {
    super.initState();
    _selectedCuisine = widget.registrationData.kuzhina;
  }

  void _continueToNextStep() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    widget.registrationData.kuzhina = _selectedCuisine;

    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) =>
    //         OpeningHoursStep(registrationData: widget.registrationData),
    //   ),
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        title: Text(
          'Lloji i Kuzhinës',
          style: GoogleFonts.nunito(
            textStyle: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 16),
          child: Center(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  CustomDropdown(
                    label: 'Lloji i kuzhinës',
                    hint: 'Zgjidhni llojin e kuzhinës',
                    value: _selectedCuisine,
                    items: _cuisines,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedCuisine = newValue;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ju lutem zgjidhni llojin e kuzhinës';
                      }
                      return null;
                    },
                  ),
                  const Spacer(),
                  SizedBox(
                    width: MediaQuery.of(context).size.width - 50,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        FocusScope.of(context).unfocus();
                        _continueToNextStep();
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: const Color.fromARGB(255, 33, 33, 33),
                        backgroundColor: const Color.fromARGB(
                          255,
                          253,
                          199,
                          69,
                        ),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Vazhdo',
                        style: GoogleFonts.nunito(
                          fontSize: 18,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
