import 'package:apodel_restorant/features/menu/presentation/widgets/add_menu_item_page.dart';
import 'package:apodel_restorant/features/menu/presentation/widgets/category_filter_sheet.dart';
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
  List<MenuItem> _filteredMenuItems = [];
  bool _isLoading = true;
  String? _restaurantId;
  String? _selectedCategory;

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

      final restaurantResponse = await _supabase
          .from('restorants')
          .select('id')
          .eq('user_id', firebaseUser.uid)
          .single();

      _restaurantId = restaurantResponse['id'] as String;

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
        _filterMenuItems();
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

  void _filterMenuItems() {
    if (_selectedCategory == null) {
      _filteredMenuItems = _menuItems;
    } else {
      _filteredMenuItems = _menuItems
          .where((item) => item.category == _selectedCategory)
          .toList();
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
            fontSize: 18,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              CategoryFilterSheet.show(
                context,
                selectedCategory: _selectedCategory,
                onCategorySelected: (category) {
                  setState(() {
                    _selectedCategory = category;
                    _filterMenuItems();
                  });
                },
              );
            },
            icon: Icon(
              Icons.filter_list,
              color: _selectedCategory != null
                  ? const Color.fromARGB(255, 253, 199, 69)
                  : Theme.of(context).colorScheme.onPrimary,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 16),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _filteredMenuItems.isEmpty
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
                        _selectedCategory != null
                            ? 'Asnjë produkt në "$_selectedCategory"'
                            : 'Asnjë produkt ende',
                        style: GoogleFonts.nunito(
                          fontSize: 18,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _selectedCategory != null
                            ? 'Provo një kategori tjetër'
                            : 'Shtoni produktin tuaj të parë',
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _filteredMenuItems.length,
                  itemBuilder: (context, index) {
                    final item = _filteredMenuItems[index];
                    return _buildMenuItem(item);
                  },
                ),
        ),
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
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddMenuItemPage(
              restaurantId: _restaurantId!,
              existingItem: item,
            ),
          ),
        );
        if (result == true) {
          _loadMenuItems();
        }
      },
      child: Card(
        color: Theme.of(context).colorScheme.primaryContainer,
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              item.imageUrl != null
                  ? ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        bottomLeft: Radius.circular(12),
                      ),
                      child: Image.network(
                        item.imageUrl!,
                        width: 100,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Container(
                      width: 100,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          bottomLeft: Radius.circular(12),
                        ),
                      ),
                      child: Icon(Icons.fastfood, color: Colors.grey.shade400),
                    ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        item.name,
                        style: GoogleFonts.nunito(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.category,
                        style: GoogleFonts.nunito(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                      if (item.description != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          item.description!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.nunito(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Text(
                    '€${item.price.toStringAsFixed(2)}',
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color.fromARGB(255, 253, 199, 69),
                    ),
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
