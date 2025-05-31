// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'signup.dart';
// import 'user/googlesignin.dart';
// import 'user/forgot_password.dart';
import 'user/dashboardpage.dart';
import 'auth_service.dart';
// import 'admin/dashboard_admin.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  bool _obscurePassword = true;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo section
              Center(
                child: Column(
                  children: [
                    Image.asset('images/logo nugasyuk.png', height: 60),
                    const SizedBox(height: 8),
                  ],
                ),
              ),

              const SizedBox(height: 48),

              // Email Input
              const Text(
                'Email Address',
                style: TextStyle(fontSize: 16, color: Color(0xFF94A3B8)),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  hintText: 'Enter your email',
                  prefixIcon: const Icon(
                    Icons.person_outline,
                    color: Color(0xFF94A3B8),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFBFDBFE),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Password Input
              const Text(
                'Password',
                style: TextStyle(fontSize: 16, color: Color(0xFF94A3B8)),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  hintText: 'Enter your password',
                  prefixIcon: const Icon(
                    Icons.lock_outline,
                    color: Color(0xFF94A3B8),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: const Color(0xFF94A3B8),
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  filled: true,
                  fillColor: const Color(0xFFBFDBFE),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
              ),

              // Forgot Password (Dihapus jika tidak digunakan)
              // Align(
              //   alignment: Alignment.centerRight,
              //   child: GestureDetector(
              //     onTap: () {
              //       Navigator.push(
              //         context,
              //         MaterialPageRoute(
              //           builder: (context) => const ForgotPasswordPage(),
              //         ),
              //       );
              //     },
              //     child: const Text(
              //       'Forgot Password?',
              //       style: TextStyle(color: Colors.lightBlue, fontSize: 14),
              //     ),
              //   ),
              // ),

              const SizedBox(height: 24),

              // Login Button
              ElevatedButton(
                onPressed: () async {
                  final email = emailController.text.trim();
                  final password = passwordController.text.trim();

                  if (email.isEmpty || password.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Email dan password wajib diisi!'),
                      ),
                    );
                    return;
                  }

                  // Cek jika akun adalah admin (Dihapus jika tidak ada peran admin)
                  // if (email == 'mlnnrhsn@gmail.com' && password == 'nugasyuksukses') {
                  //     Navigator.pushReplacement(context,
                  //     MaterialPageRoute(builder: (context) => const AdminDashboardPage())
                  //     );
                  //     return;
                  // }

                  final success = await AuthService.signIn(email, password);
                  if (success) {
                    // Jika login berhasil, arahkan ke Dashboard
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const DashboardPage()),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Email atau password salah!')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlue,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Log In',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Or continue with
              Row(
                children: const [
                  Expanded(child: Divider(color: Color(0xFF94A3B8))),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Or continue with',
                      style: TextStyle(color: Color(0xFF94A3B8)),
                    ),
                  ),
                  Expanded(child: Divider(color: Color(0xFF94A3B8))),
                ],
              ),

              const SizedBox(height: 24),

              // Google Sign In Button (Dihapus jika tidak digunakan)
              // OutlinedButton(
              //   onPressed: () {
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(
              //         builder: (context) => const GoogleSignInPage(),
              //       ),
              //     );
              //   },
              //   style: OutlinedButton.styleFrom(
              //     minimumSize: const Size(double.infinity, 56),
              //     shape: RoundedRectangleBorder(
              //       borderRadius: BorderRadius.circular(16),
              //     ),
              //     side: const BorderSide(color: Color(0xFF94A3B8)),
              //   ),
              //   child: Row(
              //     mainAxisAlignment: MainAxisAlignment.center,
              //     children: [
              //       Image.asset('images/google.png', height: 24),
              //       const SizedBox(width: 12),
              //       const Text(
              //         'Google',
              //         style: TextStyle(fontSize: 16, color: Colors.black87),
              //       ),
              //     ],
              //   ),
              // ),

              const Spacer(),

              // Sign Up Link
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SignUpPage(),
                      ),
                    );
                  },
                  child: RichText(
                    text: const TextSpan(
                      text: "Don't have an account? ",
                      style: TextStyle(color: Color(0xFF94A3B8)),
                      children: [
                        TextSpan(
                          text: 'Sign Up',
                          style: TextStyle(
                            color: Colors.lightBlue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
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

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}