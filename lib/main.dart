import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'screens/login_screen.dart'; 
import 'helpers/notification_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  
  // INI YANG PENTING: Nyalakan mesin alarm saat aplikasi pertama dibuka
  await NotificationHelper.init(); 
  
  runApp(const MyApp());
}

// ... (Sisa kode class MyApp { ... } biarkan sama seperti aslinya)

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pengingat Tugas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light, 
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5CA7FF),
          primary: const Color(0xFF5CA7FF),
        ),
        scaffoldBackgroundColor: Colors.transparent, 
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        datePickerTheme: const DatePickerThemeData(
          headerBackgroundColor: Color(0xFF5CA7FF),
          headerForegroundColor: Colors.white,
          surfaceTintColor: Colors.white,
        ),
        timePickerTheme: const TimePickerThemeData(
          backgroundColor: Colors.white,
          hourMinuteTextColor: Color(0xFF5CA7FF),
        ),
        bottomAppBarTheme: const BottomAppBarThemeData(
          color: Colors.white,
          elevation: 10,
        ),
      ),
      home: const LoginScreen(), // UBAH KE SINI AGAR BUKA LOGIN DULUAN
    );
  }
}