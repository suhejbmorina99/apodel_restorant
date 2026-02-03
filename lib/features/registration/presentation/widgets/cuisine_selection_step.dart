import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:apodel_restorant/features/registration/models/business_registration_data.dart';
import 'package:apodel_restorant/features/registration/presentation/widgets/partner_plan.dart';

class CuisineSelectionStep extends StatefulWidget {
  final BusinessRegistrationData registrationData;

  const CuisineSelectionStep({super.key, required this.registrationData});

  @override
  State<CuisineSelectionStep> createState() => _CuisineSelectionStepState();
}

class _CuisineSelectionStepState extends State<CuisineSelectionStep> {
  bool _showValidationError = false;
  List<String> _selectedCuisines = [];

  final List<String> _cuisines = [
    'Shqiptare',
    'Italiane',
    'Mesdhetare',
    'Amerikane',
    'Kineze',
    'Indiane',
    'Meksikane',
    'E përzier',
    'Turke',
    'Japoneze',
    'Tjetër',
  ];

  final Map<String, IconData> _cuisineIcons = {
    'Shqiptare': Icons.restaurant,
    'Italiane': Icons.local_pizza,
    'Mesdhetare': Icons.set_meal,
    'Amerikane': Icons.fastfood,
    'Kineze': Icons.ramen_dining,
    'Indiane': Icons.rice_bowl,
    'Meksikane': Icons.local_dining,
    'E përzier': Icons.layers,
    'Turke': Icons.kebab_dining,
    'Japoneze': Icons.ramen_dining_outlined,
    'Tjetër': Icons.category,
  };

  @override
  void initState() {
    super.initState();
    // Load previously selected cuisines if any (stored as comma-separated string)
    if (widget.registrationData.kuzhina != null &&
        widget.registrationData.kuzhina!.isNotEmpty) {
      _selectedCuisines = widget.registrationData.kuzhina!.split(',');
    }
  }

  void _toggleCuisine(String cuisine) {
    setState(() {
      if (_selectedCuisines.contains(cuisine)) {
        _selectedCuisines.remove(cuisine);
      } else {
        if (_selectedCuisines.length < 5) {
          _selectedCuisines.add(cuisine);
          _showValidationError = false;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Mund të zgjidhni maksimumi 5 lloje kuzhinash',
                style: GoogleFonts.nunito(),
              ),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    });
  }

  void _continueToPartnerPlan() {
    if (_selectedCuisines.isEmpty) {
      HapticFeedback.lightImpact();
      setState(() => _showValidationError = true);
      return;
    }

    // Store as comma-separated string
    widget.registrationData.kuzhina = _selectedCuisines.join(',');

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            PartnerPlanStep(registrationData: widget.registrationData),
      ),
    );
  }

  Widget _buildCuisineGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _cuisines.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.95,
      ),
      itemBuilder: (context, index) {
        final cuisine = _cuisines[index];
        final isSelected = _selectedCuisines.contains(cuisine);

        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            _toggleCuisine(cuisine);
          },
          child: AnimatedScale(
            scale: isSelected ? 1.05 : 1.0,
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: isSelected
                    ? const Color.fromARGB(255, 253, 199, 69)
                    : Theme.of(context).colorScheme.surface,
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 10,
                          offset: const Offset(0, 6),
                        ),
                      ]
                    : [],
                border: Border.all(
                  width: 2,
                  color: isSelected
                      ? const Color.fromARGB(255, 253, 199, 69)
                      : Colors.grey.shade300,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _cuisineIcons[cuisine],
                    size: 30,
                    color: isSelected
                        ? Colors.black
                        : Theme.of(context).colorScheme.onPrimary,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    cuisine,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Colors.black
                          : Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          'Lloji i Kuzhinës',
          style: GoogleFonts.nunito(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 16),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  children: [
                    Text(
                      'Zgjidhni deri në 5 lloje kuzhinash',
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                    const SizedBox(height: 18),
                    _buildCuisineGrid(),

                    if (_showValidationError && _selectedCuisines.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(
                          'Ju lutem zgjidhni të paktën një lloj kuzhinë',
                          style: GoogleFonts.nunito(
                            color: Colors.red,
                            fontSize: 13,
                          ),
                        ),
                      ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),

              SizedBox(
                width: MediaQuery.of(context).size.width - 50,
                height: 50,
                child: ElevatedButton(
                  onPressed: _continueToPartnerPlan,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 253, 199, 69),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
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
    );
  }
}
