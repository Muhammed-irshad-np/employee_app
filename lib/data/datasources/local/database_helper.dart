import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('employee.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    DatabaseFactory databaseFactory;
    Database db;

    if (kIsWeb) {
      // Use Web version
      databaseFactory = databaseFactoryFfiWeb;
      db = await databaseFactory.openDatabase(filePath);
    } else {
      // Use native version for Android/iOS
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, filePath);
      db = await openDatabase(path, version: 1, onCreate: _createDB);
    }

    // Ensure table is created
    await _createDB(db, 1);
    return db;
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS employees (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        role TEXT NOT NULL,
        startDate TEXT NOT NULL,
        endDate TEXT
      )
    ''');
  }

  Future<void> close() async {
    final db = await instance.database;
    await db.close();
  }
}
