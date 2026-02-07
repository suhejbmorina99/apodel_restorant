import 'dart:io';
import 'package:apodel_restorant/features/splash/presentation/pages/splash_page.dart';
import 'package:flutter/material.dart';
import 'package:apodel_restorant/features/auth/presentation/pages/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
// import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:apodel_restorant/features/auth/presentation/pages/email_verification.dart';
import 'package:apodel_restorant/core/network/email_service.dart';

class AuthService {
  User? getCurrentUser() {
    return FirebaseAuth.instance.currentUser;
  }

  Future<bool> signup({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      final EmailService emailService = EmailService();

      // final purchaserInfo = await Purchases.getCustomerInfo();
      // final newUserId = userCredential.user!.uid;

      // if (purchaserInfo.originalAppUserId != newUserId) {
      //   await Purchases.logIn(newUserId);
      // }

      if (email.isNotEmpty) {
        try {
          await emailService.sendWelcomeEmail(
            recipientEmail: email,
            recipientName: 'Apodel',
          );
          print('✅ Welcome email sent to $email');
        } catch (e) {
          print('❗ Failed to send welcome email: $e');
        }
      }

      if (!userCredential.user!.emailVerified) {
        await userCredential.user!.sendEmailVerification();

        Fluttertoast.showToast(
          msg: "Verification email sent. Please check your inbox.",
          backgroundColor: Colors.black54,
          textColor: Colors.white,
        );
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const EmailVerificationScreen(),
        ),
      );

      return true;
    } on FirebaseAuthException catch (e) {
      String message = '';
      if (e.code == 'weak-password') {
        message = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        message = 'An account already exists with that email.';
      } else if (e.code == 'invalid-email') {
        message = 'The email address is not valid.';
      }
      Fluttertoast.showToast(
        msg: message,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
      );
      return false;
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'An error occurred. Please try again.',
        backgroundColor: Colors.black54,
        textColor: Colors.white,
      );
      return false;
    }
  }

  Future<bool> signin({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    // Check if email or password is empty
    if (email.isEmpty || password.isEmpty) {
      Fluttertoast.showToast(
        msg: 'Please enter both email and password.',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.SNACKBAR,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 14.0,
      );
      return false; // Indicate failure
    }

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // RevenueCat login
      // final purchaserInfo = await Purchases.getCustomerInfo();
      // if (purchaserInfo.originalAppUserId !=
      //     FirebaseAuth.instance.currentUser!.uid) {
      //   await Purchases.logIn(FirebaseAuth.instance.currentUser!.uid);
      // }

      await Future.delayed(const Duration(seconds: 1));
      // Navigate to the WorkoutsScreen if successful
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => const SplashScreen(),
        ),
      );
      return true; // Indicate success
    } on FirebaseAuthException catch (e) {
      String message = '';

      switch (e.code) {
        case 'invalid-email':
        case 'user-not-found':
          message = 'No user found for that email.';
          break;
        case 'wrong-password':
          message = 'Wrong password provided for that user.';
          break;
        case 'user-disabled':
          message = 'This user account has been disabled.';
          break;
        case 'network-request-failed':
          message = 'There is no internet connection.';
          break;
        default:
          message = 'Invalid email or password. Please try again.';
          break;
      }

      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.SNACKBAR,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 14.0,
      );
      return false; // Indicate failure
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'An error occurred. Please try again.',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.SNACKBAR,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 14.0,
      );
      return false; // Indicate failure
    }
  }

  Future<void> signout({required BuildContext context}) async {
    await FirebaseAuth.instance.signOut();
    await Future.delayed(const Duration(seconds: 1));
    // await Purchases.logOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (BuildContext context) => LoginScreen()),
      (route) => false,
    );
  }

  Future<void> signInAsGuest(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signInAnonymously();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => const SplashScreen(),
        ),
      );
    } catch (_) {
      Fluttertoast.showToast(
        msg: 'Guest sign-in failed. Please try again.',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.SNACKBAR,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 14.0,
      );
    }
  }

  Future<UserCredential?> signInWithApple(BuildContext context) async {
    try {
      final EmailService emailService = EmailService();
      // Check if platform is iOS or macOS, where Apple Sign-In is supported
      if (Platform.isIOS || Platform.isMacOS) {
        final appleCredential = await SignInWithApple.getAppleIDCredential(
          scopes: [
            AppleIDAuthorizationScopes.email,
            AppleIDAuthorizationScopes.fullName,
          ],
        );

        // Create an OAuth credential using Apple ID token and authorization code
        final oAuthCredential = OAuthProvider("apple.com").credential(
          idToken: appleCredential.identityToken,
          accessToken: appleCredential.authorizationCode,
        );

        // Sign in to Firebase with the Apple credential
        final userCredential = await FirebaseAuth.instance.signInWithCredential(
          oAuthCredential,
        );

        // RevenueCat: check and log in if needed
        // final purchaserInfo = await Purchases.getCustomerInfo();
        // final currentUserId = userCredential.user!.uid;

        // if (purchaserInfo.originalAppUserId != currentUserId) {
        //   await Purchases.logIn(currentUserId);
        // }

        // Send welcome email if the user is new
        if (userCredential.additionalUserInfo?.isNewUser == true) {
          final email = userCredential.user?.email;

          if (email != null && email.isNotEmpty) {
            await emailService.sendWelcomeEmail(
              recipientEmail: email,
              recipientName: 'Apodel',
            );
          }
        }

        final SharedPreferences preferences =
            await SharedPreferences.getInstance();

        await preferences.setBool('isEmailVerified', true);

        // Navigate to the WorkoutsScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => const SplashScreen(),
          ),
        );

        return userCredential;
      } else {
        Fluttertoast.showToast(
          msg: 'Sign in with Apple is only supported on iOS and macOS.',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.SNACKBAR,
          backgroundColor: Colors.black54,
          textColor: Colors.white,
          fontSize: 14.0,
        );
        return null;
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'An error occurred during Apple Sign-In. Please try again.',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.SNACKBAR,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 14.0,
      );
      return null;
    }
  }

  Future<UserCredential?> signInWithGoogle(BuildContext context) async {
    try {
      final EmailService emailService = EmailService();
      final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();

      // Exit if sign-in is cancelled
      if (gUser == null) return null;

      final GoogleSignInAuthentication gAuth = await gUser.authentication;

      // Create a Google credential
      final credential = GoogleAuthProvider.credential(
        accessToken: gAuth.accessToken,
        idToken: gAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );

      // RevenueCat: ensure logged in with correct Firebase UID
      // final purchaserInfo = await Purchases.getCustomerInfo();
      // final currentUserId = userCredential.user!.uid;

      // if (purchaserInfo.originalAppUserId != currentUserId) {
      //   await Purchases.logIn(currentUserId);
      // }

      // Send welcome email if the user is new
      if (userCredential.additionalUserInfo?.isNewUser == true) {
        final email = userCredential.user?.email;

        if (email != null && email.isNotEmpty) {
          emailService
              .sendWelcomeEmail(recipientEmail: email, recipientName: 'Apodel')
              .catchError((e) {
                // log only, never block signup
                print('Welcome email failed: $e');
              });
        }
      }

      final SharedPreferences preferences =
          await SharedPreferences.getInstance();

      await preferences.setBool('isEmailVerified', true);

      // Navigate to the WorkoutsScreen if sign-in is successful
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => const SplashScreen(),
        ),
      );

      return userCredential;
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'An error occurred during Google Sign-In. Please try again.',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.SNACKBAR,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 14.0,
      );
      return null;
    }
  }

  Future<bool> deleteUser(BuildContext context) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        // Step 1: Re-authenticate the user
        if (user.providerData.isNotEmpty) {
          String providerId = user.providerData[0].providerId;

          if (providerId == 'password') {
            // Email/Password Sign-In
            String? password = await showPasswordPrompt(
              context,
            ); // Prompt for password
            if (password == null || password.isEmpty) {
              Fluttertoast.showToast(
                msg: 'Password is required to delete the account.',
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.SNACKBAR,
                backgroundColor: Colors.black54,
                textColor: Colors.white,
                fontSize: 14.0,
              );
              return false;
            }

            AuthCredential credential = EmailAuthProvider.credential(
              email: user.email!,
              password: password,
            );
            await user.reauthenticateWithCredential(
              credential,
            ); // Re-authenticate
          } else if (providerId == 'google.com') {
            // Google Sign-In
            final GoogleSignInAccount? googleUser = await GoogleSignIn()
                .signIn();
            if (googleUser == null) {
              Fluttertoast.showToast(
                msg: 'Google Sign-In failed. Please try again.',
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.SNACKBAR,
                backgroundColor: Colors.black54,
                textColor: Colors.white,
                fontSize: 14.0,
              );
              return false;
            }

            final GoogleSignInAuthentication googleAuth =
                await googleUser.authentication;

            AuthCredential credential = GoogleAuthProvider.credential(
              accessToken: googleAuth.accessToken,
              idToken: googleAuth.idToken,
            );
            await user.reauthenticateWithCredential(
              credential,
            ); // Re-authenticate
          } else if (providerId == 'apple.com') {
            // Apple Sign-In
            final appleCredential = await SignInWithApple.getAppleIDCredential(
              scopes: [
                AppleIDAuthorizationScopes.email,
                AppleIDAuthorizationScopes.fullName,
              ],
            );

            AuthCredential credential = OAuthProvider("apple.com").credential(
              idToken: appleCredential.identityToken,
              accessToken: appleCredential.authorizationCode,
            );
            await user.reauthenticateWithCredential(
              credential,
            ); // Re-authenticate
          } else {
            Fluttertoast.showToast(
              msg: 'Unsupported sign-in provider. Cannot delete account.',
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.SNACKBAR,
              backgroundColor: Colors.black54,
              textColor: Colors.white,
              fontSize: 14.0,
            );
            return false;
          }
        }

        // Step 2: Delete the user account
        await user.delete();

        Fluttertoast.showToast(
          msg: "User deleted successfully.",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.SNACKBAR,
          backgroundColor: Colors.black54,
          textColor: Colors.white,
          fontSize: 14.0,
        );

        // Step 3: Sign out the user
        await FirebaseAuth.instance.signOut();

        // Navigate to the login screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (BuildContext context) => LoginScreen()),
        );

        return true;
      } on FirebaseAuthException catch (e) {
        if (e.code == 'requires-recent-login') {
          Fluttertoast.showToast(
            msg: 'Re-authentication required. Please log in again.',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.SNACKBAR,
            backgroundColor: Colors.black54,
            textColor: Colors.white,
            fontSize: 14.0,
          );
        } else {
          Fluttertoast.showToast(
            msg: 'An error occurred: ${e.message}',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.SNACKBAR,
            backgroundColor: Colors.black54,
            textColor: Colors.white,
            fontSize: 14.0,
          );
        }
        return false;
      } catch (e) {
        Fluttertoast.showToast(
          msg: 'An unexpected error occurred. Please try again.',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.SNACKBAR,
          backgroundColor: Colors.black54,
          textColor: Colors.white,
          fontSize: 14.0,
        );
        return false;
      }
    } else {
      Fluttertoast.showToast(
        msg: 'No user is currently signed in.',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.SNACKBAR,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 14.0,
      );
      return false;
    }
  }

  Future<String?> showPasswordPrompt(BuildContext context) async {
    TextEditingController passwordController = TextEditingController();

    return await showDialog<String>(
      context: context,
      builder: (context) {
        if (Platform.isIOS) {
          // Use CupertinoAlertDialog for iOS
          return CupertinoAlertDialog(
            title: Text(
              'Enter your password',
              style: GoogleFonts.nunito(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
            content: Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: CupertinoTextField(
                controller: passwordController,
                obscureText: true,
                cursorColor: Theme.of(context).colorScheme.onPrimary,
                placeholder: 'Password',
                style: GoogleFonts.nunito(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Theme.of(context).colorScheme.onPrimary,
                      width: 1.0,
                    ),
                  ),
                ),
              ),
            ),
            actions: <Widget>[
              CupertinoDialogAction(
                isDefaultAction: true,
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Cancel',
                  style: GoogleFonts.nunito(
                    color: CupertinoColors.systemBlue,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
              CupertinoDialogAction(
                isDestructiveAction: true,
                onPressed: () {
                  Navigator.of(context).pop(passwordController.text);
                },
                child: Text(
                  'OK',
                  style: GoogleFonts.nunito(
                    color: CupertinoColors.destructiveRed,
                  ),
                ),
              ),
            ],
          );
        } else {
          // Use AlertDialog for other platforms
          return AlertDialog(
            title: Text(
              'Enter your password',
              style: GoogleFonts.nunito(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
            content: TextField(
              controller: passwordController,
              obscureText: true,
              cursorColor: Theme.of(context).colorScheme.onPrimary,
              decoration: InputDecoration(
                labelText: 'Password',
                labelStyle: GoogleFonts.nunito(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ),
              style: GoogleFonts.nunito(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text(
                  'Cancel',
                  style: GoogleFonts.nunito(color: CupertinoColors.systemBlue),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text('OK', style: GoogleFonts.nunito(color: Colors.red)),
                onPressed: () {
                  Navigator.of(context).pop(passwordController.text);
                },
              ),
            ],
          );
        }
      },
    );
  }

  Future<bool> deleteUserInVerification(BuildContext context) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        await user.delete();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteGuestUser(BuildContext context) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null && user.isAnonymous) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (BuildContext context) => LoginScreen()),
        );
        await user.delete();
        return true;
      }
      print(2);
      return false;
    } catch (e) {
      print("Error deleting guest user: $e");
      return false;
    }
  }
}
