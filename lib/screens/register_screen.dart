import 'dart:ui'; // Ditambahkan untuk efek efek blur (Glassmorphism)
import 'package:flutter/material.dart';
import '../helpers/database_helper.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Variabel untuk fitur Show/Hide Password masing-masing kolom
  bool _isPasswordHidden = true;
  bool _isConfirmPasswordHidden = true;

  void _register() async {
    final name = _nameController.text.trim();
    // Ubah otomatis semua huruf jadi kecil agar tidak ada masalah huruf besar/kecil
    final email = _emailController.text.trim().toLowerCase(); 
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    // Validasi kosong
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: Colors.redAccent, content: Text("Semua kolom harus diisi!")));
      return;
    }
    
    // Validasi format email sederhana
    if (!email.contains('@') || !email.contains('.')) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: Colors.orange, content: Text("Format email tidak valid! Pastikan pakai @ dan titik (.)")));
      return;
    }

    // Validasi sandi sama
    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: Colors.redAccent, content: Text("Sandi tidak cocok!")));
      return;
    }

    // Masukkan ke database
    bool isSuccess = await DatabaseHelper.instance.registerUser(name, email, password);

    if (!mounted) return;

    if (isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(backgroundColor: Colors.green, content: Text("Pendaftaran Sukses! Silakan Login.")),
      );
      // Pindah ke halaman login
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(backgroundColor: Colors.redAccent, content: Text("Gagal mendaftar. Email mungkin sudah dipakai.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Latar Belakang Gradient Premium (Sama dengan Login)
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0F2027), 
                  Color(0xFF203A43), 
                  Color(0xFF2C5364),
                ],
              ),
            ),
          ),

          // 2. Ornamen Lingkaran Abstrak di Background
          Positioned(
            top: -80,
            right: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF5CA7FF).withValues(alpha: 0.2),
                boxShadow: [BoxShadow(color: const Color(0xFF5CA7FF).withValues(alpha: 0.2), blurRadius: 60)]
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -80,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF6C63FF).withValues(alpha: 0.2),
                boxShadow: [BoxShadow(color: const Color(0xFF6C63FF).withValues(alpha: 0.2), blurRadius: 60)]
              ),
            ),
          ),

          // 3. Konten Utama
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tombol Kembali
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(height: 30),

                  const Text(
                    "Daftar Akun 🚀", 
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Lengkapi datamu untuk mulai mengatur tugas dengan lebih cerdas.", 
                    style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.7), height: 1.5),
                  ),
                  const SizedBox(height: 35),

                  // Kotak Register dengan Efek Glassmorphism
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
                              ctrl: _nameController, 
                              icon: Icons.person_outline_rounded, 
                              hint: "Nama Lengkap"
                            ),
                            const SizedBox(height: 20),
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
                              isObscured: _isPasswordHidden,
                              onToggleVisibility: () {
                                setState(() {
                                  _isPasswordHidden = !_isPasswordHidden;
                                });
                              }
                            ),
                            const SizedBox(height: 20),
                            _buildTextField(
                              ctrl: _confirmPasswordController, 
                              icon: Icons.lock_reset_rounded, 
                              hint: "Ulangi Kata Sandi", 
                              isPassword: true,
                              isObscured: _isConfirmPasswordHidden,
                              onToggleVisibility: () {
                                setState(() {
                                  _isConfirmPasswordHidden = !_isConfirmPasswordHidden;
                                });
                              }
                            ),
                            
                            const SizedBox(height: 40),

                            // Tombol Daftar dengan Gradient
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
                                onPressed: _register,
                                child: const Text(
                                  "DAFTAR SEKARANG", 
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Desain Field Teks yang Diperbarui (Mendukung fungsi toggle mata per kolom)
  Widget _buildTextField({
    required TextEditingController ctrl, 
    required IconData icon, 
    required String hint, 
    bool isPassword = false, 
    bool isEmail = false,
    bool isObscured = false,
    VoidCallback? onToggleVisibility,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.2), // Transparan gelap
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: TextField(
        controller: ctrl,
        obscureText: isObscured,
        keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
        style: const TextStyle(color: Colors.white), // Warna teks inputan user
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.white70),
          suffixIcon: isPassword 
              ? IconButton(
                  icon: Icon(
                    isObscured ? Icons.visibility_off : Icons.visibility,
                    color: Colors.white70,
                  ),
                  onPressed: onToggleVisibility,
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