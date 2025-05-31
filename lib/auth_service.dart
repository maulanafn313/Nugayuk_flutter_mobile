import './services/service.dart';
import '../models/User.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  static final _api = ApiService();

  static User? _currentUser;

  static User? get currentUser => _currentUser;

  static Future<bool> loadUserProfile() async {
    final token = await _api.getToken(); // Periksa apakah token masih ada
    if (token == null) {
      _currentUser = null;
      return false; // Tidak ada token, tidak bisa login
    }

    try {
      final userData = await _api.getUserProfile(); // Ambil data user dari API
      if (userData != null) {
        _currentUser = User(
          id: userData['id'] ?? 0, // Sesuaikan dengan field dari UserResource Laravel
          name: userData['name'] ?? '',
          email: userData['email'] ?? '',
          role: userData['role'] ?? 'user', // Sesuaikan
        );
        debugPrint('User profile loaded in AuthService: ${_currentUser?.name}');
        return true;
      } else {
        // Token mungkin ada tapi tidak valid lagi, atau API error
        _currentUser = null;
        await _api.signOut(); // Hapus token yang tidak valid
        return false;
      }
    } catch (e) {
      debugPrint('Error loading user profile in AuthService: $e');
      _currentUser = null;
      return false;
    }
  }

  static Future<bool> signUp(String name, String email, String pass) async {
    return await _api.signUp(name, email, pass, pass); // [cite: 258]
  }

  static Future<bool> signIn(String email, String pass) async {
    final tokenStored = await _api.signIn(email, pass);
    if (tokenStored) {
      // Jika token berhasil disimpan, coba muat profil pengguna
      return await loadUserProfile(); // Ini akan mengisi _currentUser
    }
    _currentUser = null; // Pastikan currentUser null jika sign-in gagal
    return false;
  }

  static Future<void> signOut() async {
    await _api.signOut(); // Ini sudah menghapus token dari storage
    _currentUser = null; // Bersihkan currentUser
    debugPrint('User signed out, currentUser cleared.');
  }


  static Future<bool> isLoggedIn() async {
    final token = await _api.getToken();
    return token != null;
  }

  // Metode ini akan dipanggil oleh main.dart untuk memeriksa status login awal
  static Future<bool> checkInitialLoginStatus() async {
    return await loadUserProfile(); // Langsung coba muat profil user
  }
}
