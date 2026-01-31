import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProcessingInformation extends StatefulWidget {
  const ProcessingInformation({super.key});

  @override
  State<ProcessingInformation> createState() => _ProcessingInformationState();
}

class _ProcessingInformationState extends State<ProcessingInformation> {
  @override
  void initState() {
    super.initState();
    _saveRegistrationStatus();
  }

  Future<void> _saveRegistrationStatus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('registration_status', 'processing');
    await prefs.setBool('registration_completed', true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Lottie Animation
              Lottie.asset(
                'assets/animations/under_review.json',
                height: 250,
                fit: BoxFit.contain,
                repeat: true,
              ),
              const SizedBox(height: 40),

              // Title
              Text(
                'Regjistrimi Juaj Po Processohet',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
              const SizedBox(height: 16),

              // Description
              Text(
                'Faleminderit për regjistrimin! Ekipi ynë po shqyrton informacionin tuaj dhe do t\'ju njoftojë së shpejti.',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),

              // Information Cards
              _buildInfoCard(
                icon: Icons.schedule,
                title: 'Koha e Procesimit',
                description: 'Zakonisht 24-48 orë',
              ),
              const SizedBox(height: 12),
              _buildInfoCard(
                icon: Icons.email_outlined,
                title: 'Do të Njoftoheni',
                description: 'Në email dhe në aplikacion',
              ),
              const SizedBox(height: 12),
              _buildInfoCard(
                icon: Icons.support_agent,
                title: 'Keni Pyetje?',
                description: 'Kontaktoni mbështetjen tonë',
              ),

              const Spacer(),

              // Back to Home Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 253, 199, 69),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Kthehu në Fillim',
                    style: GoogleFonts.nunito(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 253, 199, 69).withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 24,
              color: const Color.fromARGB(255, 253, 199, 69),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.nunito(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
