import 'dart:async'; // Tambahan untuk Timer
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../helpers/database_helper.dart';
import '../models/task.dart';
import 'detail_task_screen.dart';
import 'profile_screen.dart'; // Tambahkan import ini agar bisa pindah ke profil

class HomeScreen extends StatefulWidget {
  final bool isDarkMode;
  final Function(bool) onThemeChanged;
  final String userName; 

  const HomeScreen({
    super.key, 
    required this.isDarkMode, 
    required this.onThemeChanged,
    required this.userName
  });

  @override
  State<HomeScreen> createState() => HomeScreenState(); 
}

class HomeScreenState extends State<HomeScreen> {
  List<Task> _allTasks = [];
  List<Task> _filteredTasks = [];
  List<Map<String, dynamic>> _kategoriData = []; 
  
  bool _isLoading = true;
  String _searchQuery = "";
  String _selectedCategory = "Semua";
  List<String> _categories = ["Semua"];

  // ==========================================
  // Variabel untuk fitur REWEL
  // ==========================================
  Timer? _rewelTimer;
  bool _isPopupShowing = false; // Mencegah popup menumpuk

  @override
  void initState() {
    super.initState();
    refreshData(); 
    _mulaiSistemRewel(); // Jalankan sistem pengecek rewel saat beranda dibuka
  }

  @override
  void dispose() {
    _rewelTimer?.cancel(); // Matikan timer kalau pindah halaman biar memori aman
    super.dispose();
  }

