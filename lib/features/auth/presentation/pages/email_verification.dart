import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:stretchandmobility/screens/splash_screen.dart';
import 'package:apodel_restorant/features/auth/data/firebase_auth.dart';
import 'package:apodel_restorant/features/auth/presentation/pages/signup.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() {
    return _EmailVerificationScreenState();
  }
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  Future<void> _setEmailVerificationStatus(bool status) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool('isEmailVerified', status);
  }

  Future<void> _checkVerificationStatus() async {
    HapticFeedback.lightImpact();
    await FirebaseAuth.instance.currentUser!.reload();
    final isVerified = FirebaseAuth.instance.currentUser!.emailVerified;

    if (isVerified) {
      await _setEmailVerificationStatus(true);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SplashScreen()),
      );
    } else {
      await _setEmailVerificationStatus(false);
      Fluttertoast.showToast(
        msg: "Please verify your email before continuing.",
        backgroundColor: Colors.black54,
        textColor: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Return false to prevent navigation back
        return false;
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: SafeArea(
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 16, left: 24),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    'Email Verification!',
                    style: GoogleFonts.nunito(
                      textStyle: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'A verification link has been sent to your email.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.nunito(fontSize: 18),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width - 50,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _checkVerificationStatus,
                          style: ElevatedButton.styleFrom(
                            foregroundColor: const Color.fromARGB(
                              255,
                              33,
                              33,
                              33,
                            ),
                            backgroundColor: const Color.fromARGB(
                              255,
                              253,
                              199,
                              69,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'I have verified my email',
                            style: GoogleFonts.nunito(
                              fontSize: 18,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width - 50,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () async {
                            await AuthService().deleteUserInVerification(
                              context,
                            );
                            final SharedPreferences preferences =
                                await SharedPreferences.getInstance();
                            await preferences.remove('lastLoginTimestamp');
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SignupScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Theme.of(
                              context,
                            ).colorScheme.primaryFixed,
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.tertiaryFixed,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'Wrong Email?',
                            style: GoogleFonts.nunito(fontSize: 18),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
