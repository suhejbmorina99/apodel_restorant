import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomTimePickerRow extends StatelessWidget {
  final TimeOfDay? openingTime;
  final TimeOfDay? closingTime;
  final Future<void> Function(BuildContext, bool) onSelectTime;

  const CustomTimePickerRow({
    super.key,
    required this.openingTime,
    required this.closingTime,
    required this.onSelectTime,
  });

  String _formatTime(TimeOfDay? time) {
    if (time == null) return '';
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
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
    return SizedBox(
      width: MediaQuery.of(context).size.width - 50,
      child: Row(
        children: [
          Expanded(
            child: _buildTimePicker(
              context: context,
              label: 'Hapet nga',
              hint: 'Zgjidhni orën',
              time: openingTime,
              onTap: () => onSelectTime(context, true),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildTimePicker(
              context: context,
              label: 'Mbyllet në',
              hint: 'Zgjidhni orën',
              time: closingTime,
              onTap: () => onSelectTime(context, false),
            ),
          ),
        ],
      ),
    );
  }
}
