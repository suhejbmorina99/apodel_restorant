import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NavItem extends StatelessWidget {
  final int index;
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const NavItem({
    super.key,
    required this.index,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color.fromARGB(255, 253, 199, 69)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? Colors.black
                  : Theme.of(context).colorScheme.secondary,
              size: 24,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
