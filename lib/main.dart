import 'package:apodel_restorant/login/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:timezone/data/latest.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  tz.initializeTimeZones();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(const ApodelRestorant());
}

class ApodelRestorant extends StatelessWidget {
  const ApodelRestorant({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: const LoginScreen());
  }
}
