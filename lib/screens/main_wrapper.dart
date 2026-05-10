import 'dart:ui';
import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'mata_kuliah_screen.dart';
import 'riwayat_screen.dart';
import 'profile_screen.dart';
import 'add_task_screen.dart';

class MainWrapper extends StatefulWidget {
  final String userName; 

  const MainWrapper({super.key, required this.userName});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _currentIndex = 0;
  bool _isDarkMode = true; // Kita paksa true karena temanya sekarang Dark Space

  final GlobalKey<HomeScreenState> _homeKey = GlobalKey<HomeScreenState>();

  void _toggleTheme(bool value) {
    setState(() {
      _isDarkMode = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      HomeScreen(key: _homeKey, isDarkMode: _isDarkMode, onThemeChanged: _toggleTheme, userName: widget.userName),
      MataKuliahScreen(isDarkMode: _isDarkMode),
      RiwayatScreen(isDarkMode: _isDarkMode), 
      ProfileScreen(isDarkMode: _isDarkMode, userName: widget.userName),
    ];

    // Warna Tema Baru
    final activeColor = const Color(0xFF5CA7FF); // Biru menyala
    final inactiveColor = Colors.white54;

    return Scaffold(
      extendBody: true, // Memastikan background layar memanjang sampai ke bawah navbar
      backgroundColor: const Color(0xFF0F2027), // Warna dasar gelap
      body: screens[_currentIndex], 
      
      // Tombol (+) Menyala di tengah
      floatingActionButton: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6C63FF).withValues(alpha: 0.5), 
              blurRadius: 20, 
              spreadRadius: 2,
              offset: const Offset(0, 5)
            )
          ]
        ),
        child: FloatingActionButton(
          backgroundColor: const Color(0xFF6C63FF),
          shape: const CircleBorder(),
          elevation: 0,
          onPressed: () async {
            await Navigator.push(
              context, 
              MaterialPageRoute(builder: (context) => const AddTaskScreen())
            );
            _homeKey.currentState?.refreshData();
          },
          child: const Icon(Icons.add_rounded, size: 38, color: Colors.white), 
        ),
      ),
      
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      
      // Navbar Bawah ala Glassmorphism
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: BottomAppBar(
            color: Colors.black.withValues(alpha: 0.4), // Gelap transparan
            shape: const CircularNotchedRectangle(),
            notchMargin: 10.0,
            elevation: 0,
            child: Container(
              height: 65,
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.1), width: 1)), 
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildNavItem(0, Icons.home_rounded, "Beranda", activeColor, inactiveColor),
                        _buildNavItem(1, Icons.book_rounded, "Matkul", activeColor, inactiveColor),
                      ],
                    ),
                  ),
                  const SizedBox(width: 48), // Ruang untuk FAB
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildNavItem(2, Icons.assignment_turned_in_rounded, "Riwayat", activeColor, inactiveColor),
                        _buildNavItem(3, Icons.person_rounded, "Profil", activeColor, inactiveColor),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, Color activeColor, Color inactiveColor) {
    final isSelected = _currentIndex == index;
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () => setState(() => _currentIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: isSelected ? activeColor : inactiveColor, size: isSelected ? 28 : 24),
          const SizedBox(height: 4),
          Text(
            label, 
            style: TextStyle(
              fontSize: 11,
              color: isSelected ? activeColor : inactiveColor,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}