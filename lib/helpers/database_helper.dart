import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/task.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('pengingat_tugas.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    // VERSI 5: Menambahkan kolom 'warna' di tabel mata_kuliah
    return await openDatabase(path, version: 5, onCreate: _createDB, onUpgrade: _upgradeDB);
  }

  Future _createDB(Database db, int version) async {
    // Tabel Tugas
    await db.execute('''
      CREATE TABLE tasks(
        id TEXT PRIMARY KEY,
        judul TEXT,
        deskripsi TEXT,
        deadline TEXT,
        reminderTime TEXT,
        kategori TEXT,
        prioritas INTEGER,
        isStarted INTEGER,
        isDone INTEGER,
        isLate INTEGER,
        imagePath TEXT,
        catatan TEXT,
        completedAt TEXT
      )
    ''');

    // Tabel Akun
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        email TEXT UNIQUE,
        password TEXT
      )
    ''');

    // Tabel Kategori Mata Kuliah (DIUPDATE: Tambah kolom warna TEXT)
    await db.execute('''
      CREATE TABLE mata_kuliah(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama_mk TEXT UNIQUE,
        warna TEXT
      )
    ''');

    // Tambahkan 1 Mata Kuliah Default (Warna biru default)
    await db.insert('mata_kuliah', {'nama_mk': 'Umum', 'warna': '0xFF5CA7FF'});
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    await db.execute('DROP TABLE IF EXISTS tasks');
    await db.execute('DROP TABLE IF EXISTS users');
    await db.execute('DROP TABLE IF EXISTS mata_kuliah');
    await _createDB(db, newVersion);
  }

  // ==========================================
  // FUNGSI AKUN (LOGIN/REGISTER)
  // ==========================================
  Future<bool> registerUser(String name, String email, String password) async {
    final db = await instance.database;
    try {
      await db.insert('users', {'name': name, 'email': email, 'password': password});
      return true;
    } catch (e) {
      return false; 
    }
  }

  Future<String?> loginUser(String email, String password) async {
    final db = await instance.database;
    final maps = await db.query('users', where: 'email = ? AND password = ?', whereArgs: [email, password]);
    if (maps.isNotEmpty) return maps.first['name'] as String; 
    return null; 
  }

  // ==========================================
  // FUNGSI MATA KULIAH (KATEGORI)
  // ==========================================
  
  // MENGAMBIL MK BESERTA WARNANYA
  Future<List<Map<String, dynamic>>> getMataKuliahLengkap() async {
    final db = await instance.database;
    return await db.query('mata_kuliah');
  }

  // FUNGSI LAMA (Dibiarkan agar tidak error di HomeScreen)
  Future<List<String>> getMataKuliah() async {
    final db = await instance.database;
    final maps = await db.query('mata_kuliah');
    return maps.map((map) => map['nama_mk'] as String).toList();
  }

  // MENAMBAH MK BARU DENGAN WARNA
  Future<void> insertMataKuliahWarna(String namaMk, String hexColor) async {
    final db = await instance.database;
    try {
      await db.insert('mata_kuliah', {'nama_mk': namaMk, 'warna': hexColor});
    } catch (e) {
      // Abaikan jika nama MK sudah ada
    }
  }

  // MENGUPDATE MK (EDIT NAMA/WARNA)
  Future<void> updateMataKuliah(String oldName, String newName, String newColor) async {
    final db = await instance.database;
    await db.update(
      'mata_kuliah', 
      {'nama_mk': newName, 'warna': newColor}, 
      where: 'nama_mk = ?', 
      whereArgs: [oldName]
    );

    // Keren: Update juga nama kategori di tabel tasks agar datanya tetap sinkron!
    await db.update(
      'tasks', 
      {'kategori': newName}, 
      where: 'kategori = ?', 
      whereArgs: [oldName]
    );
  }

  // MENGHAPUS MK
 Future<void> deleteMataKuliah(String namaMk) async {
    final db = await instance.database;
    // 1. Hapus semua tugas (pending & riwayat) yang kategorinya sama dengan namaMk
    await db.delete('tasks', where: 'kategori = ?', whereArgs: [namaMk]);
    
    // 2. Hapus matkul dari daftar kategori
    await db.delete('mata_kuliah', where: 'nama_mk = ?', whereArgs: [namaMk]);
  }

  // ==========================================
  // FUNGSI TUGAS
  // ==========================================
  Future<void> insertTask(Task task) async {
    final db = await instance.database;
    await db.insert('tasks', task.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Task>> getAllTasks() async {
    final db = await instance.database;
    final maps = await db.query('tasks');
    return maps.map((map) => Task.fromMap(map)).toList();
  }

  Future<void> updateTask(Task task) async {
    final db = await instance.database;
    await db.update('tasks', task.toMap(), where: 'id = ?', whereArgs: [task.id]);
  }

  Future<void> deleteTask(String id) async {
    final db = await instance.database;
    await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }
}