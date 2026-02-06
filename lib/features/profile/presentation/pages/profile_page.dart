import 'package:apodel_restorant/features/auth/data/firebase_auth.dart';
import 'package:apodel_restorant/features/reports/presentation/pages/reports_page.dart';
import 'package:flutter/cupertino.dart';
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
        'emoji': '📊',
        'title': 'Raportet',
        'onTap': () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (ctx) => const ReportsPage())),
      },
      // {
      //   'emoji': '🎬',
      //   'title': 'Visual Mode',
      //   'onTap': () => Navigator.push(
      //     context,
      //     MaterialPageRoute(builder: (context) => const VisualModeScreen()),
      //   ),
      // },
      {
        'emoji': '👋',
        'title': 'Logout',
        'onTap': () async {
          HapticFeedback.lightImpact();
          // Show confirmation dialog
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return Theme.of(context).platform == TargetPlatform.iOS
                  ? CupertinoAlertDialog(
                      title: Text(
                        'Confirm Logout',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.nunito(fontSize: 22),
                      ),
                      content: Text(
                        'Do you really want to logout?',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.nunito(fontSize: 14),
                      ),
                      actions: [
                        CupertinoDialogAction(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            'Cancel',
                            style: GoogleFonts.nunito(
                              color: CupertinoColors.systemBlue,
                            ),
                          ),
                        ),
                        CupertinoDialogAction(
                          onPressed: () async {
                            final SharedPreferences preferences =
                                await SharedPreferences.getInstance();
                            await preferences.remove('lastLoginTimestamp');
                            await AuthService().signout(context: context);
                          },
                          isDestructiveAction: true,
                          child: Text('Log Out', style: GoogleFonts.nunito()),
                        ),
                      ],
                    )
                  : AlertDialog(
                      title: Text(
                        'Confirm Logout',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.nunito(fontSize: 22),
                      ),
                      content: Text(
                        'Do you really want to logout?',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.nunito(fontSize: 14),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            'Cancel',
                            style: GoogleFonts.nunito(color: Colors.blue),
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            final SharedPreferences preferences =
                                await SharedPreferences.getInstance();
                            await preferences.remove('lastLoginTimestamp');
                            await AuthService().signout(context: context);
                          },
                          child: Text(
                            'Log Out',
                            style: GoogleFonts.nunito(color: Colors.red),
                          ),
                        ),
                      ],
                    );
            },
          );
        },
      },
      {
        'emoji': '❌',
        'title': 'Delete Account',
        'onTap': () async {
          HapticFeedback.lightImpact();
          // Show confirmation dialog
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return Theme.of(context).platform == TargetPlatform.iOS
                  ? CupertinoAlertDialog(
                      title: Text(
                        'Confirm Account Deletion',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.nunito(fontSize: 22),
                      ),
                      content: Text(
                        'Do you really want to delete your account? This action cannot be undone.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.nunito(fontSize: 14),
                      ),
                      actions: [
                        CupertinoDialogAction(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            'Cancel',
                            style: GoogleFonts.nunito(
                              color: CupertinoColors.systemBlue,
                            ),
                          ),
                        ),
                        CupertinoDialogAction(
                          onPressed: () async {
                            final result = await AuthService().deleteUser(
                              context,
                            );
                            if (result) {
                              final SharedPreferences preferences =
                                  await SharedPreferences.getInstance();
                              await preferences.remove('lastLoginTimestamp');
                            }
                          },
                          isDestructiveAction: true,
                          child: Text('Delete', style: GoogleFonts.nunito()),
                        ),
                      ],
                    )
                  : AlertDialog(
                      title: Text(
                        'Confirm Account Deletion',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.nunito(fontSize: 22),
                      ),
                      content: Text(
                        'Do you really want to delete your account? This action cannot be undone.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.nunito(fontSize: 14),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            'Cancel',
                            style: GoogleFonts.nunito(color: Colors.blue),
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            final result = await AuthService().deleteUser(
                              context,
                            );
                            if (result) {
                              final SharedPreferences preferences =
                                  await SharedPreferences.getInstance();
                              await preferences.remove('lastLoginTimestamp');
                            }
                          },
                          child: Text(
                            'Delete',
                            style: GoogleFonts.nunito(color: Colors.red),
                          ),
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
                              leading: Text(
                                item['emoji'] as String,
                                style: GoogleFonts.nunito(
                                  fontSize: 24,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimary,
                                ),
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
