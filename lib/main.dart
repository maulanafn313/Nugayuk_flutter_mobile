import 'package:flutter/material.dart';
import 'package:nugasyuk/user/notification_provider.dart';
import 'package:provider/provider.dart';
// Sesuaikan path ini jika schedule_provider.dart ada di folder 'providers'
import 'user/schedule_provider.dart'; // Perubahan path potensial
import 'user/category_provider.dart'; // Pastikan path ini sesuai dengan struktur folder Anda
import 'signin.dart';
import 'auth_service.dart';
import 'user/dashboardpage.dart'; // Pastikan DashboardPage sudah diatur untuk menggunakan ScheduleProvider
// import 'landing_page.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ScheduleProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create:(_) => NotificationProvider())
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // final _storage = const FlutterSecureStorage();
  bool _isLoggedIn = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _performCheckLoginStatus();
  }

  Future<void> _performCheckLoginStatus() async {
    // AuthService.checkInitialLoginStatus() akan mencoba memuat profil pengguna
    // dan mengembalikan true jika berhasil (token valid & profil dimuat)
    final loggedIn = await AuthService.checkInitialLoginStatus();
    if (mounted) { // Pastikan widget masih ada di tree
      setState(() {
        _isLoggedIn = loggedIn;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return MaterialApp(
      title: 'Nugayuk Mobile',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: _isLoggedIn ? const DashboardPage() : const SignInPage(),
    );
  }
}
