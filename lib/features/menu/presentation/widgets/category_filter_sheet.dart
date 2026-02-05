import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CategoryFilterSheet extends StatelessWidget {
  final String? selectedCategory;
  final Function(String?) onCategorySelected;

  const CategoryFilterSheet({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  static final List<String> _categories = [
    'Të gjitha',
    'Pica',
    'Burger',
    'Sandwich',
    'Toast',
    'Pije',
    'Ëmbëlsirë',
    'Sallatë',
    'Pasta',
    'Tjetër',
  ];

  static void show(
    BuildContext context, {
    required String? selectedCategory,
    required Function(String?) onCategorySelected,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => CategoryFilterSheet(
        selectedCategory: selectedCategory,
        onCategorySelected: onCategorySelected,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Filtro sipas kategorisë',
              style: GoogleFonts.nunito(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
            const SizedBox(height: 20),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final isSelected =
                      selectedCategory == category ||
                      (category == 'Të gjitha' && selectedCategory == null);

                  return ListTile(
                    title: Text(
                      category,
                      style: GoogleFonts.nunito(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(
                            Icons.check_circle,
                            color: Color.fromARGB(255, 253, 199, 69),
                          )
                        : null,
                    onTap: () {
                      final newCategory = category == 'Të gjitha'
                          ? null
                          : category;
                      onCategorySelected(newCategory);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
