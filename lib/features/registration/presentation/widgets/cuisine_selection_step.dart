import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:apodel_restorant/features/registration/models/business_registration_data.dart';
import 'package:apodel_restorant/features/registration/presentation/widgets/custom_dropdown.dart';

class CuisineSelectionStep extends StatefulWidget {
  final BusinessRegistrationData registrationData;

  const CuisineSelectionStep({super.key, required this.registrationData});

  @override
  State<CuisineSelectionStep> createState() => _CuisineSelectionStepState();
}

class _CuisineSelectionStepState extends State<CuisineSelectionStep> {
  final _formKey = GlobalKey<FormState>();
  final _supabase = Supabase.instance.client;

  String? _selectedCuisine;
  bool _isLoading = false;

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

  Future<void> _submitRegistration() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      widget.registrationData.kuzhina = _selectedCuisine;

      await _supabase
          .from('restorants')
          .insert(widget.registrationData.toJson());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Restoranti u regjistrua me sukses!',
              style: GoogleFonts.nunito(),
            ),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate back to login or home
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gabim: ${e.toString()}',
              style: GoogleFonts.nunito(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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
                      onPressed: _isLoading
                          ? null
                          : () {
                              HapticFeedback.lightImpact();
                              FocusScope.of(context).unfocus();
                              _submitRegistration();
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
                        disabledBackgroundColor: const Color.fromARGB(
                          255,
                          253,
                          199,
                          69,
                        ).withOpacity(0.6),
                      ),
                      child: _isLoading
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Theme.of(context).colorScheme.onPrimary,
                                ),
                              ),
                            )
                          : Text(
                              'Përfundo',
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