  // ==========================================
  // SISTEM PENGECEK REWEL (IN-APP NAGGING)
  // ==========================================
  void _mulaiSistemRewel() {
    // Mengecek setiap 10 detik (Bisa diganti jadi per 1 jam atau sesuai kebutuhan)
    _rewelTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _cekTugasRewel();
    });
  }

  Future<void> _cekTugasRewel() async {
    // Kalau popup lagi muncul atau data kosong, jangan cek dulu
    if (_isPopupShowing || _allTasks.isEmpty) return; 

    final sekarang = DateTime.now();

    // Cari tugas yang belum selesai dan waktu 'reminderTime'-nya sudah lewat
    for (var task in _allTasks) {
      // TAMBAHAN: Kita cek dulu task.reminderTime != null, lalu pakai tanda !
      if (!task.isDone && task.reminderTime != null && sekarang.isAfter(task.reminderTime!)) {
        _tampilkanPopupRewel(task);
        break; // Tampilkan 1 popup saja untuk tugas yang mendesak
      }
    }
  }
    
  

  void _tampilkanPopupRewel(Task task) {
    setState(() => _isPopupShowing = true);

    // Format jam deadline
    String pad(int n) => n.toString().padLeft(2, '0');
    String jamDeadline = "${pad(task.deadline.hour)}:${pad(task.deadline.minute)}";
    String tglDeadline = "${pad(task.deadline.day)}/${pad(task.deadline.month)}/${task.deadline.year}";

    showDialog(
      context: context,
      barrierDismissible: false, // Tidak bisa ditutup sembarangan pake klik luar
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1C20).withValues(alpha: 0.8), // Hitam transparan
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.purpleAccent.withValues(alpha: 0.5), width: 2), // Pendar ungu
                boxShadow: [
                  BoxShadow(color: Colors.purpleAccent.withValues(alpha: 0.3), blurRadius: 30, spreadRadius: 5)
                ]
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(color: Colors.purpleAccent.withValues(alpha: 0.2), shape: BoxShape.circle),
                    child: const Icon(Icons.notifications_active_rounded, color: Colors.purpleAccent, size: 50),
                  ),
                  const SizedBox(height: 20),
                  
                  const Text("Misi Hampir Gagal!", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  
                  Text(
                    "Tugas '${task.judul}' kamu sudah memasuki masa 'Rewel'.",
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 15),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(10)),
                    child: Text("Deadline: $tglDeadline, Jam $jamDeadline", style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 15),

                  const Text(
                    "Jangan ditunda lagi, Bintang. Ayo cicil pengerjaannya sekarang!",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 13),
                  ),
                  const SizedBox(height: 25),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C63FF),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        elevation: 10,
                        shadowColor: const Color(0xFF6C63FF).withValues(alpha: 0.5),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() => _isPopupShowing = false);
                        // Arahkan langsung ke Detail Tugas
                        Navigator.push(context, MaterialPageRoute(builder: (context) => DetailTaskScreen(task: task))).then((_) => refreshData());
                      },
                      child: const Text("MULAI KERJAKAN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // Tunda popup 5 menit kalau user pencet 'Nanti Dulu'
                      Future.delayed(const Duration(minutes: 5), () {
                        if (mounted) setState(() => _isPopupShowing = false);
                      });
                    },
                    child: const Text("Nanti Dulu", style: TextStyle(color: Colors.white54)),
                  )
                ],
              ),
            ),
          ),
        );
      }
    );
  }

  Future<void> refreshData() async {
    setState(() => _isLoading = true);
    final dataTasks = await DatabaseHelper.instance.getAllTasks();
    final dataMK = await DatabaseHelper.instance.getMataKuliahLengkap(); 
    
    setState(() {
      _allTasks = dataTasks;
      _kategoriData = dataMK; 
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
      _filteredTasks = _allTasks.where((t) {
        final matchSearch = t.judul.toLowerCase().contains(_searchQuery.toLowerCase());
        final matchCat = _selectedCategory == "Semua" || t.kategori == _selectedCategory;
        return matchSearch && matchCat && !t.isDone;
      }).toList();
    });
  }

  Color _getColorForCategory(String namaKategori) {
    try {
      final mk = _kategoriData.firstWhere((element) => element['nama_mk'] == namaKategori);
      String hexString = mk['warna']?.toString() ?? '0xFF5CA7FF';
      String hex = hexString.replaceAll(RegExp(r'#|0x|0X'), '');
      if (hex.length == 6) hex = 'FF$hex';
      return Color(int.parse(hex, radix: 16));
    } catch (e) {
      return const Color(0xFF5CA7FF); 
    }
  }

  int get _doneCount => _allTasks.where((t) => t.isDone).length;
  int get _pendingCount => _allTasks.where((t) => !t.isDone).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. BACKGROUND DARK SPACE
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
              ),
            ),
          ),

          // 2. ORNAMEN CAHAYA BACKGROUND
          Positioned(
            top: -50, left: -50,
            child: Container(
              width: 200, height: 200,
              decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF5CA7FF).withValues(alpha: 0.2), boxShadow: [BoxShadow(color: const Color(0xFF5CA7FF).withValues(alpha: 0.2), blurRadius: 50)]),
            ),
          ),
          Positioned(
            bottom: -100, right: -50,
            child: Container(
              width: 300, height: 300,
              decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF6C63FF).withValues(alpha: 0.2), boxShadow: [BoxShadow(color: const Color(0xFF6C63FF).withValues(alpha: 0.2), blurRadius: 60)]),
            ),
          ),

          // 3. KONTEN UTAMA
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                
                // Card Statistik Pie Chart (Glassmorphism)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        height: 140,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: PieChart(
                                PieChartData(
                                  sectionsSpace: 2, centerSpaceRadius: 25,
                                  sections: [
                                    PieChartSectionData(value: _doneCount.toDouble(), color: const Color(0xFF00E676), radius: 15, showTitle: false),
                                    PieChartSectionData(value: _pendingCount.toDouble(), color: const Color(0xFFFF9100), radius: 15, showTitle: false),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              flex: 1,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildStatItem("Selesai", _doneCount, const Color(0xFF00E676)),
                                  const SizedBox(height: 12),
                                  _buildStatItem("Pending", _pendingCount, const Color(0xFFFF9100)),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Search Bar (Glassmorphism)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                    ),
                    child: TextField(
                      onChanged: (val) {
                        _searchQuery = val;
                        _applyFilter();
                      },
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Cari tugas...",
                        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                        prefixIcon: const Icon(Icons.search, color: Colors.white70),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      ),
                    ),
                  ),
                ),

                // Kategori Filter (Diperbaiki agar sesuai dengan screenshot)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  child: Row(
                    children: _categories.map((cat) {
                      final isSelected = _selectedCategory == cat;
                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: ChoiceChip(
                          label: Text(
                            cat, 
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87, 
                              fontWeight: FontWeight.bold
                            )
                          ),
                          selected: isSelected,
                          onSelected: (val) {
                            setState(() => _selectedCategory = cat);
                            _applyFilter();
                          },
                          selectedColor: const Color(0xFF8B78FF), // Warna ungu dari desain
                          backgroundColor: Colors.white, // Putih solid sesuai desain
                          side: BorderSide.none, // Hilangkan border tipis
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          showCheckmark: false,
                        ),
                      );
                    }).toList(),
                  ),
                ),

                // List Tugas
                Expanded(
                  child: _isLoading 
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF5CA7FF)))
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 100, top: 10),
                      itemCount: _filteredTasks.length,
                      itemBuilder: (context, index) {
                        final task = _filteredTasks[index];
                        return Dismissible(
                          key: Key(task.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            padding: const EdgeInsets.only(right: 20),
                            decoration: BoxDecoration(color: Colors.redAccent.withValues(alpha: 0.8), borderRadius: BorderRadius.circular(20)),
                            child: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 30),
                          ),
                          onDismissed: (dir) => _deleteTask(task.id),
                          child: _buildTaskCard(task),
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

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Halo, ${widget.userName}! 🚀", 
                  style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                  maxLines: 1, overflow: TextOverflow.ellipsis, 
                ),
                const SizedBox(height: 5),
                Text(
                  "Pantau progress tugasmu hari ini", 
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 14),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Foto Profil yang sudah difungsikan agar bisa diklik
          GestureDetector(
            onTap: () {
              Navigator.push(
                context, 
                MaterialPageRoute(
                  builder: (context) => ProfileScreen(
                    isDarkMode: widget.isDarkMode, 
                    userName: widget.userName
                  )
                )
              );
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
              ),
              child: const Icon(Icons.person_rounded, color: Colors.white, size: 28),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTaskCard(Task task) {
    Color priorityColor = _getColorForCategory(task.kategori);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              leading: Container(
                width: 12, height: 40,
                decoration: BoxDecoration(color: priorityColor, borderRadius: BorderRadius.circular(10), boxShadow: [BoxShadow(color: priorityColor.withValues(alpha: 0.5), blurRadius: 10)])
              ),
              title: Text(task.judul, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(task.kategori, style: TextStyle(color: priorityColor, fontSize: 13, fontWeight: FontWeight.w600)),
              ),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white54, size: 16),
              onTap: () async {
                await Navigator.push(context, MaterialPageRoute(builder: (context) => DetailTaskScreen(task: task)));
                refreshData(); 
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, int count, Color color) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle, boxShadow: [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 8)])),
        const SizedBox(width: 10),
        Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14)),
        Text("$count", style: const TextStyle(color: Colors.white70, fontSize: 14)),
      ],
    );
  }

  void _deleteTask(String id) async {
    await DatabaseHelper.instance.deleteTask(id);
    refreshData();
  }
}