class Task {
  String id;
  String judul;
  String deskripsi;
  DateTime deadline;
  DateTime? reminderTime;
  String? imagePath;
  String? catatan;
  bool isStarted;
  bool isDone;
  bool isLate;
  DateTime? completedAt;
  
  // Fitur Baru
  String kategori; 
  int prioritas; // 1: Tinggi, 2: Sedang, 3: Rendah

  Task({
    required this.id,
    required this.judul,
    required this.deskripsi,
    required this.deadline,
    this.reminderTime,
    this.imagePath,
    this.catatan,
    this.isStarted = false,
    this.isDone = false,
    this.isLate = false,
    this.completedAt,
    this.kategori = "Umum",
    this.prioritas = 2,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'judul': judul,
      'deskripsi': deskripsi,
      'deadline': deadline.toIso8601String(),
      'reminderTime': reminderTime?.toIso8601String(),
      'imagePath': imagePath,
      'catatan': catatan,
      'isStarted': isStarted ? 1 : 0,
      'isDone': isDone ? 1 : 0,
      'isLate': isLate ? 1 : 0,
      'completedAt': completedAt?.toIso8601String(),
      'kategori': kategori,
      'prioritas': prioritas,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      judul: map['judul'],
      deskripsi: map['deskripsi'],
      deadline: DateTime.parse(map['deadline']),
      reminderTime: map['reminderTime'] != null ? DateTime.parse(map['reminderTime']) : null,
      imagePath: map['imagePath'],
      catatan: map['catatan'],
      isStarted: map['isStarted'] == 1,
      isDone: map['isDone'] == 1,
      isLate: map['isLate'] == 1,
      completedAt: map['completedAt'] != null ? DateTime.parse(map['completedAt']) : null,
      kategori: map['kategori'] ?? "Umum",
      prioritas: map['prioritas'] ?? 2,
    );
  }
}