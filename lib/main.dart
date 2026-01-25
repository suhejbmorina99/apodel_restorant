import 'package:flutter/material.dart';
import 'package:apodel_restorant/core/theme/theme.dart';
import 'package:apodel_restorant/core/theme/theme_provider.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'package:apodel_restorant/features/splash/presentation/pages/splash_page.dart';
import 'package:timezone/data/latest.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  tz.initializeTimeZones();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider()..loadThemeMode(),
      child: const ApodelRestorant(),
    ),
  );
}

class ApodelRestorant extends StatelessWidget {
  const ApodelRestorant({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      home: SplashScreen(),
      theme: themeProvider.themeData,
      darkTheme: darkMode,
      themeMode: themeProvider.themeMode == ThemeModeOption.on
          ? ThemeMode.dark
          : themeProvider.themeMode == ThemeModeOption.off
          ? ThemeMode.light
          : ThemeMode.system,
    );
  }
}
