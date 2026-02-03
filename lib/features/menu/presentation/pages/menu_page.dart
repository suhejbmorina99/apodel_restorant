import 'package:apodel_restorant/features/menu/presentation/widgets/add_menu_item_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:apodel_restorant/features/menu/models/menu_item.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  final _supabase = Supabase.instance.client;
  List<MenuItem> _menuItems = [];
  bool _isLoading = true;
  String? _restaurantId;

  @override
  void initState() {
    super.initState();
    _loadRestaurantAndMenu();
  }

  Future<void> _loadRestaurantAndMenu() async {
    setState(() => _isLoading = true);

    try {
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser == null) return;

      // Get restaurant ID
      final restaurantResponse = await _supabase
          .from('restorants')
          .select('id')
          .eq('user_id', firebaseUser.uid)
          .single();

      _restaurantId = restaurantResponse['id'] as String;

      // Load menu items
      await _loadMenuItems();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gabim: ${e.toString()}',
              style: GoogleFonts.nunito(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadMenuItems() async {
    if (_restaurantId == null) return;

    try {
      final response = await _supabase
          .from('menu_items')
          .select()
          .eq('restaurant_id', _restaurantId!)
          .order('created_at', ascending: false);

      setState(() {
        _menuItems = (response as List)
            .map((item) => MenuItem.fromJson(item))
            .toList();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gabim: ${e.toString()}',
              style: GoogleFonts.nunito(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        title: Text(
          'Menuja',
          style: GoogleFonts.nunito(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _menuItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.restaurant_menu,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Asnjë produkt ende',
                    style: GoogleFonts.nunito(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Shtoni produktin tuaj të parë',
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _menuItems.length,
              itemBuilder: (context, index) {
                final item = _menuItems[index];
                return _buildMenuItem(item);
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  AddMenuItemPage(restaurantId: _restaurantId!),
            ),
          );
          if (result == true) {
            _loadMenuItems();
          }
        },
        backgroundColor: const Color.fromARGB(255, 253, 199, 69),
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add),
        label: Text(
          'Shto Produkt',
          style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildMenuItem(MenuItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: item.imageUrl != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  item.imageUrl!,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                ),
              )
            : Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.fastfood, color: Colors.grey.shade400),
              ),
        title: Text(
          item.name,
          style: GoogleFonts.nunito(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              item.category,
              style: GoogleFonts.nunito(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            if (item.description != null) ...[
              const SizedBox(height: 4),
              Text(
                item.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.nunito(fontSize: 13),
              ),
            ],
          ],
        ),
        trailing: Text(
          '€${item.price.toStringAsFixed(2)}',
          style: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: const Color.fromARGB(255, 253, 199, 69),
          ),
        ),
      ),
    );
  }
}
