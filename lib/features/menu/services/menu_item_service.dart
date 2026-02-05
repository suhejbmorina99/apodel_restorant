import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:apodel_restorant/features/menu/models/menu_item.dart';

class MenuItemService {
  final _supabase = Supabase.instance.client;

  Future<bool> verifyRestaurantOwnership(String restaurantId) async {
    try {
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser == null) return false;

      final response = await _supabase
          .from('restorants')
          .select('user_id')
          .eq('id', restaurantId)
          .single();

      return response['user_id'] == firebaseUser.uid;
    } catch (e) {
      return false;
    }
  }

  Future<bool> saveMenuItem({
    required BuildContext context,
    required MenuItem menuItem,
    required bool isEditMode,
    String? existingItemId,
  }) async {
    try {
      if (isEditMode && existingItemId != null) {
        // Update existing item
        await _supabase
            .from('menu_items')
            .update(menuItem.toJson())
            .eq('id', existingItemId);
      } else {
        // Insert new item
        await _supabase.from('menu_items').insert(menuItem.toJson());
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEditMode
                  ? 'Produkti u përditësua me sukses!'
                  : 'Produkti u shtua me sukses!',
              style: GoogleFonts.nunito(),
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
      return true;
    } catch (e) {
      if (context.mounted) {
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
      return false;
    }
  }

  Future<bool> deleteMenuItem({
    required BuildContext context,
    required String itemId,
    required String itemName,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Fshi Produktin',
          style: GoogleFonts.nunito(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
        content: Text(
          'A jeni të sigurt që dëshironi të fshini "$itemName"?',
          style: GoogleFonts.nunito(
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Anulo',
              style: GoogleFonts.nunito(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('Fshi', style: GoogleFonts.nunito()),
          ),
        ],
      ),
    );

    if (confirmed != true) return false;

    try {
      await _supabase.from('menu_items').delete().eq('id', itemId);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Produkti u fshi me sukses!',
              style: GoogleFonts.nunito(),
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
      return true;
    } catch (e) {
      if (context.mounted) {
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
      return false;
    }
  }
}
