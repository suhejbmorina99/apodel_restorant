import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:apodel_restorant/features/registration/models/business_registration_data.dart';
import 'package:apodel_restorant/features/registration/presentation/widgets/cuisine_selection_step.dart';
import 'package:apodel_restorant/features/registration/presentation/widgets/partner_plan.dart';

class CategorySelectionStep extends StatefulWidget {
  final BusinessRegistrationData registrationData;

  const CategorySelectionStep({super.key, required this.registrationData});

  @override
  State<CategorySelectionStep> createState() => _CategorySelectionStepState();
}

class _CategorySelectionStepState extends State<CategorySelectionStep> {
  String? _selectedCategory;
  bool _showValidationError = false;

  final List<String> _categories = [
    'Restorant',
    'Fast Food',
    'Pub Lounge',
    'Kafe',
    'Bar',
    'Furrë buke',
    'Piceri',
    'Market',
    'Tjetër',
  ];

  final List<String> _foodRelatedCategories = [
    'Restorant',
    'Fast Food',
    'Piceri',
    'Furrë buke',
  ];

  final Map<String, IconData> _categoryIcons = {
    'Restorant': Icons.restaurant,
    'Fast Food': Icons.fastfood,
    'Pub Lounge': Icons.sports_bar,
    'Kafe': Icons.coffee,
    'Bar': Icons.local_bar,
    'Furrë buke': Icons.bakery_dining,
    'Piceri': Icons.local_pizza,
    'Market': Icons.store,
    'Tjetër': Icons.category,
  };

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.registrationData.kategorite;
  }

  bool _isFoodRelated() {
    return _selectedCategory != null &&
        _foodRelatedCategories.contains(_selectedCategory);
  }

  void _continueToNextStep() {
    if (_selectedCategory == null) {
      HapticFeedback.lightImpact();
      setState(() {
        _showValidationError = true;
      });
      return;
    }

    _showValidationError = false;
    widget.registrationData.kategorite = _selectedCategory;

    // If food-related, go to cuisine selection, otherwise go to partner plan
    if (_isFoodRelated()) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              CuisineSelectionStep(registrationData: widget.registrationData),
        ),
      );
    } else {
      // For non-food businesses, clear cuisine and go to partner plan
      widget.registrationData.kuzhina = null;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              PartnerPlanStep(registrationData: widget.registrationData),
        ),
      );
    }
  }

  Widget _buildCategoryGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _categories.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.95,
      ),
      itemBuilder: (context, index) {
        final category = _categories[index];
        final isSelected = _selectedCategory == category;

        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() => _selectedCategory = category);
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
                    _categoryIcons[category],
                    size: 36,
                    color: isSelected
                        ? Colors.black
                        : Theme.of(context).colorScheme.onPrimary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    category,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(
                      fontSize: 15,
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
          'Kategoria e Biznesit',
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
                    _buildCategoryGrid(),

                    if (_showValidationError && _selectedCategory == null)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(
                          'Ju lutem zgjidhni kategorinë',
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
                  onPressed: _continueToNextStep,
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
