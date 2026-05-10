import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../helpers/database_helper.dart';
import '../models/task.dart';

class DetailTaskScreen extends StatefulWidget {
  final Task task;
  const DetailTaskScreen({super.key, required this.task});

  @override
  State<DetailTaskScreen> createState() => _DetailTaskScreenState();
}

class _DetailTaskScreenState extends State<DetailTaskScreen> {
  final _catatanController = TextEditingController();
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    _imagePath = widget.task.imagePath;
    _catatanController.text = widget.task.catatan ?? "";
  }

  Future<void> _takePicture() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() => _imagePath = pickedFile.path);
    }
  }

  void _updateStatus(bool isStarting) async {
    widget.task.isStarted = isStarting;
    await DatabaseHelper.instance.updateTask(widget.task);
    setState(() {});
  }

  void _completeTask() async {
    if (_imagePath == null || _catatanController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: Colors.redAccent, content: Text("Wajib upload foto bukti & isi catatan!")));
      return;
    }
    widget.task.isDone = true;
    widget.task.imagePath = _imagePath;
    widget.task.catatan = _catatanController.text;
    widget.task.completedAt = DateTime.now();
    await DatabaseHelper.instance.updateTask(widget.task);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    // Format angka agar selalu dua digit (misal 09 bukan 9)
    String formatDigit(int n) => n.toString().padLeft(2, '0');
    
    // Menyiapkan teks deadline
    String tanggalBatas = "${formatDigit(widget.task.deadline.day)}/${formatDigit(widget.task.deadline.month)}/${widget.task.deadline.year}";
    String jamBatas = "${formatDigit(widget.task.deadline.hour)}:${formatDigit(widget.task.deadline.minute)}";

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Detail Tugas", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1)),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Stack(
        children: [
          // 1. Latar Belakang Tema Premium
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)]),
            ),
          ),
          
          // 2. Ornamen Cahaya Keren
          Positioned(top: 100, left: -50, child: Container(width: 250, height: 250, decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF5CA7FF).withValues(alpha: 0.15), boxShadow: [BoxShadow(color: const Color(0xFF5CA7FF).withValues(alpha: 0.2), blurRadius: 60)]))),
          Positioned(bottom: 50, right: -50, child: Container(width: 200, height: 200, decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF6C63FF).withValues(alpha: 0.15), boxShadow: [BoxShadow(color: const Color(0xFF6C63FF).withValues(alpha: 0.2), blurRadius: 60)]))),

          // 3. Konten Utama
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                  // ==========================================
                  // KARTU DETAIL TUGAS YANG LEBIH HIDUP
                  // ==========================================
                  ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                      child: Container(
                        padding: const EdgeInsets.all(25),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1), 
                          borderRadius: BorderRadius.circular(25), 
                          border: Border.all(color: Colors.white.withValues(alpha: 0.2))
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header Kartu: Kategori & Status
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF8B78FF).withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: const Color(0xFF8B78FF).withValues(alpha: 0.5)),
                                  ),
                                  child: Text(
                                    widget.task.kategori, 
                                    style: const TextStyle(color: Color(0xFF8B78FF), fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                ),
                                if (widget.task.isStarted)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(color: Colors.orangeAccent.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                                    child: const Row(
                                      children: [
                                        Icon(Icons.pending_actions_rounded, color: Colors.orangeAccent, size: 14),
                                        SizedBox(width: 5),
                                        Text("In Progress", style: TextStyle(color: Colors.orangeAccent, fontSize: 11, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            
                            // Judul Tugas
                            Text(widget.task.judul, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white, height: 1.2)),
                            const SizedBox(height: 20),
                            
                            // Baris Info Deadline
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
                              child: Row(
                                children: [
                                  const Icon(Icons.event_busy_rounded, color: Colors.redAccent, size: 20),
                                  const SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text("Tenggat Waktu", style: TextStyle(color: Colors.white54, fontSize: 11)),
                                      const SizedBox(height: 2),
                                      Text("$tanggalBatas • Jam $jamBatas", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Divider(color: Colors.white24, height: 1),
                            ),

                            // Deskripsi
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(color: const Color(0xFF5CA7FF).withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                                  child: const Icon(Icons.subject_rounded, color: Color(0xFF5CA7FF), size: 18),
                                ),
                                const SizedBox(width: 10),
                                const Text("Deskripsi:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              widget.task.deskripsi.isEmpty ? "Tidak ada rincian deskripsi." : widget.task.deskripsi, 
                              style: const TextStyle(fontSize: 15, color: Colors.white70, height: 1.6)
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 35),

                  // ==========================================
                  // AREA TOMBOL & KAMERA
                  // ==========================================
                  if (!widget.task.isStarted && !widget.task.isDone)
                    Container(
                      width: double.infinity, height: 60,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFF6C63FF), Color(0xFF5CA7FF)]),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: const Color(0xFF6C63FF).withValues(alpha: 0.4), blurRadius: 15, offset: const Offset(0, 5))],
                      ),
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                        onPressed: () => _updateStatus(true),
                        icon: const Icon(Icons.play_circle_fill_rounded, color: Colors.white, size: 28),
                        label: const Text("MULAI KERJAKAN TUGAS INI", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1, color: Colors.white, fontSize: 15)),
                      ),
                    ),

                  if (widget.task.isStarted && !widget.task.isDone) ...[
                    const Row(
                      children: [
                        Icon(Icons.camera_alt_rounded, color: Colors.white70, size: 20),
                        SizedBox(width: 8),
                        Text("Upload Bukti (Foto):", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
                      ],
                    ),
                    const SizedBox(height: 15),
                    GestureDetector(
                      onTap: _takePicture,
                      child: Container(
                        height: 220, width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: _imagePath == null ? const Color(0xFF5CA7FF).withValues(alpha: 0.5) : Colors.green.withValues(alpha: 0.8), width: 2),
                          boxShadow: _imagePath == null ? [] : [BoxShadow(color: Colors.green.withValues(alpha: 0.2), blurRadius: 20)],
                        ),
                        child: _imagePath == null
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(20), 
                                    decoration: BoxDecoration(color: const Color(0xFF5CA7FF).withValues(alpha: 0.2), shape: BoxShape.circle), 
                                    child: const Icon(Icons.add_a_photo_rounded, size: 45, color: Color(0xFF5CA7FF))
                                  ), 
                                  const SizedBox(height: 15),
                                  const Text("Ketuk area ini untuk memotret bukti", style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600))
                                ],
                              )
                            : ClipRRect(borderRadius: BorderRadius.circular(18), child: Image.file(File(_imagePath!), fit: BoxFit.cover)),
                      ),
                    ),
                    const SizedBox(height: 25),
                    
                    Container(
                      decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.white.withValues(alpha: 0.15))),
                      child: TextField(
                        controller: _catatanController, maxLines: 3, style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "Tulis catatan hasil tugasmu di sini...", 
                          hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)), 
                          border: InputBorder.none, 
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15)
                        ),
                      ),
                    ),
                    const SizedBox(height: 35),
                    
                    Container(
                      width: double.infinity, height: 60,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFF00E676), Color(0xFF00C853)]),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: const Color(0xFF00E676).withValues(alpha: 0.4), blurRadius: 15, offset: const Offset(0, 5))],
                      ),
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                        onPressed: _completeTask,
                        icon: const Icon(Icons.check_circle_rounded, color: Colors.white, size: 26),
                        label: const Text("TANDAI SELESAI", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.white, fontSize: 16)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}