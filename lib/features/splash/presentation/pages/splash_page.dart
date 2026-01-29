import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:apodel_restorant/features/auth/presentation/pages/login.dart';
import 'package:apodel_restorant/features/registration/presentation/pages/business_registration.dart';
import 'package:apodel_restorant/features/auth/presentation/pages/email_verification.dart';
// import 'package:stretchandmobility/screens/paywall_screen.dart';

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
  // late Animation<double> _animation;
  // late Animation<Offset> _slideAnimation;

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
            // final bool isSubscribed = await isUserSubscribed();

            final SharedPreferences preferences =
                await SharedPreferences.getInstance();
            // await preferences.setBool('isSubscribed', isSubscribed);

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

              if (isEmailVerified && now.difference(lastLogin).inMinutes < 30) {
                if (mounted) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const BusinessRegistration(),
                    ),
                  );
                }
              } else if (!isEmailVerified) {
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

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();

  //   _animation = Tween<double>(
  //     begin: MediaQuery.of(context).size.width,
  //     end: 190.0,
  //   ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

  //   _slideAnimation = Tween<Offset>(
  //     begin: const Offset(1.0, 0.0),
  //     end: Offset.zero,
  //   ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  // }

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
            // const SizedBox(height: 24),
            // Text(
            //   'apodel',
            //   style: GoogleFonts.nunito(
            //     fontSize: 42,
            //     fontWeight: FontWeight.bold,
            //     color: const Color.fromARGB(255, 253, 199, 69),
            //     letterSpacing: 2,
            //   ),
            // ),
            // const SizedBox(height: 8),
            // Text(
            //   'Delivery App',
            //   style: GoogleFonts.nunito(
            //     fontSize: 16,
            //     fontWeight: FontWeight.w500,
            //     color: Colors.grey[600],
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
