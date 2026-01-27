import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:apodel_restorant/features/registration/models/business_registration_data.dart';
import 'package:apodel_restorant/features/registration/presentation/widgets/category_selection_step.dart';
import 'package:apodel_restorant/features/registration/presentation/widgets/custom_dropdown.dart';
import 'package:apodel_restorant/features/registration/presentation/widgets/custom_text_field.dart';

class BasicInformationStep extends StatefulWidget {
  final BusinessRegistrationData registrationData;

  const BasicInformationStep({super.key, required this.registrationData});

  @override
  State<BasicInformationStep> createState() => _BasicInformationStepState();
}

class _BasicInformationStepState extends State<BasicInformationStep> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _emriBiznesitController;
  late final TextEditingController _numriIdentifikuesController;
  late final TextEditingController _numriMobilController;
  late final TextEditingController _cityController;
  late final TextEditingController _postalCodeController;
  late final TextEditingController _adresaController;

  String? _selectedCountry;
  TimeOfDay? _openingTime;
  TimeOfDay? _closingTime;

  final List<String> _countries = ['Kosovë', 'Shqipëri'];

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing data if any
    _emriBiznesitController = TextEditingController(
      text: widget.registrationData.emriBiznesit,
    );
    _numriIdentifikuesController = TextEditingController(
      text: widget.registrationData.numriIdentifikues,
    );
    _numriMobilController = TextEditingController(
      text: widget.registrationData.numriMobil,
    );
    _cityController = TextEditingController(
      text: widget.registrationData.qyteti,
    );
    _postalCodeController = TextEditingController(
      text: widget.registrationData.postalCode,
    );
    _adresaController = TextEditingController(
      text: widget.registrationData.adresa,
    );
    _selectedCountry = widget.registrationData.shteti;

    // Load existing times if any
    if (widget.registrationData.orariHapjes != null) {
      _openingTime = _parseTime(widget.registrationData.orariHapjes!);
    }
    if (widget.registrationData.orariMbylljes != null) {
      _closingTime = _parseTime(widget.registrationData.orariMbylljes!);
    }
  }

  @override
  void dispose() {
    _emriBiznesitController.dispose();
    _numriIdentifikuesController.dispose();
    _numriMobilController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    _adresaController.dispose();
    super.dispose();
  }

  TimeOfDay? _parseTime(String time) {
    try {
      final parts = time.split(':');
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    } catch (e) {
      return null;
    }
  }

  Future<void> _selectTime(BuildContext context, bool isOpeningTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color.fromARGB(255, 253, 199, 69),
              onPrimary: Colors.black,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isOpeningTime) {
          _openingTime = picked;
        } else {
          _closingTime = picked;
        }
      });
    }
  }

  String _formatTime(TimeOfDay? time) {
    if (time == null) return '';
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  void _continueToNextStep() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate opening hours
    if (_openingTime == null || _closingTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Ju lutem zgjidhni orarin e punës',
            style: GoogleFonts.nunito(),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Save data to the model
    widget.registrationData.emriBiznesit = _emriBiznesitController.text.trim();
    widget.registrationData.numriIdentifikues = _numriIdentifikuesController
        .text
        .trim();
    widget.registrationData.numriMobil = _numriMobilController.text.trim();
    widget.registrationData.shteti = _selectedCountry;
    widget.registrationData.qyteti = _cityController.text.trim();
    widget.registrationData.postalCode = _postalCodeController.text.trim();
    widget.registrationData.adresa = _adresaController.text.trim();
    widget.registrationData.orariHapjes = _formatTime(_openingTime);
    widget.registrationData.orariMbylljes = _formatTime(_closingTime);

    // Navigate to category selection
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            CategorySelectionStep(registrationData: widget.registrationData),
      ),
    );
  }

  Widget _buildTimePicker({
    required BuildContext context,
    required String label,
    required String hint,
    required TimeOfDay? time,
    required VoidCallback onTap,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.nunito(
            textStyle: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
              fontWeight: FontWeight.normal,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(height: 10),
        InkWell(
          onTap: onTap,
          child: Container(
            width: MediaQuery.of(context).size.width - 50,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                width: 2,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  time != null ? _formatTime(time) : hint,
                  style: GoogleFonts.nunito(
                    color: time != null
                        ? Theme.of(context).colorScheme.onPrimary
                        : Theme.of(context).colorScheme.secondary,
                    fontSize: 14,
                  ),
                ),
                Icon(
                  Icons.access_time,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
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
          'Informacione Bazike',
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 16),
          child: Center(
            child: Form(
              key: _formKey,
              child: Column(
                // crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  CustomTextField(
                    label: 'Emri i biznesit',
                    hint: 'Emri i restorantit tuaj',
                    controller: _emriBiznesitController,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Ju lutem shkruani emrin e biznesit';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    label: 'Numri unik identifikues',
                    hint: 'Numri identifikues i biznesit',
                    controller: _numriIdentifikuesController,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Ju lutem shkruani numrin identifikues';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    label: 'Numri mobil i biznesit',
                    hint: '+383 XX XXX XXX',
                    controller: _numriMobilController,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Ju lutem shkruani numrin mobil';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  CustomDropdown(
                    label: 'Shteti',
                    hint: 'Zgjidhni shtetin',
                    value: _selectedCountry,
                    items: _countries,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedCountry = newValue;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ju lutem zgjidhni shtetin';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    label: 'Qyteti',
                    hint: 'Emri i qytetit',
                    controller: _cityController,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Ju lutem shkruani qytetin';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    label: 'Kodi postar',
                    hint: '30000',
                    controller: _postalCodeController,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    label: 'Adresa e biznesit',
                    hint: 'Rruga, numri i objektit',
                    controller: _adresaController,
                    maxLines: 2,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Ju lutem shkruani adresen';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: MediaQuery.of(context).size.width - 50,
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildTimePicker(
                            context: context,
                            label: 'Hapet nga',
                            hint: 'Zgjidhni orën',
                            time: _openingTime,
                            onTap: () => _selectTime(context, true),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTimePicker(
                            context: context,
                            label: 'Mbyllet në',
                            hint: 'Zgjidhni orën',
                            time: _closingTime,
                            onTap: () => _selectTime(context, false),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
