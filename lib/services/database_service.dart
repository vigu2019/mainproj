import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'app_scans.db');

    return await databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE scans(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              type TEXT,
              model TEXT,
              timestamp TEXT,
              item_count INTEGER,
              status TEXT
            )
          ''');
        },
      ),
    );
  }

  Future<int> insertScan(Map<String, dynamic> scan) async {
    final db = await database;
    return await db.insert('scans', scan, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getScans({int limit = 10}) async {
    final db = await database;
    return await db.query(
      'scans',
      orderBy: 'id DESC',
      limit: limit,
    );
  }

  Future<int> deleteScan(int id) async {
    final db = await database;
    return await db.delete('scans', where: 'id = ?', whereArgs: [id]);
  }
}
