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
  static final List<MemeDesign> _testMemes = [];

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    try {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, 'meme_designs.db');

      final db = await openDatabase(
        path,
        version: 2,
        onCreate: (db, version) async {
          await _ensureTableAndColumns(db);
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          await _ensureTableAndColumns(db);
        },
      );
      await _ensureTableAndColumns(db);
      return db;
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

  Future<void> _ensureTableAndColumns(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS meme_designs (
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
        createdAt TEXT,
        filterId TEXT DEFAULT 'none',
        filterIntensity REAL DEFAULT 1.0,
        textLayersJson TEXT,
        textOffsetX REAL,
        textOffsetY REAL,
        frameId INTEGER,
        aspectRatio REAL,
        bgMode INTEGER DEFAULT 0,
        isTransparentBg INTEGER DEFAULT 0,
        blurSigma REAL DEFAULT 0.0,
        hasFilmGrain INTEGER DEFAULT 1,
        grainOpacity REAL DEFAULT 0.12,
        isInverted INTEGER DEFAULT 0,
        hasVignette INTEGER DEFAULT 0,
        letterSpacing REAL DEFAULT -0.5,
        textCase TEXT DEFAULT 'lowercase',
        frameBgOpacity REAL DEFAULT 1.0,
        frameBgFit TEXT DEFAULT 'cover'
      )
    ''');

    try {
      final columnsInfo = await db.rawQuery('PRAGMA table_info(meme_designs)');
      final existingColumns = columnsInfo.map((row) => (row['name'] as String).toLowerCase()).toSet();

      final migrationColumns = <String, String>{
        'filterid': 'ALTER TABLE meme_designs ADD COLUMN filterId TEXT DEFAULT "none"',
        'filterintensity': 'ALTER TABLE meme_designs ADD COLUMN filterIntensity REAL DEFAULT 1.0',
        'textlayersjson': 'ALTER TABLE meme_designs ADD COLUMN textLayersJson TEXT',
        'textoffsetx': 'ALTER TABLE meme_designs ADD COLUMN textOffsetX REAL',
        'textoffsety': 'ALTER TABLE meme_designs ADD COLUMN textOffsetY REAL',
        'frameid': 'ALTER TABLE meme_designs ADD COLUMN frameId INTEGER',
        'aspectratio': 'ALTER TABLE meme_designs ADD COLUMN aspectRatio REAL',
        'bgmode': 'ALTER TABLE meme_designs ADD COLUMN bgMode INTEGER DEFAULT 0',
        'istransparentbg': 'ALTER TABLE meme_designs ADD COLUMN isTransparentBg INTEGER DEFAULT 0',
        'blursigma': 'ALTER TABLE meme_designs ADD COLUMN blurSigma REAL DEFAULT 0.0',
        'hasfilmgrain': 'ALTER TABLE meme_designs ADD COLUMN hasFilmGrain INTEGER DEFAULT 1',
        'grainopacity': 'ALTER TABLE meme_designs ADD COLUMN grainOpacity REAL DEFAULT 0.12',
        'isinverted': 'ALTER TABLE meme_designs ADD COLUMN isInverted INTEGER DEFAULT 0',
        'hasvignette': 'ALTER TABLE meme_designs ADD COLUMN hasVignette INTEGER DEFAULT 0',
        'letterspacing': 'ALTER TABLE meme_designs ADD COLUMN letterSpacing REAL DEFAULT -0.5',
        'textcase': 'ALTER TABLE meme_designs ADD COLUMN textCase TEXT DEFAULT "lowercase"',
        'framebgopacity': 'ALTER TABLE meme_designs ADD COLUMN frameBgOpacity REAL DEFAULT 1.0',
        'framebgfit': 'ALTER TABLE meme_designs ADD COLUMN frameBgFit TEXT DEFAULT "cover"',
      };

      for (final entry in migrationColumns.entries) {
        if (!existingColumns.contains(entry.key)) {
          await db.execute(entry.value);
          AppLogger.logInfo('DATABASE', 'Migrated: added ${entry.key} column to meme_designs');
        }
      }
    } catch (e) {
      AppLogger.logError('DATABASE', 'Column migration check error', e);
    }
  }

  // CRUD operations
  Future<int> insertMemeDesign(MemeDesign meme) async {
    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      final generatedId = meme.id ?? (_testMemes.length + 1);
      final item = meme.copyWith(id: generatedId);
      _testMemes.removeWhere((m) => m.id == generatedId);
      _testMemes.insert(0, item);
      savedMemesChangeNotifier.value++;
      return generatedId;
    }

    try {
      final db = await database;
      await _ensureTableAndColumns(db);

      final rawMap = meme.toDbMap();
      final columnsInfo = await db.rawQuery('PRAGMA table_info(meme_designs)');
      final validColumns = columnsInfo.map((r) => r['name'] as String).toSet();
      final sanitizedMap = Map<String, dynamic>.from(rawMap)
        ..removeWhere((k, _) => !validColumns.contains(k));

      final id = await db.insert(
        'meme_designs',
        sanitizedMap,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
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
      return List<MemeDesign>.from(_testMemes);
    }
    try {
      final db = await database;
      await _ensureTableAndColumns(db);
      final List<Map<String, dynamic>> maps =
          await db.query('meme_designs', orderBy: 'id DESC');
      AppLogger.logInfo('DATABASE', 'Fetched ${maps.length} saved meme designs');

      final List<MemeDesign> results = [];
      for (final map in maps) {
        try {
          results.add(MemeDesign.fromJson(map));
        } catch (itemError, st) {
          AppLogger.logError('DATABASE', 'Failed to parse single meme row: ${map['id']}', itemError, st);
        }
      }
      return results;
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
    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      final idx = _testMemes.indexWhere((m) => m.id == meme.id);
      if (idx != -1) {
        _testMemes[idx] = meme;
      } else {
        _testMemes.insert(0, meme);
      }
      savedMemesChangeNotifier.value++;
      return 1;
    }

    try {
      final db = await database;
      await _ensureTableAndColumns(db);

      final rawMap = meme.toDbMap();
      final columnsInfo = await db.rawQuery('PRAGMA table_info(meme_designs)');
      final validColumns = columnsInfo.map((r) => r['name'] as String).toSet();
      final sanitizedMap = Map<String, dynamic>.from(rawMap)
        ..removeWhere((k, _) => !validColumns.contains(k));

      final count = await db.update(
        'meme_designs',
        sanitizedMap,
        where: 'id = ?',
        whereArgs: [meme.id],
      );
      AppLogger.logInfo('DATABASE', 'Updated meme design #${meme.id} (count: $count)');
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
    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      _testMemes.removeWhere((m) => m.id == id);
      savedMemesChangeNotifier.value++;
      return 1;
    }

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
