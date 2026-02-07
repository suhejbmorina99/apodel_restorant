import 'package:apodel_restorant/features/auth/data/firebase_auth.dart';
import 'package:apodel_restorant/features/reports/presentation/pages/reports_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() {
    return _ProfilePageState();
  }
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final items = [
      {
        'icon': Icons.bar_chart,
        'title': 'Raportet',
        'onTap': () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (ctx) => const ReportsPage())),
      },
      // {
      //   'icon': Icons.videocam,
      //   'title': 'Mënyra Vizuale',
      //   'onTap': () => Navigator.push(
      //     context,
      //     MaterialPageRoute(builder: (context) => const VisualModeScreen()),
      //   ),
      // },
      {
        'icon': Icons.logout,
        'title': 'Dilni',
        'onTap': () async {
          HapticFeedback.lightImpact();
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                backgroundColor: Theme.of(context).colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: Text(
                  'Konfirmo Daljen',
                  style: GoogleFonts.nunito(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: 18,
                  ),
                ),
                content: Text(
                  'A jeni të sigurt që dëshironi të dilni?',
                  style: GoogleFonts.nunito(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'Anulo',
                      style: GoogleFonts.nunito(color: Colors.grey.shade600),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final SharedPreferences preferences =
                          await SharedPreferences.getInstance();
                      await preferences.remove('lastLoginTimestamp');
                      await AuthService().signout(context: context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('Dilni', style: GoogleFonts.nunito()),
                  ),
                ],
              );
            },
          );
        },
      },
      {
        'icon': Icons.delete_forever,
        'title': 'Fshi Llogarinë',
        'onTap': () async {
          HapticFeedback.lightImpact();
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                backgroundColor: Theme.of(context).colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: Text(
                  'Konfirmo Fshirjen e Llogarisë',
                  style: GoogleFonts.nunito(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: 18,
                  ),
                ),
                content: Text(
                  'A jeni të sigurt që dëshironi të fshini llogarinë tuaj? Ky veprim nuk mund të kthehet mbrapsht.',
                  style: GoogleFonts.nunito(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'Anulo',
                      style: GoogleFonts.nunito(color: Colors.grey.shade600),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final result = await AuthService().deleteUser(context);
                      if (result) {
                        final SharedPreferences preferences =
                            await SharedPreferences.getInstance();
                        await preferences.remove('lastLoginTimestamp');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('Fshi', style: GoogleFonts.nunito()),
                  ),
                ],
              );
            },
          );
        },
      },
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        title: Text(
          'Profili',
          style: GoogleFonts.nunito(
            textStyle: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
              fontSize: 18,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 16),
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return Column(
                        children: [
                          Card(
                            color: Theme.of(
                              context,
                            ).colorScheme.primaryContainer,
                            elevation: 0.5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ListTile(
                              leading: Icon(
                                item['icon'] as IconData,
                                size: 24,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                              title: Text(
                                item['title'] as String,
                                style: GoogleFonts.nunito(
                                  fontSize: 16,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimary,
                                ),
                              ),
                              trailing: Icon(
                                Icons.chevron_right,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                              onTap: item['onTap'] as void Function()?,
                            ),
                          ),
                          const SizedBox(height: 5),
                        ],
                      );
                    },
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
