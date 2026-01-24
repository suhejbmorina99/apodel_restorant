import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:apodel_restorant/features/auth/presentation/pages/login.dart';

import 'package:apodel_restorant/features/auth/presentation/pages/email_verification.dart';
// import 'package:stretchandmobility/screens/paywall_screen.dart';
import 'package:apodel_restorant/features/menu/test.dart';
// import 'package:purchases_flutter/purchases_flutter.dart';

// Future<bool> isUserSubscribed() async {
//   try {
//     final customerInfo = await Purchases.getCustomerInfo();
//     final entitlement = customerInfo.entitlements.all['Pro'];

//     return entitlement != null && entitlement.isActive;
//   } catch (e) {
//     print('Error checking subscription: $e');
//     return false;
//   }
// }

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
  late Animation<double> _animation;
  late Animation<Offset> _slideAnimation;
  bool _isGuestUser = true;

  @override
  void initState() {
    super.initState();
    _checkIfGuestUser();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _controller =
        AnimationController(duration: const Duration(seconds: 5), vsync: this)
          ..addStatusListener((status) async {
            if (status == AnimationStatus.completed) {
              // final bool isSubscribed = await isUserSubscribed();

              final SharedPreferences preferences =
                  await SharedPreferences.getInstance();
              // await preferences.setBool('isSubscribed', isSubscribed);

              // final bool questionsCompleted =
              //     preferences.getBool('questionsCompleted') ?? false;
              final bool isEmailVerified =
                  preferences.getBool('isEmailVerified') ?? false;
              final int? lastLoginTimestamp = preferences.getInt(
                'lastLoginTimestamp',
              );

              if (lastLoginTimestamp != null) {
                final DateTime lastLogin = DateTime.fromMillisecondsSinceEpoch(
                  lastLoginTimestamp,
                );
                final DateTime now = DateTime.now();

                if (isEmailVerified && now.difference(lastLogin).inDays < 7) {
                  if (mounted) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const JustTestScreen(),
                      ),
                    );
                  }
                } else if (isEmailVerified &&
                    now.difference(lastLogin).inDays < 7) {
                  if (mounted) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const JustTestScreen(),
                      ),
                    );
                  }
                } else if (!isEmailVerified && _isGuestUser) {
                  if (mounted) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const JustTestScreen(),
                      ),
                    );
                  }
                } else if (!isEmailVerified && !_isGuestUser) {
                  if (mounted) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const EmailVerificationScreen(),
                      ),
                    );
                  }
                } else {
                  if (mounted) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                  }
                }
              } else {
                // if (questionsCompleted) {
                //   if (mounted) {
                //     Navigator.of(context).pushReplacement(
                //       MaterialPageRoute(
                //         builder: (context) => Login(),
                //       ),
                //     );
                //   }
                // } else {
                if (mounted) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) =>
                          LoginScreen(), // const FirstQuestion();
                    ),
                  );
                }
                // }
              }
            }
          });

    _controller.forward();
  }

  Future<void> _checkIfGuestUser() async {
    final bool isGuest = await isGuestUser();
    setState(() {
      _isGuestUser = isGuest;
    });
  }

  Future<bool> isGuestUser() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getBool('isGuest') ?? true;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _animation = Tween<double>(
      begin: MediaQuery.of(context).size.width,
      end: 190.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
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
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            double value = _animation.value;
            return Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: value,
                  height: value,
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 253, 199, 69),
                    shape: BoxShape.circle,
                  ),
                ),
                Positioned(
                  right: -value + 200,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Str8ch Today.',
                          style: GoogleFonts.nunito(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                        Text(
                          'Smile Tomorrow.',
                          style: GoogleFonts.nunito(
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
