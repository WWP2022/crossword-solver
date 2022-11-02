import 'dart:async';

import 'package:crossword_solver/model/photo.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class CrosswordDatabase {
  static final CrosswordDatabase instance = CrosswordDatabase._init();
  static Database? _database;

  CrosswordDatabase._init();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDB('crosswordDatabase.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute(
        'CREATE TABLE $photoTable('
            '${PhotoFields.id} INTEGER PRIMARY KEY,'
            '${PhotoFields.path}  TEXT,'
            '${PhotoFields.name}  TEXT,'
            '${PhotoFields.date}  TEXT)'
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
