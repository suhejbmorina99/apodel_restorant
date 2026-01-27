import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:apodel_restorant/features/registration/models/business_registration_data.dart';
import 'package:apodel_restorant/features/registration/presentation/widgets/cuisine_selection_step.dart';
import 'package:apodel_restorant/features/registration/presentation/widgets/custom_dropdown.dart';

class CategorySelectionStep extends StatefulWidget {
  final BusinessRegistrationData registrationData;

  const CategorySelectionStep({super.key, required this.registrationData});

  @override
  State<CategorySelectionStep> createState() => _CategorySelectionStepState();
}

class _CategorySelectionStepState extends State<CategorySelectionStep> {
  final _formKey = GlobalKey<FormState>();
  final _supabase = Supabase.instance.client;

  String? _selectedCategory;
  bool _isLoading = false;

  final List<String> _categories = [
    'Restaurant',
    'Fast Food',
    'Pub',
    'Café',
    'Bar',
    'Bakery',
    'Pizzeria',
    'Market',
    'Tjetër',
  ];

  final List<String> _foodRelatedCategories = [
    'Restaurant',
    'Fast Food',
    'Pizzeria',
    'Bakery',
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.registrationData.kategorite;
  }

  bool _isFoodRelated() {
    return _selectedCategory != null &&
        _foodRelatedCategories.contains(_selectedCategory);
  }

  Future<void> _submitRegistration() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userId = _supabase.auth.currentUser?.id;

      widget.registrationData.kategorite = _selectedCategory;
      widget.registrationData.kuzhina =
          null; // Clear cuisine for non-food categories

      final data = widget.registrationData.toJson();
      data['user_id'] = userId;

      await _supabase.from('restorants').insert(data);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Biznesi u regjistrua me sukses!',
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

  void _continueToNextStep() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    widget.registrationData.kategorite = _selectedCategory;

    // If food-related, go to cuisine selection, otherwise submit directly
    if (_isFoodRelated()) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              CuisineSelectionStep(registrationData: widget.registrationData),
        ),
      );
    } else {
      _submitRegistration();
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
          'Kategoria e Biznesit',
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
                    label: 'Kategoria e biznesit',
                    hint: 'Zgjidhni kategorinë',
                    value: _selectedCategory,
                    items: _categories,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedCategory = newValue;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ju lutem zgjidhni kategorinë';
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
                              _isFoodRelated() ? 'Vazhdo' : 'Përfundo',
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
