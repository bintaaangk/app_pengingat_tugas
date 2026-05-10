import 'dart:ui';
import 'package:flutter/material.dart';
import '../helpers/database_helper.dart';
import '../helpers/notification_helper.dart';
import '../models/task.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _judulController = TextEditingController();
  final _deskripsiController = TextEditingController();
  
  DateTime _deadlineDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _deadlineTime = const TimeOfDay(hour: 13, minute: 0);
  DateTime _reminderDate = DateTime.now();
  TimeOfDay _reminderTime = const TimeOfDay(hour: 13, minute: 0);

  String? _selectedKategori;
  List<String> _categories = ["Umum"]; 

  @override
  void initState() {
    super.initState();
    _loadMataKuliah();
  }

  void _loadMataKuliah() async {
    final dbCategories = await DatabaseHelper.instance.getMataKuliah();
    setState(() {
      if (dbCategories.isNotEmpty) _categories = dbCategories;
      _selectedKategori = _categories.first;
    });
  }

  void _saveTask() async {
    if (_judulController.text.trim().isEmpty || _selectedKategori == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: Colors.redAccent, content: Text("Judul dan Mata Kuliah tidak boleh kosong!")));
      return;
    }

    final deadlineFinal = DateTime(_deadlineDate.year, _deadlineDate.month, _deadlineDate.day, _deadlineTime.hour, _deadlineTime.minute);
    final reminderFinal = DateTime(_reminderDate.year, _reminderDate.month, _reminderDate.day, _reminderTime.hour, _reminderTime.minute);

    if (reminderFinal.isAfter(deadlineFinal)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: Colors.redAccent, content: Text("Waktu pengingat tidak boleh melebihi deadline!")));
      return;
    }

    int notificationId = DateTime.now().millisecondsSinceEpoch.remainder(100000);

    final newTask = Task(
      id: notificationId.toString(),
      judul: _judulController.text,
      deskripsi: _deskripsiController.text,
      deadline: deadlineFinal,
      reminderTime: reminderFinal, 
      kategori: _selectedKategori!,
      prioritas: 2, 
    );

    await DatabaseHelper.instance.insertTask(newTask);
    if (mounted) Navigator.pop(context);

    try {
      await NotificationHelper.scheduleNaggingNotifications(
        id: notificationId, title: newTask.judul,
        body: "Deadline $_selectedKategori: ${deadlineFinal.day}/${deadlineFinal.month} Jam ${deadlineFinal.hour}:${deadlineFinal.minute.toString().padLeft(2, '0')}",
        startNagging: reminderFinal, deadline: deadlineFinal,
      );
    } catch (e) {
      debugPrint("Gagal: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Tambah Tugas Baru", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)]),
            ),
          ),
          Positioned(top: -50, right: -50, child: Container(width: 200, height: 200, decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF6C63FF).withValues(alpha: 0.15), boxShadow: [BoxShadow(color: const Color(0xFF6C63FF).withValues(alpha: 0.2), blurRadius: 60)]))),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel("Judul Tugas"),
                  _buildTextField(_judulController, "Contoh: Project Akhir..."),
                  const SizedBox(height: 20),

                  _buildLabel("Mata Kuliah"),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.white.withValues(alpha: 0.1))),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        dropdownColor: const Color(0xFF203A43),
                        value: _selectedKategori,
                        isExpanded: true,
                        icon: const Icon(Icons.arrow_drop_down_rounded, color: Colors.white70),
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                        items: _categories.map((val) => DropdownMenuItem(value: val, child: Text(val))).toList(),
                        onChanged: (val) => setState(() => _selectedKategori = val!),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  _buildLabel("Deskripsi Tugas"),
                  _buildTextField(_deskripsiController, "Detail pengerjaan...", maxLines: 3),
                  const SizedBox(height: 30),

                  _buildLabel("📅 Tenggat Tugas (Deadline)"),
                  Row(
                    children: [
                      Expanded(child: _buildPickerCard(label: "Tanggal", value: "${_deadlineDate.day}/${_deadlineDate.month}/${_deadlineDate.year}", icon: Icons.event, onTap: () async {
                        final d = await showDatePicker(context: context, initialDate: _deadlineDate, firstDate: DateTime.now(), lastDate: DateTime(2100));
                        if (d != null) setState(() => _deadlineDate = d);
                      })),
                      const SizedBox(width: 15),
                      Expanded(child: _buildPickerCard(label: "Jam", value: _deadlineTime.format(context), icon: Icons.access_time, onTap: () async {
                        final t = await showTimePicker(context: context, initialTime: _deadlineTime);
                        if (t != null) setState(() => _deadlineTime = t);
                      })),
                    ],
                  ),
                  const SizedBox(height: 25),

                  _buildLabel("🔔 Mulai Ingatkan Saya (Sistem Rewel)"),
                  Row(
                    children: [
                      Expanded(child: _buildPickerCard(label: "Tanggal", value: "${_reminderDate.day}/${_reminderDate.month}/${_reminderDate.year}", icon: Icons.notifications_active, onTap: () async {
                        final d = await showDatePicker(context: context, initialDate: _reminderDate, firstDate: DateTime.now(), lastDate: _deadlineDate);
                        if (d != null) setState(() => _reminderDate = d);
                      })),
                      const SizedBox(width: 15),
                      Expanded(child: _buildPickerCard(label: "Jam", value: _reminderTime.format(context), icon: Icons.timer, onTap: () async {
                        final t = await showTimePicker(context: context, initialTime: _reminderTime);
                        if (t != null) setState(() => _reminderTime = t);
                      })),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 10.0),
                    child: Text("*Aplikasi akan mengirim notifikasi tiap 2 jam sejak waktu ini.", style: TextStyle(fontSize: 12, color: Colors.white54, fontStyle: FontStyle.italic)),
                  ),

                  const SizedBox(height: 40),
                  Container(
                    width: double.infinity, height: 55,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF6C63FF), Color(0xFF5CA7FF)]),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: const Color(0xFF6C63FF).withValues(alpha: 0.4), blurRadius: 15, offset: const Offset(0, 5))],
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                      onPressed: _saveTask,
                      child: const Text("SIMPAN & AKTIFKAN", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white, letterSpacing: 1)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) => Padding(padding: const EdgeInsets.only(bottom: 10), child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)));
  
  Widget _buildTextField(TextEditingController ctrl, String hint, {int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.white.withValues(alpha: 0.1))),
      child: TextField(
        controller: ctrl, maxLines: maxLines, style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(hintText: hint, hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)), border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15)),
      ),
    );
  }

  Widget _buildPickerCard({required String label, required String value, required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap, 
      borderRadius: BorderRadius.circular(15),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            padding: const EdgeInsets.all(15), 
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.white.withValues(alpha: 0.2))), 
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, 
              children: [
                Row(children: [Icon(icon, size: 16, color: const Color(0xFF5CA7FF)), const SizedBox(width: 8), Text(label, style: const TextStyle(fontSize: 12, color: Colors.white70))]), 
                const SizedBox(height: 8), 
                Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white))
              ]
            )
          ),
        ),
      )
    );
  }
}