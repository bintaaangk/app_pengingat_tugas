import 'dart:ui'; // Ditambahkan untuk efek efek blur (Glassmorphism)
import 'package:flutter/material.dart';
import '../helpers/database_helper.dart';
import 'main_wrapper.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  // Variabel baru untuk fitur Show/Hide Password
  bool _isPasswordHidden = true; 

  void _login() async {
    // Ubah otomatis jadi kecil, jaga-jaga user ngetik huruf besar di HP
    final email = _emailController.text.trim().toLowerCase(); 
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: Colors.redAccent, content: Text("Email dan Sandi wajib diisi!")));
      return;
    }
    
    if (!email.contains('@') || !email.contains('.')) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: Colors.orange, content: Text("Format email tidak valid! Cek kembali titik dan komanya.")));
      return;
    }

    // Tangkap NAMA dari database
    String? userName = await DatabaseHelper.instance.loginUser(email, password);

    if (!mounted) return;

    if (userName != null) {
      // Jika berhasil, kirimkan userName ke MainWrapper
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainWrapper(userName: userName)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(backgroundColor: Colors.redAccent, content: Text("Email atau Sandi salah!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Latar Belakang Gradient Premium
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0F2027), // Warna gelap modern
                  Color(0xFF203A43), 
                  Color(0xFF2C5364),
                ],
              ),
            ),
          ),

          // 2. Ornamen Lingkaran Abstrak di Background
          Positioned(
            top: -50,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF5CA7FF).withValues(alpha: 0.3),
                boxShadow: [BoxShadow(color: const Color(0xFF5CA7FF).withValues(alpha: 0.2), blurRadius: 50)]
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF6C63FF).withValues(alpha: 0.2),
                boxShadow: [BoxShadow(color: const Color(0xFF6C63FF).withValues(alpha: 0.2), blurRadius: 60)]
              ),
            ),
          ),

          // 3. Konten Utama
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Ikon/Logo Animasi (Hero)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 2),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20)]
                      ),
                      child: const Icon(Icons.school_rounded, size: 70, color: Colors.white),
                    ),
                    const SizedBox(height: 25),
                    
                    const Text(
                      "Selamat Datang!", 
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Siap menjadi lebih produktif hari ini?", 
                      style: TextStyle(fontSize: 15, color: Colors.white.withValues(alpha: 0.7)),
                    ),
                    const SizedBox(height: 40),

                    // Kotak Login dengan Efek Glassmorphism
                    ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          padding: const EdgeInsets.all(30),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                          ),
                          child: Column(
                            children: [
                              _buildTextField(
                                ctrl: _emailController, 
                                icon: Icons.email_outlined, 
                                hint: "Email Mahasiswa", 
                                isEmail: true
                              ),
                              const SizedBox(height: 20),
                              _buildTextField(
                                ctrl: _passwordController, 
                                icon: Icons.lock_outline_rounded, 
                                hint: "Kata Sandi", 
                                isPassword: true,
                              ),
                              const SizedBox(height: 15),
                              
                              Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  "Lupa Sandi?", 
                                  style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontWeight: FontWeight.w600, fontSize: 13),
                                ),
                              ),
                              const SizedBox(height: 35),

                              // Tombol Login dengan Gradient
                              Container(
                                width: double.infinity,
                                height: 55,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF6C63FF), Color(0xFF5CA7FF)],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF6C63FF).withValues(alpha: 0.4), 
                                      blurRadius: 15, 
                                      offset: const Offset(0, 5)
                                    )
                                  ],
                                ),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                  ),
                                  onPressed: _login,
                                  child: const Text(
                                    "MASUK", 
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Link Daftar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Belum punya akun? ", style: TextStyle(color: Colors.white.withValues(alpha: 0.7))),
                        GestureDetector(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen())),
                          child: const Text(
                            "Daftar Sekarang", 
                            style: TextStyle(color: Color(0xFF5CA7FF), fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Desain Field Teks yang Diperbarui
  Widget _buildTextField({
    required TextEditingController ctrl, 
    required IconData icon, 
    required String hint, 
    bool isPassword = false, 
    bool isEmail = false
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.2), // Transparan gelap
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: TextField(
        controller: ctrl,
        obscureText: isPassword ? _isPasswordHidden : false,
        keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
        style: const TextStyle(color: Colors.white), // Warna teks inputan user
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.white70),
          suffixIcon: isPassword 
              ? IconButton(
                  icon: Icon(
                    _isPasswordHidden ? Icons.visibility_off : Icons.visibility,
                    color: Colors.white70,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordHidden = !_isPasswordHidden;
                    });
                  },
                )
              : null,
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
      ),
    );
  }
}