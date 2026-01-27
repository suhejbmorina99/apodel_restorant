import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class BasicInformation extends StatefulWidget {
  const BasicInformation({super.key});

  @override
  State<BasicInformation> createState() => _BasicInformationState();
}

class _BasicInformationState extends State<BasicInformation> {
  final _formKey = GlobalKey<FormState>();
  final _supabase = Supabase.instance.client;

  // Controllers for text fields
  final _emriBiznesitController = TextEditingController();
  final _numriIdentifikuesController = TextEditingController();
  final _numriMobilController = TextEditingController();
  String? _selectedCountry;
  final _cityController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _adresaController = TextEditingController();

  bool _isLoading = false;

  final List<String> _countries = ['Kosovë', 'Shqipëri'];

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

  Future<void> _registerRestaurant() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _supabase.from('restaurants').insert({
        'emri_biznesit': _emriBiznesitController.text.trim(),
        'numri_identifikues': _numriIdentifikuesController.text.trim(),
        'numri_mobil': _numriMobilController.text.trim(),
        'country': _selectedCountry,
        'city': _cityController.text.trim(),
        'postal_code': _postalCodeController.text.trim(),
        'adresa': _adresaController.text.trim(),
      });

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

        // Clear form
        _formKey.currentState!.reset();
        _emriBiznesitController.clear();
        _numriIdentifikuesController.clear();
        _numriMobilController.clear();
        setState(() {
          _selectedCountry = null;
        });
        _cityController.clear();
        _postalCodeController.clear();
        _adresaController.clear();
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

  Widget _buildTextField({
    required BuildContext context,
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
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
        SizedBox(
          width: MediaQuery.of(context).size.width - 50,
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            style: GoogleFonts.nunito(
              color: Theme.of(context).colorScheme.onPrimary,
              fontSize: 14,
            ),
            decoration: InputDecoration(
              filled: true,
              hintText: hint,
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
                borderSide: const BorderSide(color: Colors.red, width: 2),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Colors.red, width: 2),
              ),
            ),
            validator: validator,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required BuildContext context,
    required String label,
    required String hint,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
    String? Function(String?)? validator,
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
        SizedBox(
          width: MediaQuery.of(context).size.width - 50,
          child: DropdownButtonFormField<String>(
            value: value,
            decoration: InputDecoration(
              filled: true,
              hintText: hint,
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
                borderSide: const BorderSide(color: Colors.red, width: 2),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Colors.red, width: 2),
              ),
            ),
            style: GoogleFonts.nunito(
              color: Theme.of(context).colorScheme.onPrimary,
              fontSize: 14,
            ),
            dropdownColor: Theme.of(context).colorScheme.primaryContainer,
            items: items.map((String country) {
              return DropdownMenuItem<String>(
                value: country,
                child: Text(
                  country,
                  style: GoogleFonts.nunito(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              );
            }).toList(),
            onChanged: onChanged,
            validator: validator,
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
          'Regjistro Biznesin',
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),

                  _buildTextField(
                    context: context,
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

                  _buildTextField(
                    context: context,
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

                  _buildTextField(
                    context: context,
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

                  _buildDropdown(
                    context: context,
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

                  _buildTextField(
                    context: context,
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

                  _buildTextField(
                    context: context,
                    label: 'Kodi postar',
                    hint: '30000',
                    controller: _postalCodeController,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),

                  _buildTextField(
                    context: context,
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
                  const SizedBox(height: 24),

                  SizedBox(
                    width: MediaQuery.of(context).size.width - 50,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : () async {
                              HapticFeedback.lightImpact();
                              FocusScope.of(context).unfocus();
                              await _registerRestaurant();
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
