import 'package:apodel_restorant/features/home/presentation/widgets/keyed_widget.dart';
import 'package:apodel_restorant/features/home/presentation/widgets/nav_item.dart';
import 'package:flutter/material.dart';
import 'package:apodel_restorant/features/orders/presentation/pages/orders.dart';
import 'package:apodel_restorant/features/menu/presentation/pages/menu_page.dart';
import 'package:apodel_restorant/features/profile/presentation/pages/profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const Orders(),
    const MenuPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        transitionBuilder: (child, animation) {
          return SlideTransition(
            position:
                Tween<Offset>(
                  begin: const Offset(0.08, 0.0),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                ),
            child: FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              ),
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.75, end: 1.0).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                ),
                child: child,
              ),
            ),
          );
        },
        child: KeyedWidget(
          key: ValueKey<int>(_currentIndex),
          index: _currentIndex,
          child: _pages[_currentIndex],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                NavItem(
                  index: 0,
                  icon: Icons.receipt_long,
                  label: 'Porositë',
                  isSelected: _currentIndex == 0,
                  onTap: () => setState(() => _currentIndex = 0),
                ),
                NavItem(
                  index: 1,
                  icon: Icons.restaurant_menu,
                  label: 'Menuja',
                  isSelected: _currentIndex == 1,
                  onTap: () => setState(() => _currentIndex = 1),
                ),
                NavItem(
                  index: 2,
                  icon: Icons.person,
                  label: 'Profili',
                  isSelected: _currentIndex == 2,
                  onTap: () => setState(() => _currentIndex = 2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
