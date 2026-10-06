import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/meme_design_model.dart';
import 'logger_service.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;
  static final ValueNotifier<int> savedMemesChangeNotifier = ValueNotifier<int>(0);

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    try {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, 'meme_designs.db');

      return await openDatabase(
        path,
        version: 1,
        onCreate: _createDb,
      );
    } catch (e, stack) {
      AppLogger.logError(
        'DATABASE',
        'Database initialization failed',
        e,
        stack,
      );
      rethrow;
    }
  }

  Future<void> _createDb(Database db, int version) async {
    AppLogger.logInfo('DATABASE', 'Creating meme_designs database schema v$version');
    await db.execute('''
      CREATE TABLE meme_designs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        backgroundImageBytes BLOB,
        backgroundColor INTEGER,
        text TEXT,
        textAlign INTEGER,
        fontFamily TEXT,
        fontSize REAL,
        fontWeight TEXT,
        textColor INTEGER,
        imageBytes BLOB,
        createdAt TEXT
      )
    ''');
  }

  // CRUD operations
  Future<int> insertMemeDesign(MemeDesign meme) async {
    try {
      final db = await database;
      final id = await db.insert('meme_designs', meme.toJson());
      AppLogger.logInfo('DATABASE', 'Inserted meme design #$id into database');
      savedMemesChangeNotifier.value++;
      return id;
    } catch (e, stack) {
      AppLogger.logError(
        'DATABASE',
        'Failed to insert meme design',
        e,
        stack,
      );
      return -1;
    }
  }

  Future<List<MemeDesign>> getAllMemeDesigns() async {
    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      return [];
    }
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps =
          await db.query('meme_designs', orderBy: 'createdAt DESC');
      AppLogger.logInfo('DATABASE', 'Fetched ${maps.length} saved meme designs');
      return List.generate(maps.length, (i) => MemeDesign.fromJson(maps[i]));
    } catch (e, stack) {
      AppLogger.logError(
        'DATABASE',
        'Failed to query meme designs',
        e,
        stack,
      );
      return [];
    }
  }

  Future<int> updateMemeDesign(MemeDesign meme) async {
    try {
      final db = await database;
      final count = await db.update(
        'meme_designs',
        meme.toJson(),
        where: 'id = ?',
        whereArgs: [meme.id],
      );
      AppLogger.logInfo('DATABASE', 'Updated meme design #${meme.id}');
      savedMemesChangeNotifier.value++;
      return count;
    } catch (e, stack) {
      AppLogger.logError(
        'DATABASE',
        'Failed to update meme design #${meme.id}',
        e,
        stack,
      );
      return 0;
    }
  }

  Future<int> deleteMemeDesign(int id) async {
    try {
      final db = await database;
      final count = await db.delete(
        'meme_designs',
        where: 'id = ?',
        whereArgs: [id],
      );
      AppLogger.logInfo('DATABASE', 'Deleted meme design #$id');
      savedMemesChangeNotifier.value++;
      return count;
    } catch (e, stack) {
      AppLogger.logError(
        'DATABASE',
        'Failed to delete meme design #$id',
        e,
        stack,
      );
      return 0;
    }
  }
}
