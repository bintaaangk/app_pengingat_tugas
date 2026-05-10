import 'dart:ui';
import 'package:flutter/material.dart';
import '../helpers/database_helper.dart';

class MataKuliahScreen extends StatefulWidget {
  final bool isDarkMode;
  const MataKuliahScreen({super.key, required this.isDarkMode});

  @override
  State<MataKuliahScreen> createState() => _MataKuliahScreenState();
}

class _MataKuliahScreenState extends State<MataKuliahScreen> {
  List<Map<String, dynamic>> _listMK = [];
  bool _isLoading = true;

  final List<Color> _colorChoices = [
    const Color(0xFF5CA7FF), const Color(0xFFFF7B7B), const Color(0xFF4ADE80), 
    const Color(0xFFFFB020), const Color(0xFF9C27B0), const Color(0xFF00BCD4), 
    const Color(0xFFFF9800), const Color(0xFF795548),
  ];

  @override
  void initState() {
    super.initState();
    _fetchMK();
  }

  void _fetchMK() async {
    final data = await DatabaseHelper.instance.getMataKuliahLengkap();
    setState(() {
      _listMK = data; 
      _isLoading = false;
    });
  }

  Color _colorFromHex(String? hexString) {
    if (hexString == null || hexString.isEmpty) return const Color(0xFF5CA7FF);
    String hex = hexString.replaceAll(RegExp(r'#|0x|0X'), '');
    if (hex.length == 6) hex = 'FF$hex'; 
    try {
      return Color(int.parse(hex, radix: 16));
    } catch (e) {
      return const Color(0xFF5CA7FF); 
    }
  }

  String _colorToHex(Color color) {
    return '0xFF${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2, 8).toUpperCase()}';
  }

  // BOTTOM SHEET KACA (GLASSMORPHISM)
  void _showFormModal({String? oldName, String? oldColorHex}) {
    final txtController = TextEditingController(text: oldName ?? "");
    Color selectedColor = _colorFromHex(oldColorHex);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return Container(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom + 30,
                  top: 20, left: 25, right: 25
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                  border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.2))),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(child: Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.white38, borderRadius: BorderRadius.circular(10)))),
                    const SizedBox(height: 25),
                    
                    Text(oldName == null ? "Tambah Mata Kuliah 📚" : "Edit Mata Kuliah ✏️", style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 25),

                    // Input Nama Matkul Transparan
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                      ),
                      child: TextField(
                        controller: txtController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: "Nama Mata Kuliah",
                          labelStyle: const TextStyle(color: Colors.white70),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),

                    const Text("Pilih Warna Label:", style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 15),
                    Wrap(
                      spacing: 12, runSpacing: 12,
                      children: _colorChoices.map((c) {
                        bool isSelected = selectedColor == c;
                        return GestureDetector(
                          onTap: () => setModalState(() => selectedColor = c),
                          child: Container(
                            width: 40, height: 40,
                            decoration: BoxDecoration(
                              color: c, shape: BoxShape.circle,
                              border: isSelected ? Border.all(color: Colors.white, width: 3) : null,
                              boxShadow: isSelected ? [BoxShadow(color: c.withValues(alpha: 0.6), blurRadius: 10, spreadRadius: 2)] : [],
                            ),
                            child: isSelected ? const Icon(Icons.check_rounded, color: Colors.white, size: 24) : null,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 40),

                    // Tombol Simpan Gradient
                    Container(
                      width: double.infinity, height: 55,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFF6C63FF), Color(0xFF5CA7FF)]),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: const Color(0xFF6C63FF).withValues(alpha: 0.4), blurRadius: 15, offset: const Offset(0, 5))],
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                        onPressed: () async {
                          if (txtController.text.trim().isEmpty) return;
                          String newHexColor = _colorToHex(selectedColor);
                          if (oldName == null) {
                            await DatabaseHelper.instance.insertMataKuliahWarna(txtController.text.trim(), newHexColor);
                          } else {
                            await DatabaseHelper.instance.updateMataKuliah(oldName, txtController.text.trim(), newHexColor);
                          }
                          if (context.mounted) Navigator.pop(context); 
                          _fetchMK(); 
                        },
                        child: const Text("SIMPAN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.5)),
                      ),
                    )
                  ],
                ),
              );
            }
          ),
        );
      }
    );
  }

  void _hapusMK(String namaMk) async {
    showDialog(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          backgroundColor: const Color(0xFF1A1C20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
          title: const Text("Hapus Matkul?", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: Text("Apakah kamu yakin ingin menghapus '$namaMk'?", style: const TextStyle(color: Colors.white70)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal", style: TextStyle(color: Colors.white54))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              onPressed: () async {
                Navigator.pop(context);
                await DatabaseHelper.instance.deleteMataKuliah(namaMk);
                _fetchMK();
              },
              child: const Text("Hapus", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Mata Kuliah", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1)),
        backgroundColor: Colors.transparent, elevation: 0, centerTitle: true,
      ),
      body: Stack(
        children: [
          // Background Tema Premium
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)]),
            ),
          ),
          Positioned(top: 50, right: -50, child: Container(width: 200, height: 200, decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF5CA7FF).withValues(alpha: 0.15), boxShadow: [BoxShadow(color: const Color(0xFF5CA7FF).withValues(alpha: 0.2), blurRadius: 60)]))),

          SafeArea(
            child: Column(
              children: [
                // Banner Kaca
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          children: [
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Kelola Kategori 📚", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                  SizedBox(height: 5),
                                  Text("Beri warna tugasmu agar lebih rapi.", style: TextStyle(color: Colors.white70, fontSize: 13)),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () => _showFormModal(),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF6C63FF), shape: BoxShape.circle,
                                  boxShadow: [BoxShadow(color: const Color(0xFF6C63FF).withValues(alpha: 0.4), blurRadius: 10, spreadRadius: 1)]
                                ),
                                child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Daftar Matkul
                Expanded(
                  child: _isLoading 
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF5CA7FF)))
                  : _listMK.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.folder_open_rounded, size: 80, color: Colors.white.withValues(alpha: 0.3)),
                            const SizedBox(height: 15),
                            const Text("Belum ada Mata Kuliah", style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 120, top: 10), 
                        itemCount: _listMK.length,
                        itemBuilder: (context, index) {
                          final mk = _listMK[index];
                          String namaMatkul = mk['nama_mk'];
                          Color warnaMatkul = _colorFromHex(mk['warna']);
                          String hurufPertama = namaMatkul.isNotEmpty ? namaMatkul[0].toUpperCase() : "?";

                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                    leading: Container(
                                      width: 48, height: 48,
                                      decoration: BoxDecoration(color: warnaMatkul.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(15), border: Border.all(color: warnaMatkul.withValues(alpha: 0.5))),
                                      alignment: Alignment.center,
                                      child: Text(hurufPertama, style: TextStyle(color: warnaMatkul, fontWeight: FontWeight.bold, fontSize: 20)),
                                    ),
                                    title: Text(namaMatkul, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit_rounded, color: Colors.white70, size: 22),
                                          onPressed: () => _showFormModal(oldName: namaMatkul, oldColorHex: mk['warna']),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 24),
                                          onPressed: () => _hapusMK(namaMatkul),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}