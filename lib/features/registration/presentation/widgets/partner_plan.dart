import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:apodel_restorant/features/registration/models/business_registration_data.dart';
import 'package:apodel_restorant/features/registration/presentation/widgets/processing_information.dart';

class PartnerPlanStep extends StatefulWidget {
  final BusinessRegistrationData registrationData;

  const PartnerPlanStep({super.key, required this.registrationData});

  @override
  State<PartnerPlanStep> createState() => _PartnerPlanStepState();
}

class _PartnerPlanStepState extends State<PartnerPlanStep> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = false;

  // Delivery options
  int? _selectedDeliveryOption; // 1 or 2
  bool _pickupEnabled = true;

  Future<void> _submitRegistration() async {
    setState(() => _isLoading = true);

    try {
      final firebaseUser = FirebaseAuth.instance.currentUser;

      if (firebaseUser == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Sesioni ka skaduar. Ju lutem hyni sërishmi.',
              style: GoogleFonts.nunito(),
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final userId = firebaseUser.uid;

      final data = widget.registrationData.toJson();
      data['user_id'] = userId;
      data['delivery_plan'] = _selectedDeliveryOption;
      data['pickup_enabled'] = _pickupEnabled;
      data['registration_status'] = 'processing';

      await _supabase.from('restorants').insert(data);

      final response = await _supabase
          .from('restorants')
          .select('registration_status')
          .eq('user_id', userId)
          .single();

      final String registrationStatus =
          response['registration_status'] as String? ?? 'processing';

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('registration_status', registrationStatus);
      await prefs.setBool('registration_completed', true);

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const ProcessingInformation()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gabim: ${e.toString()}', style: GoogleFonts.nunito()),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildDeliveryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Shpërndarja',
                style: GoogleFonts.nunito(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.delivery_dining,
                  size: 28,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Përdorni platformën për të marrë porosi nga klientët.',
            style: GoogleFonts.nunito(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 20),
          // Option 1: Use platform delivery
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _selectedDeliveryOption = 1);
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _selectedDeliveryOption == 1
                    ? const Color.fromARGB(255, 253, 199, 69).withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _selectedDeliveryOption == 1
                      ? const Color.fromARGB(255, 253, 199, 69)
                      : Colors.grey.shade300,
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _selectedDeliveryOption == 1
                            ? const Color.fromARGB(255, 253, 199, 69)
                            : Colors.grey.shade400,
                        width: 2,
                      ),
                      color: _selectedDeliveryOption == 1
                          ? const Color.fromARGB(255, 253, 199, 69)
                          : Colors.transparent,
                    ),
                    child: _selectedDeliveryOption == 1
                        ? const Center(
                            child: Icon(
                              Icons.circle,
                              size: 12,
                              color: Colors.black,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Përdorni apodel si dorëzues',
                          style: GoogleFonts.nunito(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '10% tarifë për porosi',
                          style: GoogleFonts.nunito(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Option 2: Use own delivery staff
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _selectedDeliveryOption = 2);
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _selectedDeliveryOption == 2
                    ? const Color.fromARGB(255, 253, 199, 69).withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _selectedDeliveryOption == 2
                      ? const Color.fromARGB(255, 253, 199, 69)
                      : Colors.grey.shade300,
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _selectedDeliveryOption == 2
                            ? const Color.fromARGB(255, 253, 199, 69)
                            : Colors.grey.shade400,
                        width: 2,
                      ),
                      color: _selectedDeliveryOption == 2
                          ? const Color.fromARGB(255, 253, 199, 69)
                          : Colors.transparent,
                    ),
                    child: _selectedDeliveryOption == 2
                        ? const Center(
                            child: Icon(
                              Icons.circle,
                              size: 12,
                              color: Colors.black,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Përdorni stafin tuaj për dorëzim',
                              style: GoogleFonts.nunito(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.info_outline,
                              size: 16,
                              color: Colors.grey.shade500,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '5% tarifë për porosi',
                          style: GoogleFonts.nunito(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPickupCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _pickupEnabled
              ? const Color.fromARGB(255, 253, 199, 69)
              : Colors.grey.shade300,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _pickupEnabled = !_pickupEnabled);
                },
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: _pickupEnabled
                        ? const Color.fromARGB(255, 253, 199, 69)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: _pickupEnabled
                          ? const Color.fromARGB(255, 253, 199, 69)
                          : Colors.grey.shade400,
                      width: 2,
                    ),
                  ),
                  child: _pickupEnabled
                      ? const Icon(Icons.check, size: 16, color: Colors.black)
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Marrja e porosisë',
                style: GoogleFonts.nunito(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.shopping_bag,
                  size: 28,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Lejoni klientët të marrin porosinë e tyre në dyqanin tuaj.',
            style: GoogleFonts.nunito(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '5% tarifë për porosi',
            style: GoogleFonts.nunito(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
        ],
      ),
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
          'Zgjidhni Planin',
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
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    Text(
                      'Ju mund të ndryshoni zgjedhjet më vonë.',
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildDeliveryCard(),
                    const SizedBox(height: 16),
                    _buildPickupCard(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width - 50,
                height: 50,
                child: ElevatedButton(
                  onPressed: _selectedDeliveryOption == null || _isLoading
                      ? null
                      : _submitRegistration,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 253, 199, 69),
                    foregroundColor: Colors.black,
                    disabledBackgroundColor: Colors.grey.shade300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.black,
                          ),
                        )
                      : Text(
                          'Përfundo Regjistrimin',
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
}
