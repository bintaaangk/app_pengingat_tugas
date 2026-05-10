import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/task.dart';

class DetailRiwayatScreen extends StatelessWidget {
  final Task task;

  const DetailRiwayatScreen({super.key, required this.task});

  // Fungsi format tanggal
  String _formatTanggal(DateTime? dt) {
    if (dt == null) return "Waktu tidak dicatat";
    String pad(int n) => n.toString().padLeft(2, '0');
    return "${pad(dt.day)}/${pad(dt.month)}/${dt.year} • Jam ${pad(dt.hour)}:${pad(dt.minute)}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Arsip Tugas", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1)),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Stack(
        children: [
          // 1. Background Tema Premium
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)]),
            ),
          ),
          
          // 2. Ornamen Cahaya Kemenangan (Hijau Glow)
          Positioned(top: -50, right: -50, child: Container(width: 250, height: 250, decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF00E676).withValues(alpha: 0.15), boxShadow: [BoxShadow(color: const Color(0xFF00E676).withValues(alpha: 0.2), blurRadius: 60)]))),
          Positioned(bottom: 50, left: -50, child: Container(width: 200, height: 200, decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF5CA7FF).withValues(alpha: 0.1), boxShadow: [BoxShadow(color: const Color(0xFF5CA7FF).withValues(alpha: 0.15), blurRadius: 60)]))),

          // 3. Konten Utama
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                  // ==========================================
                  // HEADER INFO TUGAS
                  // ==========================================
                  Center(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(color: const Color(0xFF00E676).withValues(alpha: 0.2), shape: BoxShape.circle),
                          child: const Icon(Icons.verified_rounded, size: 50, color: Color(0xFF00E676)),
                        ),
                        const SizedBox(height: 15),
                        Text(task.judul, textAlign: TextAlign.center, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(color: const Color(0xFF8B78FF).withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF8B78FF).withValues(alpha: 0.5))),
                          child: Text(task.kategori, style: const TextStyle(color: Color(0xFF8B78FF), fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 35),

                  // ==========================================
                  // KARTU STATISTIK WAKTU
                  // ==========================================
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withValues(alpha: 0.2))),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.event_available_rounded, color: Colors.white54, size: 20),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text("Waktu Diselesaikan", style: TextStyle(color: Colors.white54, fontSize: 12)),
                                    const SizedBox(height: 3),
                                    Text(_formatTanggal(task.completedAt), style: const TextStyle(color: Color(0xFF00E676), fontWeight: FontWeight.bold, fontSize: 14)),
                                  ],
                                ),
                              ],
                            ),
                            const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(color: Colors.white24, height: 1)),
                            Row(
                              children: [
                                const Icon(Icons.history_rounded, color: Colors.white54, size: 20),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text("Tenggat Waktu Awal (Deadline)", style: TextStyle(color: Colors.white54, fontSize: 12)),
                                    const SizedBox(height: 3),
                                    Text(_formatTanggal(task.deadline), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),

                  // ==========================================
                  // KARTU CATATAN HASIL TUGAS
                  // ==========================================
                  const Text("Catatan Pengerjaan:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.white.withValues(alpha: 0.1))),
                    child: Text(
                      task.catatan == null || task.catatan!.isEmpty ? "Tidak ada catatan." : task.catatan!,
                      style: const TextStyle(color: Colors.white70, fontSize: 15, height: 1.5, fontStyle: FontStyle.italic),
                    ),
                  ),
                  const SizedBox(height: 25),

                  // ==========================================
                  // FOTO BUKTI TUGAS
                  // ==========================================
                  const Text("Foto Bukti:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFF00E676).withValues(alpha: 0.5), width: 2), boxShadow: [BoxShadow(color: const Color(0xFF00E676).withValues(alpha: 0.15), blurRadius: 20)]),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: task.imagePath != null && task.imagePath!.isNotEmpty
                          ? Image.file(
                              File(task.imagePath!), 
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const Padding(
                                padding: EdgeInsets.all(50.0),
                                child: Icon(Icons.broken_image_rounded, color: Colors.white54, size: 50),
                              ),
                            )
                          : const Padding(
                              padding: EdgeInsets.all(50.0),
                              child: Column(
                                children: [
                                  Icon(Icons.no_photography_rounded, color: Colors.white54, size: 50),
                                  SizedBox(height: 10),
                                  Text("Tidak ada foto bukti", style: TextStyle(color: Colors.white54)),
                                ],
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}