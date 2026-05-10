import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../helpers/database_helper.dart';
import '../models/task.dart';
import 'detail_riwayat_screen.dart';

class RiwayatScreen extends StatefulWidget {
  final bool isDarkMode; 

  const RiwayatScreen({super.key, required this.isDarkMode});

  @override
  State<RiwayatScreen> createState() => _RiwayatScreenState();
}

class _RiwayatScreenState extends State<RiwayatScreen> {
  String _selectedCategory = "Semua";
  List<String> _categories = ["Semua"];
  bool _isLoading = true;
  
  List<Task> _allCompletedTasks = [];
  List<Task> _filteredTasks = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    final dataTasks = await DatabaseHelper.instance.getAllTasks();
    final dataMK = await DatabaseHelper.instance.getMataKuliahLengkap(); 
    
    setState(() {
      _allCompletedTasks = dataTasks.where((t) => t.isDone).toList();
      _categories = ["Semua", ...dataMK.map((e) => e['nama_mk'].toString())]; 
      
      if (!_categories.contains(_selectedCategory)) {
        _selectedCategory = "Semua";
      }
      
      _applyFilter();
      _isLoading = false;
    });
  }

  void _applyFilter() {
    setState(() {
      if (_selectedCategory == "Semua") {
        _filteredTasks = _allCompletedTasks;
      } else {
        _filteredTasks = _allCompletedTasks.where((t) => t.kategori == _selectedCategory).toList();
      }
    });
  }

  // FUNGSI BARU: Hapus Tugas dari Riwayat
  void _hapusTugas(String taskId, String taskTitle) async {
    // Munculkan dialog konfirmasi sebelum hapus
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          backgroundColor: const Color(0xFF1A1C20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
          title: const Text("Hapus Arsip?", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: Text("Yakin ingin menghapus '$taskTitle' dari riwayat secara permanen?", style: const TextStyle(color: Colors.white70)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Batal", style: TextStyle(color: Colors.white54))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Hapus", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );

    if (confirm == true) {
      await DatabaseHelper.instance.deleteTask(taskId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: Colors.green, content: Text("Arsip tugas berhasil dihapus.")));
      _loadData(); // Refresh list
    }
  }

  String _formatTanggal(DateTime? dt) {
    if (dt == null) return "Waktu tidak dicatat";
    String pad(int n) => n.toString().padLeft(2, '0');
    return "${pad(dt.day)}/${pad(dt.month)}/${dt.year} • ${pad(dt.hour)}:${pad(dt.minute)}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Riwayat Tugas", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)]),
            ),
          ),
          Positioned(bottom: -50, right: -50, child: Container(width: 300, height: 300, decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF00E676).withValues(alpha: 0.1), boxShadow: [BoxShadow(color: const Color(0xFF00E676).withValues(alpha: 0.15), blurRadius: 60)]))),

          SafeArea(
            child: Column(
              children: [
                if (!_isLoading && _categories.length > 1)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _categories.map((cat) {
                          final isSelected = _selectedCategory == cat;
                          return Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: ChoiceChip(
                              label: Text(
                                cat, 
                                style: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontWeight: FontWeight.bold)
                              ),
                              selected: isSelected,
                              onSelected: (val) {
                                setState(() => _selectedCategory = cat);
                                _applyFilter();
                              },
                              selectedColor: const Color(0xFF8B78FF), 
                              backgroundColor: Colors.white,
                              side: BorderSide.none,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              showCheckmark: false,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),

                Expanded(
                  child: _isLoading 
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFF00E676)))
                    : _filteredTasks.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(25),
                                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), shape: BoxShape.circle),
                                child: Icon(Icons.history_edu_rounded, size: 80, color: Colors.white.withValues(alpha: 0.3)),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                _selectedCategory == "Semua" ? "Belum ada tugas selesai 🚀" : "Belum ada arsip untuk kategori ini", 
                                style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 16, fontWeight: FontWeight.bold)
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.only(bottom: 120, top: 10), 
                          itemCount: _filteredTasks.length,
                          itemBuilder: (context, index) {
                            final task = _filteredTasks[index];
                            
                            return Dismissible(
                              key: Key(task.id),
                              direction: DismissDirection.endToStart, // Swipe dari kanan ke kiri
                              confirmDismiss: (direction) async {
                                _hapusTugas(task.id, task.judul);
                                return false; // Kembalikan false agar item tidak langsung hilang sebelum dikonfirmasi
                              },
                              background: Container(
                                alignment: Alignment.centerRight,
                                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                padding: const EdgeInsets.only(right: 20),
                                decoration: BoxDecoration(color: Colors.redAccent.withValues(alpha: 0.8), borderRadius: BorderRadius.circular(20)),
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.delete_forever_rounded, color: Colors.white, size: 30),
                                    SizedBox(height: 4),
                                    Text("Hapus", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))
                                  ],
                                ),
                              ),
                              child: GestureDetector(
                                onTap: () async {
                                  await Navigator.push(
                                    context, 
                                    MaterialPageRoute(builder: (context) => DetailRiwayatScreen(task: task))
                                  );
                                  _loadData(); 
                                },
                                child: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: BackdropFilter(
                                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                      child: Container(
                                        padding: const EdgeInsets.all(15),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.05),
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                                        ),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              width: 70, height: 70,
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF00E676).withValues(alpha: 0.1),
                                                borderRadius: BorderRadius.circular(15),
                                                border: Border.all(color: const Color(0xFF00E676).withValues(alpha: 0.3), width: 1.5),
                                              ),
                                              child: task.imagePath != null && task.imagePath!.isNotEmpty
                                                  ? ClipRRect(
                                                      borderRadius: BorderRadius.circular(13),
                                                      child: Image.file(File(task.imagePath!), fit: BoxFit.cover,
                                                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported, color: Colors.white54),
                                                      ),
                                                    )
                                                  : const Icon(Icons.check_circle_rounded, color: Color(0xFF00E676), size: 35),
                                            ),
                                            const SizedBox(width: 15),

                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    task.judul, 
                                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
                                                    maxLines: 2, overflow: TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Row(
                                                    children: [
                                                      Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                        decoration: BoxDecoration(color: const Color(0xFF8B78FF).withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                                                        child: Text(task.kategori, style: const TextStyle(color: Color(0xFF8B78FF), fontSize: 10, fontWeight: FontWeight.bold)),
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                        decoration: BoxDecoration(color: const Color(0xFF00E676).withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                                                        child: const Text("Tuntas", style: TextStyle(color: Color(0xFF00E676), fontSize: 10, fontWeight: FontWeight.bold)),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 12),
                                                  Row(
                                                    children: [
                                                      const Icon(Icons.access_time_filled_rounded, color: Colors.white54, size: 14),
                                                      const SizedBox(width: 5),
                                                      Text(
                                                        "Diselesaikan: ${_formatTanggal(task.completedAt)}", 
                                                        style: const TextStyle(color: Colors.white54, fontSize: 11),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}