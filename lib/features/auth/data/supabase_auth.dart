import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAuthService {
  final _supabase = Supabase.instance.client;

  /// Deletes restaurant (menu items auto-delete via CASCADE)
  Future<bool> deleteUserData(String firebaseUid) async {
    try {
      // Just delete the restaurant - menu items CASCADE automatically
      await _supabase.from('restorants').delete().eq('user_id', firebaseUid);

      return true;
    } catch (e) {
      return false;
    }
  }
}
