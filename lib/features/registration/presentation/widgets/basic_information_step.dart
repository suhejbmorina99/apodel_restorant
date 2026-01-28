import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:country_picker/country_picker.dart';
import 'package:apodel_restorant/features/registration/models/business_registration_data.dart';
import 'package:apodel_restorant/features/registration/presentation/widgets/category_selection_step.dart';
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
  String? _completePhoneNumber;
  String _phoneCountryCode = '+383';
  String _phoneCountryFlag = '🇽🇰';
  // String? _selectedPhoneCountry = 'Kosovë';
  TimeOfDay? _openingTime;
  TimeOfDay? _closingTime;

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

    if (widget.registrationData.numriMobil != null) {
      final phoneNumber = widget.registrationData.numriMobil!;
      if (phoneNumber.startsWith('+383')) {
        _phoneCountryCode = '+383';
        _phoneCountryFlag = '🇽🇰';
        // Removed: _selectedPhoneCountry = 'Kosovë';
        _numriMobilController = TextEditingController(
          text: phoneNumber.replaceFirst('+383', '').trim(),
        );
      } else if (phoneNumber.startsWith('+355')) {
        _phoneCountryCode = '+355';
        _phoneCountryFlag = '🇦🇱';
        // Removed: _selectedPhoneCountry = 'Shqipëri';
        _numriMobilController = TextEditingController(
          text: phoneNumber.replaceFirst('+355', '').trim(),
        );
      } else {
        _numriMobilController = TextEditingController(text: phoneNumber);
      }
    } else {
      _numriMobilController = TextEditingController();
    }

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

    // Validate country selection
    if (_selectedCountry == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Ju lutem zgjidhni shtetin',
            style: GoogleFonts.nunito(),
          ),
          backgroundColor: Colors.red,
        ),
      );
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
    _completePhoneNumber =
        '$_phoneCountryCode${_numriMobilController.text.trim()}';
    widget.registrationData.numriMobil = _completePhoneNumber;
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

  Widget _buildCountryPicker() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Shteti',
          style: GoogleFonts.nunito(
            textStyle: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
              fontWeight: FontWeight.normal,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: MediaQuery.of(context).size.width - 50,
          child: InkWell(
            onTap: () {
              showCountryPicker(
                context: context,
                countryListTheme: CountryListThemeData(
                  flagSize: 25,
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  textStyle: GoogleFonts.nunito(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  bottomSheetHeight: 500,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  inputDecoration: InputDecoration(
                    labelText: 'Kërko',
                    labelStyle: GoogleFonts.nunito(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                    hintText: 'Shkruani emrin e shtetit',
                    hintStyle: GoogleFonts.nunito(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: Color.fromARGB(255, 253, 199, 69),
                        width: 2,
                      ),
                    ),
                  ),
                  searchTextStyle: GoogleFonts.nunito(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: 16,
                  ),
                ),
                onSelect: (Country country) {
                  setState(() {
                    _selectedCountry = country.name;
                  });
                },
                // Show only Kosovo and Albania by default
                favorite: ['XK', 'AL'],
              );
            },
            child: Container(
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
                    _selectedCountry ?? 'Zgjidhni shtetin',
                    style: GoogleFonts.nunito(
                      color: _selectedCountry != null
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(context).colorScheme.secondary,
                      fontSize: 14,
                    ),
                  ),
                  Icon(
                    Icons.arrow_drop_down,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneField() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Numri mobil i biznesit',
          style: GoogleFonts.nunito(
            textStyle: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
              fontWeight: FontWeight.normal,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: MediaQuery.of(context).size.width - 50,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Country Code Selector
              InkWell(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    builder: (context) {
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Zgjidhni kodin e shtetit',
                              style: GoogleFonts.nunito(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                            const SizedBox(height: 20),
                            ListTile(
                              leading: const Text(
                                '🇽🇰',
                                style: TextStyle(fontSize: 32),
                              ),
                              title: Text(
                                'Kosovë',
                                style: GoogleFonts.nunito(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimary,
                                ),
                              ),
                              trailing: Text(
                                '+383',
                                style: GoogleFonts.nunito(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimary,
                                ),
                              ),
                              onTap: () {
                                setState(() {
                                  _phoneCountryCode = '+383';
                                  _phoneCountryFlag = '🇽🇰';
                                  // Clear the phone number when switching countries
                                  _numriMobilController.clear();
                                });
                                Navigator.pop(context);
                              },
                            ),
                            ListTile(
                              leading: const Text(
                                '🇦🇱',
                                style: TextStyle(fontSize: 32),
                              ),
                              title: Text(
                                'Shqipëri',
                                style: GoogleFonts.nunito(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimary,
                                ),
                              ),
                              trailing: Text(
                                '+355',
                                style: GoogleFonts.nunito(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimary,
                                ),
                              ),
                              onTap: () {
                                setState(() {
                                  _phoneCountryCode = '+355';
                                  _phoneCountryFlag = '🇦🇱';
                                  // Clear the phone number when switching countries
                                  _numriMobilController.clear();
                                });
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                child: Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _phoneCountryFlag,
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _phoneCountryCode,
                        style: GoogleFonts.nunito(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_drop_down,
                        color: Theme.of(context).colorScheme.secondary,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Phone Number Input
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: TextFormField(
                    controller: _numriMobilController,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(8), // Max 8 digits
                      _PhoneNumberFormatter(), // Custom formatter for spacing
                    ],
                    style: GoogleFonts.nunito(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: 14,
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      hintText: '44 123 456',
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                      hintStyle: GoogleFonts.nunito(
                        color: Theme.of(context).colorScheme.secondary,
                        fontWeight: FontWeight.normal,
                        fontSize: 14,
                      ),
                      fillColor: Theme.of(context).colorScheme.primaryContainer,
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          width: 2,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: Color.fromARGB(255, 253, 199, 69),
                          width: 2,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: Colors.red,
                          width: 2,
                        ),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: Colors.red,
                          width: 2,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Ju lutem shkruani numrin mobil';
                      }
                      // Remove spaces for validation
                      final digitsOnly = value.replaceAll(' ', '');
                      if (digitsOnly.length != 8) {
                        return 'Numri duhet të ketë 8 shifra';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      // Remove spaces to get just the digits
                      final digitsOnly = value.replaceAll(' ', '');
                      _completePhoneNumber = '$_phoneCountryCode$digitsOnly';
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
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
                  _buildPhoneField(),
                  const SizedBox(height: 12),
                  _buildCountryPicker(),
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

// Add this class outside of your _BasicInformationStepState class
class _PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;

    if (text.isEmpty) {
      return newValue;
    }

    // Remove all spaces
    final digitsOnly = text.replaceAll(' ', '');

    // Format as: 44 123 456
    String formatted = '';
    for (int i = 0; i < digitsOnly.length; i++) {
      if (i == 2 || i == 5) {
        formatted += ' ';
      }
      formatted += digitsOnly[i];
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
