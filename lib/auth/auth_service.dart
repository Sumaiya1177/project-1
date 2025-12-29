import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;


  Future<AuthResponse> signUpWithEmailPassword(String email, String password) async {
    return await _supabase.auth.signUp(
      email: email,
      password: password,
    );
  }

  Future<AuthResponse> signInWithEmailPassword(String email, String password) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  User? get currentUser => _supabase.auth.currentUser;

  String? getCurrentUserEmail() => _supabase.auth.currentUser?.email;


  Future<void> createOrUpdateProfile({
    required String fullName,
    required String phone,
    required String email,
  }) async {
    final user = _supabase.auth.currentUser;


    if (user == null) {
      throw Exception(
        "No active session found. Turn OFF email confirmation in Supabase for demo, "
            "or save profile after login.",
      );
    }

    await _supabase.from('profiles').upsert({
      'id': user.id,
      'full_name': fullName,
      'phone': phone,
      'email': email,
    });
  }
}
