import 'dart:ui';
import 'package:flutter/material.dart';
import '../helpers/database_helper.dart';
import '../models/task.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  final bool isDarkMode;
  final String userName; 

  const ProfileScreen({super.key, required this.isDarkMode, required this.userName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Profil Saya", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Background Dark Space
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)]),
            ),
          ),
          // Ornamen Cahaya
          Positioned(top: 100, left: -50, child: Container(width: 250, height: 250, decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF6C63FF).withValues(alpha: 0.15), boxShadow: [BoxShadow(color: const Color(0xFF6C63FF).withValues(alpha: 0.2), blurRadius: 60)]))),

          FutureBuilder<List<Task>>(
            future: DatabaseHelper.instance.getAllTasks(),
            builder: (context, snapshot) {
              int doneCount = 0;
              int pendingCount = 0;

              if (snapshot.hasData) {
                doneCount = snapshot.data!.where((t) => t.isDone).length;
                pendingCount = snapshot.data!.where((t) => !t.isDone).length;
              }

              return SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 120),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      // Foto Profil Bercahaya
                      Center(
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: 0.1),
                                border: Border.all(color: const Color(0xFF5CA7FF).withValues(alpha: 0.5), width: 2),
                                boxShadow: [BoxShadow(color: const Color(0xFF5CA7FF).withValues(alpha: 0.3), blurRadius: 20, spreadRadius: 5)],
                              ),
                              child: CircleAvatar(
                                radius: 55,
                                backgroundColor: const Color(0xFF203A43),
                                child: Text(userName.isNotEmpty ? userName[0].toUpperCase() : "?", style: const TextStyle(fontSize: 45, fontWeight: FontWeight.bold, color: Colors.white)),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(userName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1)),
                            const SizedBox(height: 5),
                            Text("Mahasiswa IT PNB", style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.6))),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Card Statistik (Glassmorphism)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildStatColumn("Diselesaikan", doneCount.toString(), const Color(0xFF00E676)),
                                Container(height: 40, width: 1, color: Colors.white.withValues(alpha: 0.2)),
                                _buildStatColumn("Belum Selesai", pendingCount.toString(), const Color(0xFFFF9100)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),

                      // Card Pengaturan & Logout (Glassmorphism)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                            ),
                            child: Column(
                              children: [
                                ListTile(
                                  leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFF5CA7FF).withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.settings_rounded, color: Color(0xFF5CA7FF))),
                                  title: const Text("Pengaturan Aplikasi", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                  trailing: const Icon(Icons.chevron_right, color: Colors.white54),
                                  onTap: () {},
                                ),
                                Divider(height: 1, color: Colors.white.withValues(alpha: 0.1)),
                                ListTile(
                                  leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.redAccent.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.logout_rounded, color: Colors.redAccent)),
                                  title: const Text("Keluar", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                                  onTap: () {
                                    Navigator.pushAndRemoveUntil(
                                      context, 
                                      MaterialPageRoute(builder: (context) => const LoginScreen()), 
                                      (route) => false
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String count, Color color) {
    return Column(
      children: [
        Text(count, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color, shadows: [Shadow(color: color.withValues(alpha: 0.5), blurRadius: 10)])),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.white70)),
      ],
    );
  }
}