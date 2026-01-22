import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:stretchandmobility/services/auth.dart';
// import 'package:stretchandmobility/signup/signup.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      resizeToAvoidBottomInset: true,
      bottomNavigationBar: _signup(context),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Mirë se vini, stafi i restorantit',
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
              const SizedBox(height: 80),
              _emailAddress(context),
              const SizedBox(height: 20),
              _password(context),
              const SizedBox(height: 32),
              _signin(context),
              const SizedBox(height: 20),
              _divider("Or continue with", context),
              const SizedBox(height: 20),
              SizedBox(
                width: MediaQuery.of(context).size.width - 50,
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceEvenly, // Adjusts spacing
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          right: 8,
                        ), // Space between buttons
                        child: _signInWithApple(context),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 8,
                        ), // Space between buttons
                        child: _signInWithGoogle(context),
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

  Widget _emailAddress(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Email Address',
          style: GoogleFonts.nunito(
            textStyle: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
              fontWeight: FontWeight.normal,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: MediaQuery.of(context).size.width - 50,
          height: 50,
          child: TextField(
            controller: _emailController,
            decoration: InputDecoration(
              filled: true,
              hintText: 'str8ch@hotmail.com',
              hintStyle: GoogleFonts.nunito(
                color: Theme.of(context).colorScheme.secondary,
                fontWeight: FontWeight.normal,
                fontSize: 14,
              ),
              fillColor: Theme.of(context).colorScheme.primaryContainer,
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(14),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  width: 2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: Color.fromARGB(255, 253, 199, 69),
                  width: 2,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _password(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Password',
          style: GoogleFonts.nunito(
            textStyle: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
              fontWeight: FontWeight.normal,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: MediaQuery.of(context).size.width - 50,
          height: 50,
          child: TextField(
            obscureText: true,
            controller: _passwordController,
            decoration: InputDecoration(
              filled: true,
              hintText: '********',
              hintStyle: GoogleFonts.nunito(
                color: Theme.of(context).colorScheme.secondary,
                fontWeight: FontWeight.normal,
                fontSize: 14,
              ),
              fillColor: Theme.of(context).colorScheme.primaryContainer,
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(14),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  width: 2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: Color.fromARGB(255, 253, 199, 69),
                  width: 2,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _signin(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width - 50,
      height: 50,
      child: ElevatedButton(
        onPressed: () async {
          HapticFeedback.lightImpact();
          FocusScope.of(context).unfocus();

          // bool success = await AuthService().signin(
          //   email: _emailController.text,
          //   password: _passwordController.text,
          //   context: context,
          // );

          // if (success) {
          //   // Set the last login timestamp
          //   final SharedPreferences preferences =
          //       await SharedPreferences.getInstance();
          //   await preferences.setInt(
          //     'lastLoginTimestamp',
          //     DateTime.now().millisecondsSinceEpoch,
          //   );
          //   await preferences.setBool('isGuest', false);
          // }
        },
        style: ElevatedButton.styleFrom(
          foregroundColor: const Color.fromARGB(255, 33, 33, 33),
          backgroundColor: const Color.fromARGB(255, 253, 199, 69),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          'Sign In',
          style: GoogleFonts.nunito(
            fontSize: 18,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
      ),
    );
  }

  Widget _signInWithApple(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        HapticFeedback.lightImpact();
        // await AuthService().signInWithApple(context);

        final SharedPreferences preferences =
            await SharedPreferences.getInstance();
        await preferences.setInt(
          'lastLoginTimestamp',
          DateTime.now().millisecondsSinceEpoch,
        );
        await preferences.setBool('isGuest', false);
      },
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(8),
          color: Theme.of(context).colorScheme.tertiaryFixed,
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: SvgPicture.asset(
              'assets/logos/apple.svg',
              width: 32,
              height: 32,
              colorFilter: ColorFilter.mode(
                Theme.of(context).colorScheme.primaryFixed,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _signInWithGoogle(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        HapticFeedback.lightImpact();
        // await AuthService().signInWithGoogle(context);

        final SharedPreferences preferences =
            await SharedPreferences.getInstance();
        await preferences.setInt(
          'lastLoginTimestamp',
          DateTime.now().millisecondsSinceEpoch,
        );
        await preferences.setBool('isGuest', false);
      },
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(8),
          color: Theme.of(context).colorScheme.tertiaryFixed,
        ),
        child: Center(
          child: SvgPicture.asset(
            'assets/logos/google.svg', // Use your SVG Google logo path here
            width: 32, // Adjust the width as necessary
            height: 32, // Adjust the height as necessary
            colorFilter: ColorFilter.mode(
              Theme.of(context).colorScheme.primaryFixed,
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }

  Widget _signup(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          children: [
            TextSpan(
              text: "New to Str8ch? ",
              style: GoogleFonts.nunito(
                color: Theme.of(context).colorScheme.secondary,
                fontWeight: FontWeight.normal,
                fontSize: 16,
              ),
            ),
            TextSpan(
              text: "Sign Up Now",
              style: GoogleFonts.nunito(
                color: Theme.of(context).colorScheme.onPrimary,
                fontWeight: FontWeight.normal,
                fontSize: 16,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                },
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider(String text, BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width - 50,
      child: Row(
        children: [
          Expanded(
            child: Divider(color: Theme.of(context).colorScheme.secondary),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              text,
              style: GoogleFonts.nunito(
                color: Theme.of(context).colorScheme.secondary,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Divider(color: Theme.of(context).colorScheme.secondary),
          ),
        ],
      ),
    );
  }
}
