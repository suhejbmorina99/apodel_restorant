import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomPhoneField extends StatefulWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final void Function(String) onPhoneChanged;
  final String? Function(String?)? validator;

  const CustomPhoneField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    required this.onPhoneChanged,
    this.validator,
  });

  @override
  State<CustomPhoneField> createState() => _CustomPhoneFieldState();
}

class _CustomPhoneFieldState extends State<CustomPhoneField> {
  String _phoneCountryCode = '+383';
  String _phoneCountryFlag = '🇽🇰';

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
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
                                'Kosovo',
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
                                  widget.controller.clear();
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
                                'Albania',
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
                                  widget.controller.clear();
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
                child: TextFormField(
                  controller: widget.controller,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(8),
                    _PhoneNumberFormatter(),
                  ],
                  style: GoogleFonts.nunito(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    hintText: widget.hint,
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
                      borderSide: const BorderSide(color: Colors.red, width: 2),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Colors.red, width: 2),
                    ),
                    errorStyle: GoogleFonts.nunito(fontSize: 12),
                    errorMaxLines: 1,
                  ),
                  validator: widget.validator,
                  onChanged: (value) {
                    final digitsOnly = value.replaceAll(' ', '');
                    widget.onPhoneChanged('$_phoneCountryCode$digitsOnly');
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

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

    final digitsOnly = text.replaceAll(' ', '');

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
