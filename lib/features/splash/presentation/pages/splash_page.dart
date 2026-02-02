import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:apodel_restorant/features/auth/presentation/pages/login.dart';
import 'package:apodel_restorant/features/registration/presentation/pages/business_registration.dart';
import 'package:apodel_restorant/features/auth/presentation/pages/email_verification.dart';
import 'package:apodel_restorant/features/home/presentation/pages/home_page.dart';
import 'package:apodel_restorant/features/registration/presentation/widgets/processing_information.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _SplashScreen();
  }
}

class _SplashScreen extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _controller =
        AnimationController(
          duration: const Duration(seconds: 5),
          vsync: this,
        )..addStatusListener((status) async {
          if (status == AnimationStatus.completed) {
            final SharedPreferences preferences =
                await SharedPreferences.getInstance();

            final bool isEmailVerified =
                preferences.getBool('isEmailVerified') ?? false;
            final int? lastLoginTimestamp = preferences.getInt(
              'lastLoginTimestamp',
            );
            final bool isRegistrationCompleted =
                preferences.getBool('registration_completed') ?? false;

            if (lastLoginTimestamp != null) {
              final DateTime lastLogin = DateTime.fromMillisecondsSinceEpoch(
                lastLoginTimestamp,
              );
              final DateTime now = DateTime.now();
              final bool isSessionValid =
                  now.difference(lastLogin).inMinutes < 30;

              if (!isEmailVerified) {
                if (mounted) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const EmailVerificationScreen(),
                    ),
                  );
                }
              } else if (!isSessionValid) {
                if (mounted) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                }
              } else if (isRegistrationCompleted) {
                // Check database to verify restaurant still exists
                try {
                  final firebaseUser = FirebaseAuth.instance.currentUser;

                  if (firebaseUser == null) {
                    // Firebase session expired, go to login
                    if (mounted) {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    }
                    return;
                  }

                  final response = await Supabase.instance.client
                      .from('restorants')
                      .select('registration_status')
                      .eq('user_id', firebaseUser.uid)
                      .maybeSingle();

                  if (response == null) {
                    // Restaurant was deleted, reset SharedPreferences
                    await preferences.remove('registration_completed');
                    await preferences.remove('registration_status');

                    if (mounted) {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const BusinessRegistration(),
                        ),
                      );
                    }
                  } else {
                    // Restaurant exists, check status
                    final String status =
                        response['registration_status'] as String? ??
                        'processing';

                    // Update SharedPreferences with latest from DB
                    await preferences.setString('registration_status', status);

                    if (mounted) {
                      if (status == 'approved') {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) => HomePage()),
                        );
                      } else {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const ProcessingInformation(),
                          ),
                        );
                      }
                    }
                  }
                } catch (e) {
                  // If database call fails, fall back to SharedPreferences
                  final String registrationStatus =
                      preferences.getString('registration_status') ??
                      'processing';

                  if (mounted) {
                    if (registrationStatus == 'approved') {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => HomePage()),
                      );
                    } else {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const ProcessingInformation(),
                        ),
                      );
                    }
                  }
                }
              } else {
                // Registration not completed
                if (mounted) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const BusinessRegistration(),
                    ),
                  );
                }
              }
            } else {
              if (mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              }
            }
          }
        });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Lottie Animation
            Lottie.asset(
              'assets/animations/splash.json',
              fit: BoxFit.contain,
              repeat: false,
              onLoaded: (composition) {
                // Set the animation duration to match the composition
                _controller.duration = composition.duration;
              },
            ),
          ],
        ),
      ),
    );
  }
}
